#!/usr/bin/env perl

use Test::Most;

use lib 't/lib';
use CurieTestHelper;

use Renard::Curie::Setup;
use Renard::Curie::App;
use Function::Parameters;

my $pdf_ref_path = try {
	CurieTestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
} catch {
	plan skip_all => "$_";
};

plan tests => 1;

subtest 'Check that the outline model is set for the current document' => fun {
	my $app = Renard::Curie::App->new;
	$app->open_pdf_document( $pdf_ref_path );
	my $doc = $app->page_document_component->document;
	my $outline = $doc->outline;

	is( $app->outline->model, $outline->tree_store,
		"The outline component's model is set to the document's outline model");
};

done_testing;
