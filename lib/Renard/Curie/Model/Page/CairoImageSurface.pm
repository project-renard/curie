use Renard::Curie::Setup;
package Renard::Curie::Model::Page::CairoImageSurface;
# ABSTRACT: Page directly generated from a Cairo image surface

use Moo;
use Renard::Curie::Types qw(InstanceOf);

=attr cairo_image_surface

The L<Cairo::ImageSurface> that this page is drawn on.

=cut
has cairo_image_surface => (
	is => 'ro',
	isa => InstanceOf['Cairo::ImageSurface'],
	required => 1
);

with qw(Renard::Curie::Model::Page::Role::CairoRenderable);

1;
