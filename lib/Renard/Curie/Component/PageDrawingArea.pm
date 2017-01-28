use Renard::Curie::Setup;
package Renard::Curie::Component::PageDrawingArea;
# ABSTRACT: Component that implements document page navigation

use Moo;
use Glib 'TRUE', 'FALSE';
use Glib::Object::Subclass 'Gtk3::Bin';
use Renard::Curie::Types qw(RenderableDocumentModel RenderablePageModel
	PageNumber ZoomLevel Bool InstanceOf);
use Function::Parameters;
use Renard::Curie::Model::View::SinglePage;

=attr view

TODO

=cut
has view => (
	is => 'rw',
	required => 1
);

method zoom_level() { $self->view->zoom_level }

=attr drawing_area

The L<Gtk3::DrawingArea> that is used to draw the document on.

=cut
has drawing_area => (
	is => 'rw',
	isa => InstanceOf['Gtk3::DrawingArea'],
);

=attr scrolled_window

The L<Gtk3::ScrolledWindow> container for the L</drawing_area>.

=cut
has scrolled_window => (
	is => 'rw',
	isa => InstanceOf['Gtk3::ScrolledWindow'],
);

around BUILDARGS => sub {
	my ( $orig, $class, %args ) = @_;

	if( exists $args{document} ) {
		my $doc = delete $args{document};
		$args{view} = Renard::Curie::Model::View::SinglePage->new(
			document => $doc,
		);
	}

	return $class->$orig(%args);
};

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Initialises the L<Gtk3::Bin> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}

=method BUILD

  method BUILD

Initialises the component's contained widgets and signals.

=cut
method BUILD(@) {
	$self->view->_pd($self); # HACK TODO
	# so that the widget can take input
	$self->set_can_focus( TRUE );

	$self->setup_button_events;
	$self->setup_text_entry_events;
	$self->setup_drawing_area;
	$self->setup_number_of_pages_label;
	$self->setup_keybindings;
	$self->setup_scroll_bindings;

	# add as child for this L<Gtk3::Bin>
	$self->add(
		$self->builder->get_object('page-drawing-component')
	);
}

=method setup_button_events

  method setup_button_events()

Sets up the signals for the navigational buttons.

=cut
method setup_button_events() {
	$self->builder->get_object('button-first')->signal_connect(
		clicked => \&on_clicked_button_first_cb, $self );
	$self->builder->get_object('button-last')->signal_connect(
		clicked => \&on_clicked_button_last_cb, $self );

	$self->builder->get_object('button-forward')->signal_connect(
		clicked => \&on_clicked_button_forward_cb, $self );
	$self->builder->get_object('button-back')->signal_connect(
		clicked => \&on_clicked_button_back_cb, $self );

	$self->set_navigation_buttons_sensitivity;
}

=callback on_clicked_button_first_cb

  callback on_clicked_button_first_cb($button, $self)

Callback for when the "First" button is pressed.
See L</set_current_page_to_first>.

=cut
callback on_clicked_button_first_cb($button, $self) {
	$self->set_current_page_to_first;
}

=callback on_clicked_button_last_cb

  callback on_clicked_button_last_cb($button, $self)

Callback for when the "Last" button is pressed.
See L</set_current_page_to_last>.

=cut
callback on_clicked_button_last_cb($button, $self) {
	$self->set_current_page_to_last;
}

=callback on_clicked_button_forward_cb

  callback on_clicked_button_forward_cb($button, $self)

Callback for when the "Forward" button is pressed.
See L</set_current_page_forward>.

=cut
callback on_clicked_button_forward_cb($button, $self) {
	$self->set_current_page_forward;
}

=callback on_clicked_button_back_cb

  callback on_clicked_button_back_cb($button, $self)

Callback for when the "Back" button is pressed.
See L</set_current_page_back>.

=cut
callback on_clicked_button_back_cb($button, $self) {
	$self->set_current_page_back;
}

=method setup_text_entry_events

  method setup_text_entry_events()

Sets up the signals for the text entry box so the user can enter in page
numbers.

=cut
method setup_text_entry_events() {
	$self->builder->get_object('page-number-entry')->signal_connect(
		activate => \&on_activate_page_number_entry_cb, $self );
}

=method setup_drawing_area

  method setup_drawing_area()

Sets up the L</drawing_area> so that it draws the current page.

