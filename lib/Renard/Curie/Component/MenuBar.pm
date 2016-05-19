use Modern::Perl;
package Renard::Curie::Component::MenuBar;

use Moo;
use Glib::Object::Subclass 'Gtk3::Bin';

has app => ( is => 'ro', required => 1, weak_ref => 1 );

sub FOREIGNBUILDARGS {
	my ($class, %args) = @_;
	return ();
}

sub BUILD {
	my ($self) = @_;

	$self->builder->get_object('menu-item-file-open')
		->signal_connect( activate =>
			sub {
				my ($event, $self) = @_;
				$self->on_menu_file_open_activate_cb($event);
			}, $self );
	$self->builder->get_object('menu-item-file-quit')
		->signal_connect( activate =>
			sub {
				my ($event, $self) = @_;
				$self->on_menu_file_quit_activate_cb($event);
			}, $self );

	# add as child for this Gtk3::Bin
	$self->add(
		$self->builder->get_object('menubar')
	);
}


# Callbacks {{{
sub on_menu_file_open_activate_cb {
	my ($self, $event) = @_;
	$self->app->on_open_file_cb($event);
}

sub on_menu_file_quit_activate_cb {
	my ($self, $event) = @_;
	$self->app->on_application_quit_cb($event);
}
# }}}


with qw(
	Renard::Curie::Component::Role::FromBuilder
	Renard::Curie::Component::Role::UIFileFromPackageName
);

1;
