use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::FromFile;
# ABSTRACT: Role that provides a filename for a document

use Moo::Role;
use Renard::Curie::Types qw(File);

=attr filename

A C<Str> containing the path to a document.

=cut
has filename => (
	is => 'ro',
	isa => File,
	coerce => 1,
);

1;
