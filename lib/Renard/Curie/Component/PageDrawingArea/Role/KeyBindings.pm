use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::KeyBindings;
# ABSTRACT: A role to setup the key bindings for a page drawing area

use Moo::Role;
use Gtk3;

after BUILD => method(@) {
	$self->setup_keybindings;
};

=method setup_keybindings

  method setup_keybindings()

Sets up the signals to capture key presses on this component.

=cut
method setup_keybindings() {
	$self->signal_connect( key_press_event => \&on_key_press_event_cb, $self );
}

=callback on_key_press_event_cb

  callback on_key_press_event_cb($window, $event, $self)

Callback that responds to specific key events and dispatches to the appropriate
handlers.

=cut
callback on_key_press_event_cb($window, $event, $self) {
	if($event->keyval == Gtk3::Gdk::KEY_Page_Down){
		$self->view->set_current_page_forward;
	} elsif($event->keyval == Gtk3::Gdk::KEY_Page_Up){
		$self->view->set_current_page_back;
	} elsif($event->keyval == Gtk3::Gdk::KEY_Up){
		$self->scrolled_window->get_vadjustment->decrement_step;
	} elsif($event->keyval == Gtk3::Gdk::KEY_Down){
		$self->scrolled_window->get_vadjustment->increment_step;
	} elsif($event->keyval == Gtk3::Gdk::KEY_Right){
		$self->scrolled_window->get_hadjustment->increment_step;
	} elsif($event->keyval == Gtk3::Gdk::KEY_Left){
		$self->scrolled_window->get_hadjustment->decrement_step;
	}
}

1;
