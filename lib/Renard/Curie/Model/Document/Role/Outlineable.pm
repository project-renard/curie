use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::Outlineable;
# ABSTRACT: Role that provides an outline for a document

use Moo::Role;
use Renard::Curie::Types qw(InstanceOf);

=attr outline

Returns a L<Renard::Curie::Model::Outline> which represents the outline for
this document.

=cut
has outline => (
	is => 'lazy', # _build_outline
	isa => InstanceOf['Renard::Curie::Model::Outline'],
);

1;
