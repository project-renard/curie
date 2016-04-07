use Modern::Perl;
package Renard::Curie::Model::Page::Role::CairoRenderable;

use Moo::Role;

with qw(Renard::Curie::Model::Page::Role::Bounds);

requires 'cairo_image_surface';

has [ qw(width height) ] => (
	is => 'lazy' # _build_width _build_height
);

sub _build_width {
	my ($self) = @_;
	$self->cairo_image_surface->get_width;
}

sub _build_height {
	my ($self) = @_;
	$self->cairo_image_surface->get_height;
}

1;
