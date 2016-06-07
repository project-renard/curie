use Renard::Curie::Setup;
package Renard::Curie::Model::Page::Role::CairoRenderable;

use Moo::Role;
use Function::Parameters;
use Renard::Curie::Types qw(PositiveOrZeroInt);
use Function::Parameters;

with qw(Renard::Curie::Model::Page::Role::Bounds);

requires 'cairo_image_surface';

has [ qw(width height) ] => (
	is => 'lazy', # _build_width _build_height
	isa => PositiveOrZeroInt,
);

method _build_width :ReturnType(PositiveOrZeroInt) {
	$self->cairo_image_surface->get_width;
}

method _build_height :ReturnType(PositiveOrZeroInt) {
	$self->cairo_image_surface->get_height;
}

1;
