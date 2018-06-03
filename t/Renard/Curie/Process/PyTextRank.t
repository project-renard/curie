#!/usr/bin/env perl

use Test::Most tests => 1;
use Renard::Incunabula::Common::Setup;
use Renard::Incunabula::Format::PDF::Devel::TestHelper;

use Renard::Curie::Document;
use Renard::Curie::Process::PyTextRank;
use Test::DBIx::Class qw(:resultsets);

subtest "Process pytextrank" => sub {
	my $pdf_ref_path = try {
		Renard::Incunabula::Format::PDF::Devel::TestHelper->pdf_reference_document_path;
	} catch {
		plan skip_all => "$_";
	};

	my $doc = Renard::Curie::Document->new( filename => $pdf_ref_path );

	$doc->process_pytextrank( Schema, page_range => [ 33, 46 ] ); # [ 33, 46 ], [ 33, 35 ]

	my $doc_r = $doc->get_schema_result( Schema );

	ok $doc_r->processed_doc_pytextrank->processed, 'document has been processed';

	my $phrase = 'imaging model';
	my $pytextrank_phrase = $doc_r->processed_doc_pytextrank->pytextrank_data->search({ text => $phrase })->first;

	is_fields [qw/text pos/], $pytextrank_phrase, {
		text => $phrase,
		pos => 'np',
	};

	my $phrase_cloze_rs = $pytextrank_phrase->pytextrank_cloze_rs->related_resultset('phrase_cloze_id');
	ok $phrase_cloze_rs->search( { page => 34 })->first, 'phrase is on expected page';
};

done_testing;
