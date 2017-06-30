use Renard::Curie::Setup;
package Renard::Curie::Component::Role::HasParentMainWindow;
# ABSTRACT: Role that links a component to the parent main window

use Moo::Role;
use Renard::Curie::Types qw(InstanceOf);

=attr main_window

Links the component to the parent L<Renard::Curie::Component::MainWindow> component.

=cut
has main_window => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Component::MainWindow'],
);

1;
