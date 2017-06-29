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

	my $cpage = Renard::Curie::Model::View::ContinuousPage->new(
		document => Renard::Curie::Model::Document::PDF->new( filename => $pdf_ref_path )
	);

	my $c = CurieTestHelper->get_app_container;
	my $app = $c->app;
	$c->view_manager->current_view( $cpage );
	$c->main_window->page_document_component(
		Renard::Curie::Component::PageDrawingArea->new(
			view_manager => $c->view_manager,
		)
	);
	$c->main_window->window->show_all;

	Glib::Timeout->add(100, sub {
		$cpage->zoom_level(1.1);
		$cpage->page_number(2);

		CurieTestHelper->refresh_gui;

		$c->main_window->window->destroy;

		pass;
	});

	$app->main;
};

done_testing;
