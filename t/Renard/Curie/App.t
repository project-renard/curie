use Test::Most tests => 3;

use lib 't/lib';
use CurieTestHelper;

use Try::Tiny;
use Renard::Curie::App;
use File::Temp;

subtest "Process arguments" => sub {
	subtest "Process arguments for PDF file" => sub {
		my $pdf_ref_path = try {
			CurieTestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
		} catch {
			plan skip_all => "$_";
		};
		local @ARGV = ($pdf_ref_path);
		my $app = Renard::Curie::App->new;
		$app->process_arguments;
		like $app->window->get_title, qr/\Q$pdf_ref_path\E/, "Window title contains path to file";
	};

	subtest "Process no arguments" => sub {
		my $app = Renard::Curie::App->new;
		local @ARGV = ();
		lives_ok {
			$app->process_arguments;
		} 'Processes no arguments fine';
	};

	subtest "Process arguments for non-existent file" => sub {
		my $non_existent_filename = File::Temp::tmpnam();
		local @ARGV = ($non_existent_filename);
		my $app = Renard::Curie::App->new;
		throws_ok {
			$app->process_arguments;
		} 'Renard::Curie::Error::IO::FileNotFound', "Throws exception when file not found";
	};
};

subtest "Run app and destroy" => sub {
	my $app = Renard::Curie::App->new;

	Glib::Timeout->add(100, sub {
		cmp_ok( Gtk3::main_level, '>', 0, 'Main loop is running');
		$app->window->destroy;
	});

	$app->main;

	is( Gtk3::main_level, 0, 'Main loop is no longer running');
};

subtest "Open document twice" => sub {
	my $app = Renard::Curie::App->new;
	my $cairo_doc_a = CurieTestHelper->create_cairo_document;
	my $cairo_doc_b = CurieTestHelper->create_cairo_document;

	$app->open_document($cairo_doc_a);
	cmp_deeply $app->page_document_component->document, $cairo_doc_a, 'First document loaded';

	$app->open_document($cairo_doc_b);
	cmp_deeply $app->page_document_component->document, $cairo_doc_b, 'Second document loaded';
};
