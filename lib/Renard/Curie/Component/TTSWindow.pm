use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::TTSWindow;
# ABSTRACT: Component used to control speech synthesis

use Moo;
use Module::Load;
use Renard::Block::NLP;
use Renard::Incunabula::Common::Types qw(InstanceOf Bool Str);
use List::AllUtils qw(first);
use IO::Async::Function;
use Try::Tiny;

use Pango;

=attr view_manager

The view manager model for this application.

=cut
has view_manager => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::ViewModel::ViewManager'],
	handles => {
		view => current_view =>,
	},
);

has synth_param => (
	is => 'lazy', # _build_synth_param
);

has synth_function => (
	is => 'lazy',
);

=classmethod can_load_speech_synthesis

Returns true if the system can load Speech::Synthesis.

=cut
classmethod can_load_speech_synthesis() {
	if($^O eq 'linux') {
		return try {
			load 'Speech::Synthesis';
			1;
		} catch {
			0;
		};
	}

	return 0;
}

=method BUILD

Constructor that sets up the TTS window and its buttons.

=cut
method BUILD(@) {
	return unless $self->can_load_speech_synthesis;

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

	$self->builder->get_object('tts-text')
		->modify_font(Pango::FontDescription->from_string('Monospace 32'));

}

=method show_all

Show the TTS window.

=cut
method show_all() {
	return unless $self->can_load_speech_synthesis;

	$self->builder->get_object('tts-window')->show_all;
}

=method speak

  method speak( (Str) $text )

Say the contents of C<$str>.

=cut
method speak( (Str) $text ) { # uncoverable subroutine
	$self->synth->speak($text); # uncoverable statement
}

=callback on_clicked_button_play_cb

   callback on_clicked_button_play_cb( $button, $self )

Callback that toggles between play and pause states.

=cut
callback on_clicked_button_play_cb( $button, $self ) {
	$self->view_manager->tts_playing( ! $self->view_manager->tts_playing );
	$self->builder->get_object('button-play')
		->set_label(
			$self->view_manager->tts_playing
			? 'gtk-media-pause'
			: 'gtk-media-play'
		);
	$self->update;
}

=method update

  method update()

Updates the TTS window.

This sets the sentence label, sentence text, and plays the text if L<ViewManager::tts_playing> is true.

=cut
method update() {
	return unless defined $self->view_manager->current_document;
	my $text = $self->view_manager->current_text_page;
	$self->builder->get_object('label-sentence-count')
		->set_text(
			"@{[ @$text == 0 ? 0 : $self->view_manager->current_sentence_number + 1 ]} / @{[ scalar @$text ]}"
		);
	my $current_sentence_text =
		$text->[$self->view_manager->current_sentence_number]{sentence} // '';
	$self->builder->get_object('tts-text')
		->get_buffer
		->set_text($current_sentence_text);
	if( $self->view_manager->tts_playing && @$text > 0 ) {
		# NOTE This error occurs if you send UTF-8:
		# ***   Wide character in syswrite at .../Festival/Client/Async.pm line 127.

		my $preproc_tts = Renard::Block::NLP::preprocess_for_tts(
			"" . $current_sentence_text
		);
		$self->synth_function->call(
			args => [
				$self->synth_param,
				$preproc_tts,
			],
			on_result => sub {
				Glib::Timeout->add(0, sub {
					$self->view_manager->choose_next_sentence;
					$self->update;
					return 0;
				});
			},
		);
	}
}

=callback on_clicked_button_previous_cb

  callback on_clicked_button_previous_cb( $button, $self )

Calls L<ViewManager::choose_previous_sentence>.

=cut
callback on_clicked_button_previous_cb( $button, $self ) {
	$self->view_manager->choose_previous_sentence;
	$self->update;
}

=callback on_clicked_button_next_cb

  callback on_clicked_button_next_cb( $button, $self )

Calls L<ViewManager::choose_next_sentence>.

=cut
callback on_clicked_button_next_cb( $button, $self ) {
	$self->view_manager->choose_next_sentence;
	$self->update;
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
	Intertangle::API::Gtk3::Component::Role::FromBuilder
	Intertangle::API::Gtk3::Component::Role::UIFileFromPackageName
	Renard::Curie::Component::Role::HasParentMainWindow
);

1;
