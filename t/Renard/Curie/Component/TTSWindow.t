#!/usr/bin/env perl

use Test::Most;

use lib 't/lib';
use Renard::Incunabula::Devel::TestHelper;
use Renard::Curie::App;
use CurieTestHelper;

my $pdf_ref_path = try {
	Renard::Incunabula::Devel::TestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
} catch {
	plan skip_all => "$_";
};

plan tests => 3;

# Mock TTS engine and loop
use Test::MockModule;
use Test::MockObject;
my $mock_synth = Test::MockModule->new('Renard::Curie::Component::TTSWindow');
my $mock_loop = Test::MockModule->new('IO::Async::Loop');
$mock_loop->mock( add => sub {} );
$mock_synth->mock( speak => sub { } );
$mock_synth->mock( _build_synth_function => sub {
		my $mock = Test::MockObject->new();
		$mock->set_true( 'call' );
		$mock;
	}
);

subtest "Synth param" => sub {
	my $c = CurieTestHelper->get_app_container;
	my $app = $c->app;

	ok defined $c->tts_window->synth_param->{engine}, 'TTS engine is set';
};

subtest "Toggle play" => sub {
	my $c = CurieTestHelper->get_app_container;
	my $app = $c->app;
	$c->tts_window;

	is $c->tts_window->playing, 0, 'not playing';

	$c->tts_window->builder->get_object('button-play')
		->signal_emit( clicked => );

	is $c->tts_window->playing, 1, 'playing';
};

subtest "Sentences" => sub {
	my $c = CurieTestHelper->get_app_container;
	my $app = $c->app;
	$c->view_manager->open_pdf_document( $pdf_ref_path );

	is $c->view_manager->current_view->page_number, 1, 'first page';
	is $c->tts_window->num_of_sentences_on_page, 6, 'there are 6 sentences on page 1';
	is $c->view_manager->current_sentence_number, 0, 'start on the first sentence';

	note 'Clicking next sentence button';
	for (0..5) {
		$c->tts_window->builder->get_object('button-next')
			->signal_emit( clicked => );
		note "Sentence number ". $c->view_manager->current_sentence_number;
	}

	is $c->view_manager->current_view->page_number, 2, 'now on next page';
	is $c->view_manager->current_sentence_number, 0, 'first sentence';

	note 'Clicking previous sentence button';
	$c->tts_window->builder->get_object('button-previous')
		->signal_emit( clicked => );

	is $c->view_manager->current_view->page_number, 1, 'first page';
	is $c->view_manager->current_sentence_number, 5, 'last sentence';
};

done_testing;
