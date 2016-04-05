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
	$self->setup_drawing_area;
}

sub refresh_drawing_area {
	my ($self) = @_;
	return unless $self->drawing_area;
	$self->drawing_area->queue_draw;
}

sub on_draw_page {
	my ($self, $cr) = @_;

	my $img = $self->current_rendered_page->cairo_image_surface;

	$cr->set_source_surface($img, 0, 0);
	$cr->paint;

	$self->drawing_area->set_size_request(
		$self->current_rendered_page->width,
		$self->current_rendered_page->height );
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

1;
