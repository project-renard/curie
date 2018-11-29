use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::AccelMap;
# ABSTRACT: Set up the accelerator map (global keybindings)

use Moo;
use Renard::Incunabula::API::Gtk3::Helper;

=method BUILD

Constructor that sets up the keybindings for the default accelerator map.

=cut
method BUILD(@) {
	Gtk3::AccelMap::add_entry(
		'<Curie-Main>/File/Open',
		Gtk3::Gdk::KEY_O(),
		'control-mask'
	);

	Gtk3::AccelMap::add_entry(
		'<Curie-Main>/File/Quit',
		Gtk3::Gdk::KEY_Q(),
		'control-mask'
	);

	Gtk3::AccelMap::add_entry(
		'<Curie-Main>/View/Sidebar',
		Gtk3::Gdk::KEY_F9(),
		'release-mask'
	);
}

1;
