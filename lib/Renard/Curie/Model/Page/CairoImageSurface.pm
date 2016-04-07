use Modern::Perl;
package Renard::Curie::Model::Page::CairoImageSurface;

use Moo;

has cairo_image_surface => ( is => 'ro', required => 1 );

with qw(Renard::Curie::Model::Page::Role::CairoRenderable);

1;
