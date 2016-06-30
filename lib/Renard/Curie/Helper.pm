use Renard::Curie::Setup;
package Renard::Curie::Helper;

use Class::Method::Modifiers;
use Gtk3;
use Function::Parameters;

fun import {
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
			around => add => fun {
				# uncoverable subroutine
				my $orig = shift;             # uncoverable statement
				my $self = shift;             # uncoverable statement
				$self->add_with_viewport(@_); # uncoverable statement
			};                                    # uncoverable statement
	}

	return;
}

# Note: :prototype($$) would help here, but is only possible on Perl v5.20+
classmethod gval( $glib_typename, $value ) { ## no critic
	# GValue wrapper shortcut
	Glib::Object::Introspection::GValueWrapper->new('Glib::'.ucfirst($glib_typename) => $value);
}

classmethod genum( $package, $sv ) {
	Glib::Object::Introspection->convert_sv_to_enum($package, $sv);
}

classmethod callback( $invocant, $callback_name, @args ) {
	my $fun = $invocant->can( $callback_name );
	$fun->( @args, $invocant );
}

1;
