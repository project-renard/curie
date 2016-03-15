use Test::Most tests => 1;

use Path::Tiny;
use Renard::Curie::Model::PDFDocument;

my $pdf_ref_path = path( $ENV{RENARD_TEST_DATA_PATH}, qw(PDF Adobe pdf_reference_1-7.pdf) );

subtest pdf_ref => sub {
	my $pdf_doc = Renard::Curie::Model::PDFDocument->new(
		filename => $pdf_ref_path
	);

	ok( $pdf_doc, "PDF document object created successfully" );

	is( $pdf_doc->first_page_number, 1, "First page number is correct" );

	is( $pdf_doc->last_page_number, 1310, "Last page number is correct" );
};


done_testing;
