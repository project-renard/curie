use Renard::Curie::Setup;
package Renard::Curie::Component::Role::HasParentApp;
# ABSTRACT: Role that links a component to the parent application

use Moo::Role;
use Renard::Curie::Types qw(InstanceOf);

=attr app

Links the component to the parent L<Renard::Curie::Component::MainWindow> component.

=cut
has app => (
	is => 'ro',
	isa => InstanceOf['Renard::Curie::Component::MainWindow'],
	required => 1,
	weak_ref => 1
);

1;
