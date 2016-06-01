use Modern::Perl;
package Renard::Curie::Helper;

use Class::Method::Modifiers;
use Gtk3;

sub import {
	# Note: The code below is marked as uncoverable because it only applies
	# to a single version of GTK+ and thus is not part of the general
	# coverage. The functionality that it adds is tested in other ways.
	# uncoverable branch true
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
				# uncoverable subroutine
				my $orig = shift;             # uncoverable statement
				my $self = shift;             # uncoverable statement
				$self->add_with_viewport(@_); # uncoverable statement
			};                                    # uncoverable statement
	}

}

sub gval ($$) { ## no critic
	# GValue wrapper shortcut
	Glib::Object::Introspection::GValueWrapper->new('Glib::'.ucfirst($_[1]) => $_[2])
}

sub genum {
	Glib::Object::Introspection->convert_sv_to_enum($_[1], $_[2])
}

1;
