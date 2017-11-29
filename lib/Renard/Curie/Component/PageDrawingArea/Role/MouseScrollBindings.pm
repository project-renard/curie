use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::MouseScrollBindings;
# ABSTRACT: A role to setup the bindings for mouse wheel scrolling for a page drawing area

use Moo::Role;

after BUILD => method(@) {
	$self->setup_scroll_bindings;
};

=method setup_scroll_bindings

  method setup_scroll_bindings()

Sets up the signals to capture scroll events on this component.

=cut
method setup_scroll_bindings() {
	$self->scrolled_window->signal_connect(
		'scroll-event' => \&on_scroll_event_cb, $self );
}

=callback on_scroll_event_cb

  callback on_scroll_event_cb($window, $event, $self)

Callback that responds to specific scroll events and dispatches the associated
handlers.

=cut
callback on_scroll_event_cb($window, $event, $self) {
	if ( $event->state == 'control-mask' && $event->direction eq 'smooth') {
		my ($delta_x, $delta_y) =  $event->get_scroll_deltas();
		if ( $delta_y < 0 ) { $self->view_manager->set_zoom_level( $self->view->zoom_level - .05 ); }
		elsif ( $delta_y > 0 ) { $self->view_manager->set_zoom_level( $self->view->zoom_level + .05 ); }
		return 1;
	} elsif ( $event->state == 'control-mask' && $event->direction eq 'up' ) {
		$self->view_manager->set_zoom_level( $self->view->zoom_level + .05 );
		return 1;
	} elsif ( $event->state == 'control-mask' && $event->direction eq 'down' ) {
		$self->view_manager->set_zoom_level( $self->view->zoom_level - .05 );
		return 1;
	}
	return 0;
}

1;
