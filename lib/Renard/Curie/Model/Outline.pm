use Renard::Curie::Setup;
package Renard::Curie::Model::Outline;
# ABSTRACT: TODO

use Moo;
use Renard::Curie::Types qw(ArrayRef HashRef);

=attr items

TODO

=cut
has items => (
	is => 'rw',
	required => 1,
	isa => ArrayRef[HashRef],
);

1;
