use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;

use Modern::Perl;
use Renard::Curie::Model::Document::CairoImageSurface;


subtest pdf_ref => sub {
	my $cairo_doc = CurieTestHelper->create_cairo_document;

	ok( $cairo_doc, "PDF document object created successfully" );

	is( $cairo_doc->first_page_number, 1, "First page number is correct" );

	is( $cairo_doc->last_page_number, 4, "Last page number is correct" );

	my $first_page = $cairo_doc->get_rendered_page( page_number => 1 );
	is  $first_page->width, 5000, "Check width of first page";
	is  $first_page->height, 5000, "Check height of first page";
};


done_testing;
