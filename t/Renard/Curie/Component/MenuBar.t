use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;

use Modern::Perl;
use List::AllUtils qw(first);

subtest 'Check that the menu item File -> Open exists' => sub {
	require Renard::Curie::App;
	my $app = Renard::Curie::App->new;

	my $menu_bar = $app->menu_bar->get_child;
	my @toplevel = $menu_bar->get_children;
	my $file_menu = first {
		$_->get_property('label') eq '_File'
	} @toplevel;
	my $file_submenu = $file_menu->get_submenu;
	my @file_submenu_labels = map {
		$_->get_property('label')
	} $file_submenu->get_children;

	cmp_deeply(\@file_submenu_labels, supersetof('gtk-open'),
		'File -> Open menu item exists' );
};
