#!/usr/bin/env perl

use Test::Most tests => 1;

use lib 't/lib';
use CurieTestHelper;

use Renard::Curie::Setup;
use Renard::Curie::App;
use Renard::Curie::Model::View::ContinuousPage;
use Renard::Curie::Model::Document::PDF;

subtest "Continuous page" => sub {
	my $pdf_ref_path = try {
		CurieTestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
	} catch {
		plan skip_all => "$_";
	};
	plan tests => 1;

	my $c = Renard::Curie::Model::View::ContinuousPage->new(
		document => Renard::Curie::Model::Document::PDF->new( filename => $pdf_ref_path )
	);

	my $app = Renard::Curie::App->new;
	$app->page_document_component(
		Renard::Curie::Component::PageDrawingArea->new(
			view => $c
		)
	);
	$app->window->show_all;

	Glib::Timeout->add(100, sub {
		$c->zoom_level(1.1);
		$c->page_number(2);

		CurieTestHelper->refresh_gui;

		$app->window->destroy;

		pass;
	});

	$app->main;
};

done_testing;
