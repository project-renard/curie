use Renard::Curie::Setup;
package Renard::Curie::Model::Page::Role::CairoRenderable;
# ABSTRACT: Role for pages that represented by a Cairo image surface

use Moo::Role;
use Function::Parameters;
use Renard::Curie::Types qw(PositiveOrZeroInt);
use Function::Parameters;

with qw(Renard::Curie::Model::Page::Role::Bounds);

=attr cairo_image_surface

The L<Cairo::ImageSurface> which consumers of this role will render.

Consumes of this role must implement this.

=cut
requires 'cairo_image_surface';

=attr width

A L<PositiveOrZeroInt> that is the width of the C</cairo_image_surface>.

=attr height

A L<PositiveOrZeroInt> that is the height of the C</cairo_image_surface>.

=cut
has [ qw(width height) ] => (
	is => 'lazy', # _build_width _build_height
	isa => PositiveOrZeroInt,
);

method _build_width() :ReturnType(PositiveOrZeroInt) {
	$self->cairo_image_surface->get_width;
}

method _build_height() :ReturnType(PositiveOrZeroInt) {
	$self->cairo_image_surface->get_height;
}

1;
