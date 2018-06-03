#!/usr/bin/env perl

use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;

use Renard::Incunabula::Format::PDF::Document;
use Renard::Incunabula::Format::PDF::Devel::TestHelper;
use List::AllUtils qw(first);

subtest "Text page" => sub {
	my $pdf_ref_path = try {
		Renard::Incunabula::Format::PDF::Devel::TestHelper->pdf_reference_document_path;
	} catch {
		plan skip_all => "$_";
	};

	my $c = CurieTestHelper->get_app_container;
	my $app = $c->app;

	my $view_manager = $c->view_manager;
	my $doc = Renard::Incunabula::Format::PDF::Devel::TestHelper->pdf_reference_document_object;
	$view_manager->current_document( $doc );

	$view_manager->current_view->page_number( 23 );

	my $target_str = q|It includes the precise documentation of the underlying imaging model from Post-Script along with the PDF-specific features that are combined in version 1.7 of the PDF standard.|;
	my $text = $view_manager->current_text_page;
	my $target_text = first {
		$_->{sentence}->str eq $target_str
	} @$text;
	ok $target_text, 'Found the target text';
	is scalar @{ $target_text->{spans} }, 4, 'Sentence is spread across 4 lines';
};

done_testing;
