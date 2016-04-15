use Modern::Perl;
package Renard::Curie::Plugin::AbiWord;

use Glib::Object::Introspection;

sub import {
	Glib::Object::Introspection->setup(
		basename => 'Abi',
		version => '3.0',
		package => 'AbiWord', );
	AbiWord::init_noargs( );
}

END {
	AbiWord::shutdown( );
}

1;
