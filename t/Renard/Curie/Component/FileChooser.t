use Test::Most tests => 3;

use lib 't/lib';
use CurieTestHelper;

use Modern::Perl;
use Renard::Curie::App;
use Renard::Curie::Component::FileChooser;
use Try::Tiny;
use Test::MockModule;

subtest 'Check that the open file dialog with filters is created' => sub {
	my $app = Renard::Curie::App->new;
	my $file_chooser = Renard::Curie::Component::FileChooser->new( app => $app );

	my $dialog = $file_chooser->get_open_file_dialog_with_filters;

	is $dialog->get_title, 'Open File', 'Dialog has the right title';

	my $filters = $dialog->list_filters;
	my @filters_names = map { $_->get_name } @$filters;

	cmp_deeply(\@filters_names, bag('All files', 'PDF files'),
		'Has expected filters' );
};

subtest "Menu: File -> Open" => sub {
	my $pdf_ref_path = try {
		CurieTestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
	} catch {
		plan skip_all => "$_";
	};
		
	my $fc = Test::MockModule->new('Gtk3::FileChooserDialog', no_auto => 1);
	my ($got_file, $destroyed) = (0, 0);
	$fc->mock( get_filename => sub { $got_file = 1; "$pdf_ref_path" } );
	$fc->mock( destroy => sub { $destroyed = 1 } );

	subtest "Accept dialog" => sub {
		($got_file, $destroyed) = (0, 0);
		$fc->mock( run => 'accept' );

		my $app = Renard::Curie::App->new;
		$app->menu_bar->on_menu_file_open_activate_cb;

		ok( $got_file, "Callback retrieved the filename");
		ok( $destroyed, "Callback destroyed the dialog");
	};

	subtest "Cancel dialog" => sub {
		($got_file, $destroyed) = (0, 0);
		$fc->mock( run => 'cancel' );

		my $app = Renard::Curie::App->new;
		$app->menu_bar->on_menu_file_open_activate_cb;
		ok(!$got_file, "Callback did not retrieve the filename");
		ok( $destroyed, "Callback destroyed the dialog");
	};
};

subtest "Menu: File -> Quit" => sub {
	my $app = Renard::Curie::App->new;

	Glib::Timeout->add(100, sub {
		cmp_ok( Gtk3::main_level, '>', 0, 'Main loop is running');
		$app->menu_bar->builder
			->get_object('menu-item-file-quit')
			->signal_emit('activate');
	});

	$app->run;

	is( Gtk3::main_level, 0, 'Main loop is no longer running');
};
