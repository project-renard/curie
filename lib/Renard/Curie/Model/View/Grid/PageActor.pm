use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Grid::PageActor;
# ABSTRACT: A jacquard actor for a document page

use Mu;
use Renard::Block::Format::Cairo::Types qw(RenderableDocumentModel);
use Renard::Taffeta::Graphics::Image::PNG;
use Renard::Yarn::Graphene;

extends qw(Renard::Jacquard::Actor);

ro document => (
	isa => RenderableDocumentModel,
);

ro 'page_number';


lazy _rendered_page => method() {
	$self->document->get_rendered_page(
		page_number => $self->page_number,
	);
};

lazy height => method() { $self->_rendered_page->height };
lazy width => method() { $self->_rendered_page->width };

lazy size => method() {
	Renard::Yarn::Graphene::Size->new(
		height => $self->height,
		width => $self->width,
	);
};

lazy bounds => method() {
	Renard::Yarn::Graphene::Rect->new(
		origin => $self->origin_point,
		size => $self->size,
	);
};

method render($svg) {
	my $rp = $self->_rendered_page;
	my $taffeta = Renard::Taffeta::Graphics::Image::PNG->new(
		data => $rp->png_data,
		origin => $self->origin_point,
	);
	$taffeta->render_svg( $svg );
}

with qw(Renard::Jacquard::Role::Geometry::Position2D);

1;
