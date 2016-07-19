use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::Outlineable;
# ABSTRACT: TODO

use Moo::Role;
use Renard::Curie::Types qw(InstanceOf);

=attr outline

TODO

=cut
has outline => (
	is => 'lazy', # _build_outline
	isa => InstanceOf['Renard::Curie::Model::Outline'],
);

1;
