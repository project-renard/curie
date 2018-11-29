#!/usr/bin/env perl

use Test::Most;

use lib 't/lib';
use CurieTestHelper;
use Renard::Incunabula::Block::Format::PDF::Devel::TestHelper;

use Renard::Incunabula::Common::Setup;
use Renard::Curie::Component::DocumentPropertiesWindow;
use Renard::Incunabula::Block::Format::PDF::Document;

my $pdf_ref_path = try {
	Renard::Incunabula::Block::Format::PDF::Devel::TestHelper->pdf_reference_document_path;
} catch {
	plan skip_all => "$_";
};

plan tests => 1;

subtest "Document properties window" => sub {
	my $doc = Renard::Incunabula::Block::Format::PDF::Devel::TestHelper->pdf_reference_document_object;

	my $prop_window = Renard::Curie::Component::DocumentPropertiesWindow->new(
		document => $doc,
	);

	my $grid = $prop_window->builder->get_object('prop-grid');
	my $def_properties = $prop_window->_pdf_information_dictionary->default_properties;

	my @children = $grid->get_children;
	is scalar @children, 2 * (scalar @$def_properties), 'expected number of children';
};

done_testing;
