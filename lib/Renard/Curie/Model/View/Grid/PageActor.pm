use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Grid::PageActor;
# ABSTRACT: A jacquard actor for a document page

use Mu;
use Renard::Block::Format::Cairo::Types qw(RenderableDocumentModel);
use Renard::Taffeta::Graphics::Image::PNG;
use Renard::Yarn::Graphene;
use Renard::Yarn::Types qw(Point Size);
use List::AllUtils qw(pairmap);

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

lazy _taffeta => method() {
	my $rp = $self->_rendered_page;
	my $taffeta = Renard::Taffeta::Graphics::Image::PNG->new(
		data => $rp->png_data,
		origin => $self->origin_point,
	);
};

method render($svg) {
	$self->_taffeta->render_svg( $svg );
}

method render_cairo($cr) {
	return unless $self->{visible};
	$self->_taffeta->render_cairo( $cr );
}

lazy _textual_page => method() {
	my $tp = $self->document->get_textual_page(
		$self->page_number,
	);

	$tp;
};

method text_at_point( (Point) $point) {
	my $tp = $self->_textual_page;

	my $page_transform = Renard::Yarn::Graphene::Matrix->new;
	$page_transform->init_from_2d( 1, 0 , 0 , 1,
		$self->x->value,
		$self->y->value );

	my $bbox_to_rect = sub {
		my ($bbox) = @_;
		my ($x0, $y0, $x1, $y1) = split ' ', $bbox;
		$page_transform->transform_bounds(
			Renard::Yarn::Graphene::Rect->new(
				origin => Point->coerce([$x0, $y0]),
				size => Size->coerce([$x1-$x0, $y1-$y0]),
			)
		);
	};
	my $m_quad_to_g_quad = sub {
		my ($quad) = @_;
		my @points = pairmap { Point->coerce([$a, $b]) } split ' ', $quad;
		$page_transform->transform_quad(
			Renard::Yarn::Graphene::Quad->alloc->init_from_points( \@points )
		);
	};

	my @blocks;
	$tp->iter_extents( sub {
		my ($extent, $tag_name, $tag_value) = @_;
		my $g_bbox = $bbox_to_rect->($tag_value->{bbox});
		push @blocks, {
			extent => $extent,
			tag => $tag_name,
			bbox => $g_bbox,
		} if $g_bbox->contains_point( $point );
	}, only => ['block'] );

	if( @blocks ) {
		return $blocks[0];
	}
}

with qw(
	Renard::Jacquard::Role::Render::QnD::SVG
	Renard::Jacquard::Role::Render::QnD::Cairo
	Renard::Jacquard::Role::Geometry::Position2D
	Renard::Jacquard::Role::Render::QnD::Size::Direct
	Renard::Jacquard::Role::Render::QnD::Bounds::Direct
);

1;
