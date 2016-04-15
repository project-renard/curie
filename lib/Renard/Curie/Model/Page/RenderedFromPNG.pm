use Modern::Perl;
package Renard::Curie::Model::Page::RenderedFromPNG;

use Moo;

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

with qw(
	Renard::Curie::Model::Page::Role::CairoRenderable
);

1;
