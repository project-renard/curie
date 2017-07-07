use Renard::Curie::Setup;
package Renard::Curie::Model::Page::Role::CairoRenderable;
# ABSTRACT: Role for pages that represented by a Cairo image surface

use Moo::Role;
use Function::Parameters;
use Renard::Curie::Types qw(PositiveOrZeroInt);
use Function::Parameters;

=attr cairo_image_surface

The L<Cairo::ImageSurface> which consumers of this role will render.

Consumes of this role must implement this.

=cut
requires 'cairo_image_surface';

1;
