use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::ActionNotebookWindow;

use Moo;
use Renard::Incunabula::Common::Types qw(Str);
use Glib qw(TRUE FALSE);
use MooX::Lsub;

lsub notebook => method() {
	$self->builder->get_object('action-notebook');
};

method BUILD(@) {
	my $window = $self->builder->get_object('action-notebook-window');
	$window->set_title('Action!');
	$window->set_default_size(600, 600);
}

method append_notebook_tab( (Str) $name, $widget ) {
	$self->notebook->append_page(
		$widget,
		Gtk3::Label->new( $name ),
	);
}

=method show_all

Show the action notebook window.

=cut
method show_all() {
	$self->builder->get_object('action-notebook-window')->show_all;
}


with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName
	Renard::Curie::Component::Role::HasParentMainWindow
);

1;
