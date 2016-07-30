use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::TTSWindow;
# ABSTRACT: Component used to control speech synthesis

use Moo;
use Function::Parameters;
use Speech::Synthesis;
use Renard::Incunabula::Language::EN;
use List::AllUtils qw(first);
use IO::Async::Function;

has playing => (
	is => 'rw',
	default => sub { 0 },
);

has synth_param => (
	is => 'lazy', # _build_synth_param
);

has synth_function => (
	is => 'lazy',
);

method BUILD(@) {
	$self->builder->get_object('tts-window')
		->signal_connect(
			'delete-event'
			# TODO do nothing for now
			=> sub { undef; } );
	$self->builder->get_object('button-play')
		->signal_connect(
			clicked =>
			\&on_clicked_button_play_cb, $self );
	$self->builder->get_object('button-next')
		->signal_connect(
			clicked =>
			\&on_clicked_button_next_cb, $self );
	$self->builder->get_object('button-previous')
		->signal_connect(
			clicked =>
			\&on_clicked_button_previous_cb, $self );

	$self->builder->get_object('tts-window')->show_all;
	$self->app->loop->add( $self->synth_function );
}

method speak( $text ) {
	$self->synth->speak($text);
}

callback on_clicked_button_play_cb( $button, $self ) {
	$self->playing( ! $self->playing );
	$self->builder->get_object('button-play')
		->set_label(
			  $self->playing
			? 'gtk-media-pause'
			: 'gtk-media-play'
		);
	$self->update;
}

method update() {
	return unless defined $self->app->page_document_component;
	my $page_doc = $self->app->page_document_component;
	my $text = $page_doc->current_text_page;
	$self->builder->get_object('label-sentence-count')
		->set_text(
			"@{[ @$text == 0 ? 0 : $page_doc->current_sentence_number + 1 ]} / @{[ scalar @$text ]}"
		);
	my $current_sentence_text =
		$text->[$page_doc->current_sentence_number]{sentence} // '';
	$self->builder->get_object('tts-text')
		->get_buffer
		->set_text($current_sentence_text);
	if( $self->playing && @$text > 0 ) {
		# NOTE This error occurs if you send UTF-8:
		# ***   Wide character in syswrite at .../Festival/Client/Async.pm line 127.

		my $preproc_tts = Renard::Incunabula::Language::EN::preprocess_for_tts(
			"" . $current_sentence_text
		);
		$self->synth_function->call(
			args => [
				$self->synth_param,
				$preproc_tts,
			],
			on_result => sub {
				Glib::Timeout->add(0, sub {
					$self->choose_next_sentence;
					return 0;
				});
			},
		);
	}
}

method num_of_sentences_on_page() {
	my $page_doc = $self->app->page_document_component;
	my $text = $page_doc->current_text_page;
	return @{ $text };
}

callback on_clicked_button_previous_cb( $button, $self ) {
	$self->choose_previous_sentence;
}

callback on_clicked_button_next_cb( $button, $self ) {
	$self->choose_next_sentence;
}

method choose_previous_sentence() {
	my $page_doc = $self->app->page_document_component;
	if( $page_doc->current_sentence_number > 0 ) {
		$page_doc->current_sentence_number( $page_doc->current_sentence_number - 1 );
	} elsif( $page_doc->can_move_to_previous_page ) {
		$page_doc->set_current_page_back;
		$page_doc->current_sentence_number(
			$self->num_of_sentences_on_page - 1
		);
	}
}

method choose_next_sentence() {
	my $page_doc = $self->app->page_document_component;
	if( $page_doc->current_sentence_number < $self->num_of_sentences_on_page - 1 ) {
		$page_doc->current_sentence_number( $page_doc->current_sentence_number + 1 );
	} elsif( $page_doc->can_move_to_next_page ) {
		$page_doc->set_current_page_forward;
	}
}

sub _build_synth_param {
	# no $self : subprocess
	my $engine;
	my $preferred_voice_name;
	if( $^O eq 'linux' ) {
		$engine = 'Festival';
		$preferred_voice_name = 'nitech_us_awb_arctic_hts';
	} elsif( $^O eq 'darwin' ) {
		$engine = "MacSpeech";
	} elsif( $^O eq 'MSWin32' ) {
		$engine = 'SAPI5';
		$preferred_voice_name = 'Microsoft Zira Desktop';
	}
	my @voices = Speech::Synthesis->InstalledVoices(engine => $engine);
	my @avatars = Speech::Synthesis->InstalledAvatars(engine => $engine);
	my $voice = ( first {
		$_->{name} eq $preferred_voice_name
	} @voices ) // $voices[-1];
	my %params = (
		engine   => $engine,
		avatar   => undef,
		language => $voice->{language},
		voice    => $voice->{id},
		async    => 0
	);
	\%params;
}

sub _build_synth_function {
	# no $self : subprocess
	IO::Async::Function->new(
		code => sub {
			my ( $synth_param, $text ) = @_;
			Speech::Synthesis
				->new(%$synth_param)
				->speak($text);
		}
	);
}


with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName
	Renard::Curie::Component::Role::HasParentApp
);

1;
