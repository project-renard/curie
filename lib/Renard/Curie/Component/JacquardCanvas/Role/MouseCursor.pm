use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::JacquardCanvas::Role::MouseCursor;
# ABSTRACT: Role for changing cursor shape

use Role::Tiny;
use Glib qw(TRUE FALSE);

	sub _set_cursor_to_name {
		my ($self, $name) = @_;
		$self->get_window->set_cursor(
			Gtk3::Gdk::Cursor->new_from_name($self->get_display, $name)
		);
	}

	after do_pointer_data => sub {
		my ($self, $event_point, $pointer_data, $text_data ) = @_;

		if( defined $text_data ) {
			if( @$text_data ) {
				my $block = $text_data->[0];
				$self->{text}{substr} = $block->{extent}->substr;
				$self->{text}{data} = $block;

				$self->{text}{layers} = $text_data;

				if( $text_data->[-1]{tag} eq 'char' ) {
					$self->_set_cursor_to_name('text');
				} else {
					$self->_set_cursor_to_name('default');
				}

				$self->signal_emit( 'text-found' );
			} else {
				delete $self->{text};
				$self->_set_cursor_to_name('default');
			}
			$self->queue_draw;
		}

		return TRUE;
	};

1;
