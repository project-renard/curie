package Renard::Curie::Model::RenderedDocumentPage;

use Modern::Perl;
use Moo;
use Path::Tiny;

has [ qw(width height) ] => (
	is => 'lazy' # _build_width _build_height
);

has zoom_level => ( is => 'rw' );

has png_data => ( is => 'rw', required => 1 );

has cairo_image_surface => (
	is => 'lazy', # _build_cairo_image_surface
);

sub _build_cairo_image_surface {
	my ($self) = @_;

	# read the PNG data in-memory
	my $img = Cairo::ImageSurface->create_from_png_stream(
		sub {
			my ($callback_data, $length) = @_;
			state $offset = 0;
			my $data = substr $callback_data, $offset, $length;
			$offset += $length;
			$data;
		}, $self->png_data );

	return $img;
}

sub _build_width {
	my ($self) = @_;
	$self->cairo_image_surface->get_width;
}

sub _build_height {
	my ($self) = @_;
	$self->cairo_image_surface->get_height;
}

1;
