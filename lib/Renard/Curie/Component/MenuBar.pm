use Modern::Perl;
package Renard::Curie::Component::MenuBar;

use Moo;
use Glib::Object::Subclass 'Gtk3::Bin';


sub BUILD {
	my ($self) = @_;

	$self->builder->get_object('menu-item-file-open')
		->signal_connect( activate => \&open_activated_cb );
	$self->builder->get_object('menu-item-file-quit')
		->signal_connect( activate => \&quit_activated_cb );

	# add as child for this Gtk3::Bin
	$self->add(
		$self->builder->get_object('menubar')
	);
}

with qw(
	Renard::Curie::Component::Role::FromBuilder
	Renard::Curie::Component::Role::UIFileFromPackageName
);

1;
