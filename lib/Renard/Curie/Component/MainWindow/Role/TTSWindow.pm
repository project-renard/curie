use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::MainWindow::Role::TTSWindow;
# ABSTRACT: Role for TTS window

use Moo::Role;
use Renard::Curie::Component::Outline;
use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Incunabula::Document::Types qw(DocumentModel);

use Glib 'TRUE', 'FALSE';

requires 'content_box';

=attr tts_window

A L<Renard::Curie::Component::TTSWindow>.

=cut
has tts_window => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Component::TTSWindow'],
);

after setup_window => method() {
	if( $^O ne 'MSWin32' ) {
		$self->tts_window->show_all;
		$self->loop->add( $self->tts_window->synth_function );
	}
};

1;
