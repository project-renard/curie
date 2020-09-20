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

has document => (
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
			document => $self->document,
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
	my $group = $_LayoutGroup->new(
		layout => Renard::Jacquard::Layout::Grid->new( rows => 2, columns => 2 ),
	);

	$group->add_child( $self->create_group(start => 1, end => 6,   margin => 10) );
	$group->add_child( $self->create_group(start => 7, end => 12,  margin => 50) );
	$group->add_child( $self->create_group(start => 13, end => 18, margin => 100) );
	$group->add_child( $self->create_group(start => 19, end => 24, margin => 150) );

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
