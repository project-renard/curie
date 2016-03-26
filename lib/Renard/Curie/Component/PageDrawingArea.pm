use Modern::Perl;
package Renard::Curie::Component::PageDrawingArea;

use Moo;
use Glib 'TRUE', 'FALSE';

has builder => ( is => 'ro', required => 1 );
has document => ( is => 'rw', required => 1 );

has current_rendered_page => ( is => 'rw' );
has current_page_number => (
	is => 'rw',
	default => sub { 1 },
	trigger => 1 # _trigger_current_page_number
	);

has [qw(drawing_area)] => ( is => 'rw' );

sub setup {
	my ($self) = @_;
	$self->setup_button_events;
	$self->setup_text_entry_events;
	$self->setup_drawing_area;
	$self->setup_number_of_pages_label;
	$self->setup_status_bar;
}

sub setup_button_events {
	my ($self) = @_;

	$self->builder->get_object('button-first')->signal_connect(
		clicked => \&set_current_page_to_first, $self );
	$self->builder->get_object('button-last')->signal_connect(
		clicked => \&set_current_page_to_last, $self );

	$self->builder->get_object('button-forward')->signal_connect(
		clicked => \&set_current_page_forward, $self );
	$self->builder->get_object('button-back')->signal_connect(
		clicked => \&set_current_page_back, $self );
}

sub setup_text_entry_events {
	my ($self) = @_;

	$self->builder->get_object('page-number-entry')->signal_connect(
		activate => \&set_current_page_number, $self );
}

sub refresh_drawing_area {
	my ($self) = @_;
	return unless $self->drawing_area;

	$self->drawing_area->queue_draw;
}

sub on_draw_page {
	my ($self, $cr) = @_;

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

sub setup_drawing_area {
	my ($self) = @_;

	my $vbox = $self->builder->get_object('application_vbox');

	my $drawing_area = Gtk3::DrawingArea->new();
	$self->drawing_area( $drawing_area );
	$drawing_area->signal_connect( draw => sub {
		my ($widget, $cr) = @_;

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

	$vbox->pack_start( $scrolled_window, TRUE, TRUE, 0);
}

sub _trigger_current_page_number {
	my ($self) = @_;
	$self->refresh_drawing_area;
}

sub set_current_page_number {
	my ($entry, $self) = @_;

	my $text = $entry -> get_text;
	if ($text =~ /^[0-9]+$/ and $text <= $self->document->last_page_number
			and $text >= $self->document->first_page_number){
		$self->current_page_number( $text );
	}
}

sub setup_number_of_pages_label {
	my ($self) = @_;
	$self->builder->get_object("number-of-pages-label")->set_text( $self->document->last_page_number );
}

sub setup_status_bar{
	my ($self) = @_;
	my ($status_bar) =  $self->builder->get_object('statusbar');
	my ($width, $height) =  $status_bar->get_size_request();
	$status_bar->set_border_width(3);
	$status_bar->set_size_request($width, 25);
}

sub set_current_page_forward {
	my ($button, $self) = @_;
	if( $self->can_move_to_next_page ) {
		$self->current_page_number( $self->current_page_number + 1 );
	}
}

sub set_current_page_back {
	my ($button, $self) = @_;
	if( $self->can_move_to_previous_page ) {
		$self->current_page_number( $self->current_page_number - 1 );
	}
}

sub set_current_page_to_first {
	my ($button, $self) = @_;
	$self->current_page_number( $self->document->first_page_number );
}

sub set_current_page_to_last {
	my ($button, $self) = @_;
	$self->current_page_number( $self->document->last_page_number );
}

sub can_move_to_previous_page {
	my ($self) = @_;
	$self->current_page_number > $self->document->first_page_number;
}

sub can_move_to_next_page {
	my ($self) = @_;
	$self->current_page_number < $self->document->last_page_number;
}

=method set_navigation_buttons_sensitivity


Enables and disables forward and back navigation buttons when at the end and
start of the document respectively.

=cut
sub set_navigation_buttons_sensitivity {
	my ($self) = @_;
	my $can_move_forward = $self->can_move_to_next_page;
	my $can_move_back = $self->can_move_to_previous_page;

	for my $button_name ( qw(button-last button-forward) ) {
		$self->builder->get_object($button_name)->set_sensitive($can_move_forward);
	}

	for my $button_name ( qw(button-first button-back) ) {
		$self->builder->get_object($button_name)->set_sensitive($can_move_back);
	}
}

1;
