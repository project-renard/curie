use Modern::Perl;
package Renard::Curie::Helper;

sub gval ($$) { ## no critic
	# GValue wrapper shortcut
	Glib::Object::Introspection::GValueWrapper->new('Glib::'.ucfirst($_[0]) => $_[1])
}

sub genum {
	Glib::Object::Introspection->convert_sv_to_enum($_[0], $_[1])
}

