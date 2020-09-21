use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Scenegraph;
# ABSTRACT: A Jacquard Scene graph factory

use Mu;

use feature qw(current_sub);

use Renard::Curie::Model::View::Grid::PageActor;
use Renard::Jacquard::Layout::Grid;
use Renard::Jacquard::Layout::Box;

my $_LayoutGroup = Moo::Role->create_class_with_roles(
	'Renard::Jacquard::Actor' => qw(
	Renard::Jacquard::Role::Geometry::Position2D
	Renard::Jacquard::Role::Geometry::Size2D
	Renard::Jacquard::Role::Render::QnD::SVG::Group
	Renard::Jacquard::Role::Render::QnD::Cairo::Group
	Renard::Jacquard::Role::Render::QnD::Layout
	Renard::Jacquard::Role::Render::QnD::Size::Direct
	Renard::Jacquard::Role::Render::QnD::Bounds::Direct
));

has box_layout => (
	is => 'ro',
	default => sub { 1 },
);

has view_manager => (
	is => 'ro',
);

lazy graph => method() {
	my $graph = $self->create_scene_graph;
	$self->update_layout($graph);

	$graph;
};

method create_group( :$start, :$end, :$margin = 10 ) {
	my $group = $_LayoutGroup->new(
		layout => Renard::Jacquard::Layout::Grid->new( rows => 3, columns => 2 ),
	);

	for my $page_no ($start..$end) {
		my $actor = Renard::Curie::Model::View::Grid::PageActor->new(
			document => $self->view_manager->current_document,
			page_number => $page_no,
		);
		if( $self->box_layout ) {
			my $box = $_LayoutGroup->new(
				layout => Renard::Jacquard::Layout::Box->new( margin => $margin ),
			);
			$box->add_child( $actor );
			$group->add_child( $box );
		} else {
			$group->add_child( $actor );
		}
	}

	$group;
}

method create_scene_graph() {
	my $grid_scheme = $self->view_manager->current_view
		->_current_subview->_grid_scheme;
	my @pages = @{ $grid_scheme->pages };

	my $group = $_LayoutGroup->new(
		layout => Renard::Jacquard::Layout::Grid->new(
			rows => $grid_scheme->rows,
			columns => $grid_scheme->columns ),
	);

	$group->add_child( $self->create_group(start => $pages[0], end => $pages[-1],   margin => 10) );

	$group->x->value( 0 );
	$group->y->value( 0 );

	return $group;
}

sub _update_layouts {
	my ($g) = @_;
	__SUB__->($_) for @{ $g->children };
	$g->update_layout if $g->can('update_layout');
}

method update_layout($group) {
	_update_layouts($group);
}

1;
