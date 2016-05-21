use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;

use Try::Tiny;
use Renard::Curie::App;

subtest "Process arguments" => sub {
	my $pdf_ref_path = try {
		CurieTestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
	} catch {
		plan skip_all => "$_";
	};
	local @ARGV = ($pdf_ref_path);
	my $app = Renard::Curie::App->new;
	$app->process_arguments;
	like $app->window->get_title, qr/\Q$pdf_ref_path\E/, "Window title contains path to file";
}

