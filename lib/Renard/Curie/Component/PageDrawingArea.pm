use Renard::Curie::Setup;
package Renard::Curie::Component::PageDrawingArea;

use Moo;
use Glib 'TRUE', 'FALSE';
use Glib::Object::Subclass 'Gtk3::Bin';
use Renard::Curie::Types qw(RenderableDocumentModel PageNumber Bool InstanceOf);
use Function::Parameters;

has document => (
	is => 'rw',
	isa => (RenderableDocumentModel),
	required => 1
);

has current_rendered_page => ( is => 'rw' );
has current_page_number => (
	is => 'rw',
	isa => PageNumber,
	default => 1,
	trigger => 1 # _trigger_current_page_number
	);

has [qw(drawing_area)] => (
	is => 'rw',
	isa => InstanceOf['Gtk3::DrawingArea'],
);

has scrolled_window => (
	is => 'rw',
	isa => InstanceOf['Gtk3::ScrolledWindow'],
);

classmethod FOREIGNBUILDARGS(@) {
	return ();
}

method BUILD {
	# so that the widget can take input
	$self->set_can_focus( TRUE );

	$self->setup_button_events;
	$self->setup_text_entry_events;
	$self->setup_drawing_area;
	$self->setup_number_of_pages_label;
	$self->setup_keybindings;

	# add as child for this Gtk3::Bin
	$self->add(
		$self->builder->get_object('page-drawing-component')
	);
}

method setup_button_events() {
	$self->builder->get_object('button-first')->signal_connect(
		clicked => \&on_activate_button_first_cb, $self );
	$self->builder->get_object('button-last')->signal_connect(
		clicked => \&on_activate_button_last_cb, $self );

	$self->builder->get_object('button-forward')->signal_connect(
		clicked => \&on_activate_button_forward_cb, $self );
	$self->builder->get_object('button-back')->signal_connect(
		clicked => \&on_activate_button_back_cb, $self );

	$self->set_navigation_buttons_sensitivity;
}

fun on_activate_button_first_cb($button, $self) {
	$self->set_current_page_to_first;
}

fun on_activate_button_last_cb($button, $self) {
	$self->set_current_page_to_last;
}

fun on_activate_button_forward_cb($button, $self) {
	$self->set_current_page_forward;
}

fun on_activate_button_back_cb($button, $self) {
	$self->set_current_page_back;
}

method setup_text_entry_events() {
	$self->builder->get_object('page-number-entry')->signal_connect(
		activate => \&on_activate_page_number_entry_cb, $self );
}

method setup_drawing_area() {
	my $drawing_area = Gtk3::DrawingArea->new();
	$self->drawing_area( $drawing_area );
	$drawing_area->signal_connect( draw => fun (
			(InstanceOf['Gtk3::DrawingArea']) $widget,
			(InstanceOf['Cairo::Context']) $cr) {
		my $rp = $self->document->get_rendered_page(
			page_number => $self->current_page_number,
		);
		$self->current_rendered_page( $rp );
		$self->on_draw_page( $cr );

		return TRUE;
	}, $self);

	my $scrolled_window = Gtk3::ScrolledWindow->new();
	$scrolled_window->set_hexpand(TRUE);
	$scrolled_window->set_vexpand(TRUE);

	$scrolled_window->add($drawing_area);
	$scrolled_window->set_policy( 'automatic', 'automatic');
	$self->scrolled_window($scrolled_window);

	my $vbox = $self->builder->get_object('page-drawing-component');
	$vbox->pack_start( $scrolled_window, TRUE, TRUE, 0);
}

method setup_number_of_pages_label() {
	$self->builder->get_object("number-of-pages-label")->set_text( $self->document->last_page_number );
}

method setup_keybindings() {
	$self->signal_connect( key_press_event => \&on_key_press_event_cb, $self );
}

fun on_key_press_event_cb($window, $event, $self) {
	if($event->keyval == Gtk3::Gdk::KEY_Page_Down){
		$self->set_current_page_forward;
	} elsif($event->keyval == Gtk3::Gdk::KEY_Page_Up){
		$self->set_current_page_back;
	} elsif($event->keyval == Gtk3::Gdk::KEY_Up){
		decrement_scroll($self->scrolled_window->get_vadjustment);
	} elsif($event->keyval == Gtk3::Gdk::KEY_Down){
		increment_scroll($self->scrolled_window->get_vadjustment);
	} elsif($event->keyval == Gtk3::Gdk::KEY_Right){
		increment_scroll($self->scrolled_window->get_hadjustment);
	} elsif($event->keyval == Gtk3::Gdk::KEY_Left){
		decrement_scroll($self->scrolled_window->get_hadjustment);
	}
}

fun increment_scroll( (InstanceOf['Gtk3::Adjustment']) $current ) {
	my $adjustment = $current->get_value + $current->get_step_increment;
	$current->set_value($adjustment);
}

fun decrement_scroll( (InstanceOf['Gtk3::Adjustment']) $current ) {
	my $adjustment = $current->get_value - $current->get_step_increment;
	$current->set_value($adjustment);
}

method refresh_drawing_area() {
	return unless $self->drawing_area;

	$self->drawing_area->queue_draw;
}

method on_draw_page( (InstanceOf['Cairo::Context']) $cr ) {
	$self->set_navigation_buttons_sensitivity;

	my $img = $self->current_rendered_page->cairo_image_surface;

	$cr->set_source_surface($img, 0, 0);
	$cr->paint;

	$self->drawing_area->set_size_request(
		$self->current_rendered_page->width,
		$self->current_rendered_page->height );

	$self->builder->get_object('page-number-entry')
		->set_text($self->current_page_number);
}

method _trigger_current_page_number {
	$self->refresh_drawing_area;
}

fun on_activate_page_number_entry_cb( $entry, $self ) {
	my $text = $entry -> get_text;
	if ($text =~ /^[0-9]+$/ and $text <= $self->document->last_page_number
			and $text >= $self->document->first_page_number) {
		$self->current_page_number( $text );
	}
}

method set_current_page_forward() {
	if( $self->can_move_to_next_page ) {
		$self->current_page_number( $self->current_page_number + 1 );
	}
}

method set_current_page_back() {
	if( $self->can_move_to_previous_page ) {
		$self->current_page_number( $self->current_page_number - 1 );
	}
}

method set_current_page_to_first() {
	$self->current_page_number( $self->document->first_page_number );
}

method set_current_page_to_last() {
	$self->current_page_number( $self->document->last_page_number );
}

method can_move_to_previous_page() :ReturnType(Bool) {
	$self->current_page_number > $self->document->first_page_number;
}

method can_move_to_next_page() :ReturnType(Bool) {
	$self->current_page_number < $self->document->last_page_number;
}

=method set_navigation_buttons_sensitivity


Enables and disables forward and back navigation buttons when at the end and
start of the document respectively.

=cut
method set_navigation_buttons_sensitivity() {
	my $can_move_forward = $self->can_move_to_next_page;
	my $can_move_back = $self->can_move_to_previous_page;

	for my $button_name ( qw(button-last button-forward) ) {
		$self->builder->get_object($button_name)->set_sensitive($can_move_forward);
	}

	for my $button_name ( qw(button-first button-back) ) {
		$self->builder->get_object($button_name)->set_sensitive($can_move_back);
	}
}

with qw(
	Renard::Curie::Component::Role::FromBuilder
	Renard::Curie::Component::Role::UIFileFromPackageName
);

1;
