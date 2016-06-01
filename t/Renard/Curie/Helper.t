use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;
use Modern::Perl;

use Try::Tiny;
use Renard::Curie::Helper;

subtest "Use helper functions" => sub {
	my $val = Renard::Curie::Helper->gval(int => 512);
	isa_ok( $val, 'Glib::Object::Introspection::GValueWrapper' );

	my $enum = Renard::Curie::Helper->genum(
		'Gtk3::PackType' => 'GTK_PACK_START' );
	is( $enum, 0 );
};
