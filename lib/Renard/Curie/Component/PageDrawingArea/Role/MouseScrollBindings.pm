use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::MouseScrollBindings;
# ABSTRACT: A role to setup the bindings for mouse wheel scrolling for a page drawing area

use Moo::Role;

use Renard::Incunabula::Document::Types qw(ZoomLevel);
use List::AllUtils qw(max);

=attr MIN_ZOOM_LEVEL

A constant for the minimum zoom level possible so that the zoom level never
becomes negative.

=cut
use constant MIN_ZOOM_LEVEL => 0.001;

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
		if ( $delta_y < 0 ) { $self->view_manager->set_zoom_level( $self->compute_zoom_out($self->view->zoom_level)  ); }
		elsif ( $delta_y > 0 ) { $self->view_manager->set_zoom_level( $self->compute_zoom_in($self->view->zoom_level) ); }
		return 1;
	} elsif ( $event->state == 'control-mask' && $event->direction eq 'up' ) {
		$self->view_manager->set_zoom_level( $self->compute_zoom_in($self->view->zoom_level) );
		return 1;
	} elsif ( $event->state == 'control-mask' && $event->direction eq 'down' ) {
		$self->view_manager->set_zoom_level( $self->compute_zoom_out($self->view->zoom_level) );
		return 1;
	}
	return 0;
}

=method compute_zoom_out

  method compute_zoom_out( (ZoomLevel) $zoom_level, $amount = 0.05 )

Computes the new zoom level in order to zoom out.

=cut
method compute_zoom_out( (ZoomLevel) $zoom_level, $amount = 0.05 ) {
	return max(MIN_ZOOM_LEVEL, $zoom_level - $amount);
}

=method compute_zoom_in

  method compute_zoom_in( (ZoomLevel) $zoom_level, $amount = 0.05 ) :ReturnType(ZoomLevel) {

Computes the new zoom level in order to zoom in.

=cut
method compute_zoom_in( (ZoomLevel) $zoom_level, $amount = 0.05 ) :ReturnType(ZoomLevel) {
	return $zoom_level + $amount;
}

1;
