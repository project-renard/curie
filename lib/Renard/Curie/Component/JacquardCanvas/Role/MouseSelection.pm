use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::JacquardCanvas::Role::MouseSelection;
# ABSTRACT: Role for selecting text

use Role::Tiny;
use Renard::API::Gtk3::Helper;
use Glib qw(TRUE FALSE);
use Renard::Yarn::Types qw(Point Size);

after set_data => sub {
	my ($self, %data) = @_;

	$self->{selection}{state} = 0;
};

sub mark_selection_start {
	my ($self, $event_point) = @_;

	my $pointer_data = $self->_get_data_for_pointer($event_point);
	my $text_data = $self->_get_text_data_for_pointer( $pointer_data );
	$self->{selection}{start} = { pointer => $pointer_data, text => $text_data };
	$self->{selection}{end} = $self->{selection}{start};
}

sub mark_selection_end {
	my ($self, $event_point) = @_;

	my $pointer_data = $self->_get_data_for_pointer($event_point);
	my $text_data = $self->_get_text_data_for_pointer( $pointer_data );
	$self->{selection}{end} = { pointer => $pointer_data, text => $text_data };
	$self->queue_draw;
}

sub clear_selection {
	my ($self) = @_;
	$self->{selection}{state} = 0;
}

after cb_on_motion_notify_button1 => sub {
	my ($widget, $event, $self) = @_;

	if( $event->state & 'button1-mask' ) {
		#say "Continuing selection";
		my $event_point = Point->coerce([ $event->x, $event->y ]);
		$self->mark_selection_end($event_point);
		$self->{selection}{state} = 1;
	}

	return TRUE;
};

after cb_on_button_press_event => sub {
	my ($widget, $event, $self) = @_;

	if( $event->button == Gtk3::Gdk::BUTTON_PRIMARY ) {
		#say "Start selection";
		my $event_point = Point->coerce([ $event->x, $event->y ]);
		$self->mark_selection_start($event_point);
		$self->{selection}{state} = 1;
	}

	return TRUE;
};

after cb_on_button_release_event => sub {
	my ($widget, $event, $self) = @_;

	if( $event->state & 'button1-mask' ) {
		#say "End selection";
		my $event_point = Point->coerce([ $event->x, $event->y ]);
		if( $self->{selection}{state} == 2 ) {
			$self->clear_selection;
		} else {
			$self->mark_selection_end($event_point);
			$self->{selection}{state} = 2;
		}
	}

	return TRUE;
};

1;
