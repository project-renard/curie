use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::LogWindow;
# ABSTRACT: Component that collects log messages

use Moo;
use Renard::API::Gtk3::Helper;
use MooX::HandlesVia;
use Glib 'TRUE', 'FALSE';
use Renard::Incunabula::Common::Types qw(ArrayRef HashRef Str);

=attr log_messages

An C<ArrayRef[HashRef]> of log messages where each item has the keys

=for :list
* C<category>
* C<level>
* C<message>

See the L</log> method for more details.

=cut
has log_messages => (
	is => 'rw',
	handles_via => 'Array',
	isa => ArrayRef[HashRef],
	clearer => 1,
	handles => {
		add_log => 'push',
	},
	default => sub { [] },
);

=method BUILD

  method BUILD

Initialises the logging window.

=cut
method BUILD(@) {
	my $log_textview = $self->builder->get_object('log-text');
	if( $log_textview->can('set_monospace') ) {
		$log_textview->set_monospace(TRUE);
	} else {
		warn('Gtk3::TextView monospace property not available for Gtk+ < v3.16.');
	}
	$self->builder->get_object('log-window')
		->signal_connect(
			'delete-event'
			# Gtk3::Widget::hide_on_delete
			=> sub { shift->hide_on_delete } );
	$self->builder->get_object('button-clear')
		->signal_connect(
			clicked =>
			\&on_clicked_button_clear_cb, $self );
}

=method show_log_window

  method show_log_window()

Displays the hidden logging window.

=cut
method show_log_window() {
	$self->builder->get_object('log-window')->show_all;
}

=method log

  method log( (Str) :$category, (Str) :$level, (Str) :$message )

Called by the L<Renard::Curie::Log::Any::Adapter::LogWindow> adapter to send
logging messages to this component.

=for :list
* C<$category> is category for the log message (e.g, which package generated it).
* C<$level> is the severity of the message (e.g., info, warning, debug).
* C<$message> is the message itself.

=cut
method log( (Str) :$category, (Str) :$level, (Str) :$message ) {
	$self->add_log( {
		category => $category,
		level => $level,
		message => $message } );

	my $buffer = $self->builder->get_object('log-text')->get_buffer;
	$buffer->insert( $buffer->get_end_iter,
		sprintf("[%s] {%s} %s\n", $level, $category, $message ) );

	$self->_scroll_log_textview_to_end;
}

=method _scroll_log_textview_to_end

  method _scroll_log_textview_to_end()

Scrolls the text view of logging messages to the end so that the last message
is visible.

=cut
method _scroll_log_textview_to_end() {
	my $text_view = $self->builder->get_object('log-text');
	my $buffer = $text_view->get_buffer;

	my $end_iter = $buffer->get_end_iter;
	my $insert_mark = $buffer->get_insert;

	# move the mark and selection to the end
	$buffer->place_cursor($end_iter);

	#  scroll the view to the end
	$text_view->scroll_to_mark( $insert_mark, 0.0, TRUE, 0.0, 1.0);
}

=callback on_clicked_button_clear_cb

  callback on_clicked_button_clear_cb( $event, $self )

Callback for when the Clear button is clicked. This clears the log message text
view.

=cut
callback on_clicked_button_clear_cb( $event, $self ) {
	$self->log_messages([]);
	my $buffer = $self->builder->get_object('log-text')->get_buffer;
	$buffer->set_text("", 0);
}

with qw(
	Renard::API::Gtk3::Component::Role::FromBuilder
	Renard::API::Gtk3::Component::Role::UIFileFromPackageName
);

1;
