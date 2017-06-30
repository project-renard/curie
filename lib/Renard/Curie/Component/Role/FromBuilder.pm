use Renard::Curie::Setup;
package Renard::Curie::Component::Role::FromBuilder;
# ABSTRACT: Role that loads a Glade UI file into a Gtk3::Builder

use Moo::Role;
use Renard::Curie::Helper;
use Renard::Curie::Types qw(InstanceOf);

=attr ui_file

A C<Str> that contains the path to a Glade file to be loaded.

Consumers of this role must implement this.

=cut
requires 'ui_file';

=attr builder

A C<Gtk3::Builder> that contains the contents of the Glade file referenced in
C<ui_file>.

=cut
has builder => (
	is => 'lazy', # _build_builder
	isa => InstanceOf['Gtk3::Builder'],
);

method _build_builder() :ReturnType(InstanceOf['Gtk3::Builder']) {
	return Gtk3::Builder->new;
}

before BUILD => method(@) {
	$self->builder->add_from_file( $self->ui_file );
	$self->builder->connect_signals;
};


1;

=head1 DESCRIPTION

This role is used to load a Glade file into the C<builder> attribute.

This role can be combined with L<Renard::Curie::Component::Role::UIFileFromPackageName>
so that the contents of the C<ui_file> attribute are automatically populated
based on the package that the role is being included in.

=cut
