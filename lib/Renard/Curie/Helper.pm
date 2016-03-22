use Modern::Perl;
package Renard::Curie::Helper;

use Class::Method::Modifiers;

sub import {
	if( not Gtk3::CHECK_VERSION('3', '8', '0') ) {
		# For versions of Gtk+ less than v3.8.0, we need to call
		# `Gtk3::ScrolledWindow->add_with_viewport( ... )` so that the
		# child widget gets placed in a viewport.
		#
		# Newer versions of Gtk+ automatically create the viewport when
		# `Gtk3::ScrolledWindow->add( ... )` is called.
		#
		# See:
		# - <https://developer.gnome.org/gtk3/3.6/GtkScrolledWindow.html>
		# - <https://developer.gnome.org/gtk3/3.8/GtkScrolledWindow.html>
		Class::Method::Modifiers::install_modifier
			"Gtk3::ScrolledWindow",
			around => add => sub {
				my $orig = shift;
				my $self = shift;
				$self->add_with_viewport(@_);
			};
	}

}

sub gval ($$) { ## no critic
	# GValue wrapper shortcut
	Glib::Object::Introspection::GValueWrapper->new('Glib::'.ucfirst($_[0]) => $_[1])
}

sub genum {
	Glib::Object::Introspection->convert_sv_to_enum($_[0], $_[1])
}

1;