=cut
method setup_drawing_area() {
	my $drawing_area = Gtk3::DrawingArea->new();
	$self->drawing_area( $drawing_area );
	$drawing_area->signal_connect( draw => callback(
			(InstanceOf['Gtk3::DrawingArea']) $widget,
			(InstanceOf['Cairo::Context']) $cr) {
		$self->on_draw_page_cb( $cr );

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

=method setup_number_of_pages_label

  method setup_number_of_pages_label()

Sets up the label that shows the number of pages in the document.

=cut
method setup_number_of_pages_label() {
	$self->builder->get_object("number-of-pages-label")
		->set_text( $self->view->document->last_page_number );
}

=method setup_keybindings

  method setup_keybindings()

Sets up the signals to capture key presses on this component.

=cut
method setup_keybindings() {
	$self->signal_connect( key_press_event => \&on_key_press_event_cb, $self );
}

=callback on_key_press_event_cb

  callback on_key_press_event_cb($window, $event, $self)

Callback that responds to specific key events and dispatches to the appropriate
handlers.

=cut
callback on_key_press_event_cb($window, $event, $self) {
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

=method setup_scroll_bindings

  method setup_scroll_bindings()

Sets up the signals to capture scroll events on this component.

=cut
method setup_scroll_bindings() {
	$self->scrolled_window->signal_connect(
		'scroll-event' => \&on_scroll_event_cb, $self );
}

=callback on_scroll_event_cb

  callback on_scroll_event_cb($window, $event, $self)

Callback that responds to specific scroll events and dispatches the associated
handlers.

=cut
callback on_scroll_event_cb($window, $event, $self) {
	if ( $event->state == 'control-mask' && $event->direction eq 'smooth') {
		my ($delta_x, $delta_y) =  $event->get_scroll_deltas();
		if ( $delta_y < 0 ) { $self->zoom_level ( $self->zoom_level - .05 ); }
		elsif ( $delta_y > 0 ) { $self->zoom_level ( $self->zoom_level + .05 ); }
		return 1;
	} elsif ( $event->state == 'control-mask' && $event->direction eq 'up' ) {
		$self->zoom_level ( $self->zoom_level + .05 );
		return 1;
	} elsif ( $event->state == 'control-mask' && $event->direction eq 'down' ) {
		$self->zoom_level ( $self->zoom_level - .05 );
		return 1;
	}
	return 0;
}

=func increment_scroll

  fun increment_scroll( (InstanceOf['Gtk3::Adjustment']) $current )

Helper function that scrolls down by the scrollbar's step increment.

=cut
fun increment_scroll( (InstanceOf['Gtk3::Adjustment']) $current ) {
	my $adjustment = $current->get_value + $current->get_step_increment;
	$current->set_value($adjustment);
}

=func decrement_scroll

  fun decrement_scroll( (InstanceOf['Gtk3::Adjustment']) $current )

Helper function that scrolls up by the scrollbar's step increment.

=cut
fun decrement_scroll( (InstanceOf['Gtk3::Adjustment']) $current ) {
	my $adjustment = $current->get_value - $current->get_step_increment;
	$current->set_value($adjustment);
}

=method refresh_drawing_area

  method refresh_drawing_area()

This forces the drawing area to redraw.

=cut
method refresh_drawing_area() {
	return unless $self->drawing_area;

	$self->drawing_area->queue_draw;
}

=callback on_draw_page_cb

  method on_draw_page_cb( (InstanceOf['Cairo::Context']) $cr )

Callback that draws the current page on to the L</drawing_area>.

=cut
method on_draw_page_cb( (InstanceOf['Cairo::Context']) $cr ) {
	# NOTE: we may want to change the signature to match the other
	# callbacks with $self as the last argument.
	$self->set_navigation_buttons_sensitivity;

	my $rp = $self->view->rendered_page;

	my $img = $rp->cairo_image_surface;

	$cr->set_source_surface($img, ($self->drawing_area->get_allocated_width -
		$rp->width) / 2, 0);
	$cr->paint;

	$self->drawing_area->set_size_request(
		$rp->width,
		$rp->height );

	$self->builder->get_object('page-number-entry')
		->set_text($self->view->page_number);
}

=callback on_activate_page_number_entry_cb

  callback on_activate_page_number_entry_cb( $entry, $self )

Callback that is called when text has been entered into the page number entry.

=cut
callback on_activate_page_number_entry_cb( $entry, $self ) {
	my $text = $entry->get_text;
	if( $self->view->document->is_valid_page_number($text) ) {
		$self->view->page_number( $text );
	} else {
		Renard::Curie::Error::User::InvalidPageNumber->throw;
	}
}

=method set_current_page_forward

  method set_current_page_forward()

Increments the current page number if possible.

=cut
method set_current_page_forward() {
	if( $self->can_move_to_next_page ) {
		$self->view->page_number( $self->view->page_number + 1 );
	}
}

=method set_current_page_back

  method set_current_page_back()

Decrements the current page number if possible.

=cut
method set_current_page_back() {
	if( $self->can_move_to_previous_page ) {
		$self->view->page_number( $self->view->page_number - 1 );
	}
}

=method set_current_page_to_first

  method set_current_page_to_first()

Sets the page number to the first page of the document.

=cut
method set_current_page_to_first() {
	$self->view->page_number( $self->view->document->first_page_number );
}

=method set_current_page_to_last

  method set_current_page_to_last()

Sets the current page to the last page of the document.

=cut
method set_current_page_to_last() {
	$self->view->page_number( $self->view->document->last_page_number );
}

=method can_move_to_previous_page

  method can_move_to_previous_page() :ReturnType(Bool)

Predicate to check if we can decrement the current page number.

=cut
method can_move_to_previous_page() :ReturnType(Bool) {
	$self->view->page_number > $self->view->document->first_page_number;
}

=method can_move_to_next_page

  method can_move_to_next_page() :ReturnType(Bool)

Predicate to check if we can increment the current page number.

=cut
method can_move_to_next_page() :ReturnType(Bool) {
	$self->view->page_number < $self->view->document->last_page_number;
}

=method set_navigation_buttons_sensitivity

  set_navigation_buttons_sensitivity()

Enables and disables forward and back navigation buttons when at the end and
start of the document respectively.

=cut
method set_navigation_buttons_sensitivity() {
	my $can_move_forward = $self->can_move_to_next_page;
	my $can_move_back = $self->can_move_to_previous_page;

	for my $button_name ( qw(button-last button-forward) ) {
		$self->builder->get_object($button_name)
			->set_sensitive($can_move_forward);
	}

	for my $button_name ( qw(button-first button-back) ) {
		$self->builder->get_object($button_name)
			->set_sensitive($can_move_back);
	}
}

with qw(
	Renard::Curie::Component::Role::FromBuilder
	Renard::Curie::Component::Role::UIFileFromPackageName
);

1;
