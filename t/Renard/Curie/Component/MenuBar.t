use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;

use Modern::Perl;
use List::AllUtils qw(first);

my $cairo_doc = CurieTestHelper->create_cairo_document;

subtest 'Check that the menu item File -> Open exists' => CurieTestHelper->run_app_with_document($cairo_doc, sub {
	my ( $app ) = @_;

	Glib::Timeout->add(100, sub {
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

		$app->window->destroy;
	});
});
