use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::FromFile;

use Moo::Role;
use Renard::Curie::Types qw(File);

=attr filename

A C<Str> containing the path to the PDF document.

=cut
has filename => (
	is => 'ro',
	isa => File,
	coerce => 1,
);

1;
