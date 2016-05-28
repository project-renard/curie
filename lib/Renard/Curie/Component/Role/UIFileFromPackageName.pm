use Modern::Perl;
package Renard::Curie::Component::Role::UIFileFromPackageName;
# ABSTRACT: Role to obtain name of Glade UI file from the name of the package

use Moo::Role;

use File::Spec;
use File::Basename;
use Module::Util qw(:all);

=attr ui_file

A C<Str> that contains the path to a Glade UI file that resides in the same
directory as the C<.pm> file for the package that this role is used with.

For example, given a package C<Foo::Bar> from the file C<lib/Foo/Bar.pm>, the
contents of C<ui_file> will be C<lib/Foo/Bar.glade>.

See the C<ui_file> attribute in L<Renard::Curie::Component::Role::FromBuilder>.

=cut
has ui_file => ( is => 'ro', default => sub {
		my ($self) = @_;
		my $module_name = ref $self;
		my $package_last_component = (split(/::/, $module_name))[-1];
		my $module_file = find_installed($module_name);
		File::Spec->catfile(dirname($module_file), "@{[ $package_last_component ]}.glade")
	} );

1;

=head1 DESCRIPTION

See the description of the attribute C<ui_file> for more information.

=cut
