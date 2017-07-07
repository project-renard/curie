use Renard::Curie::Setup;
package Renard::Curie::Model::Page::RenderedFromPNG;
# ABSTRACT: Page generated from PNG data

use Moo;

with qw(
	Renard::Curie::Model::Page::Role::CairoRenderableFromPNG
	Renard::Curie::Model::Page::Role::BoundsFromCairoImageSurface
);

1;
