use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Grid::Subview;
# ABSTRACT: A subview for a grid-layout

use Moo;
use Renard::Incunabula::Common::Types qw(InstanceOf);

has _grid_view => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Model::View::Grid']
);

has _grid_scheme => (
	is => 'ro',
	required => 1,
);

1;
