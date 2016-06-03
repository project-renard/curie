use Renard::Curie::Setup;
package Renard::Curie::Model::Page::CairoImageSurface;

use Moo;
use Renard::Curie::Types qw(InstanceOf);

has cairo_image_surface => (
	is => 'ro',
	isa => InstanceOf['Cairo::ImageSurface'],
	required => 1
);

with qw(Renard::Curie::Model::Page::Role::CairoRenderable);

1;
