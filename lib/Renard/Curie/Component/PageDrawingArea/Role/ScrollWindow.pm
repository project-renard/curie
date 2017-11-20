use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::ScrollWindow;
# ABSTRACT: A role with helpers for scrolling the page drawing area viewport

use Moo::Role;
use Gtk3;
use Renard::Incunabula::Common::Types qw(InstanceOf);

=method increment_scroll

  method increment_scroll( (InstanceOf['Gtk3::Adjustment']) $current )

Helper method that scrolls down by the scrollbar's step increment.

=cut
method increment_scroll( (InstanceOf['Gtk3::Adjustment']) $current ) {
	my $adjustment = $current->get_value + $current->get_step_increment;
	$current->set_value($adjustment);
}

=method decrement_scroll

  method decrement_scroll( (InstanceOf['Gtk3::Adjustment']) $current )

Helper method that scrolls up by the scrollbar's step increment.

=cut
method decrement_scroll( (InstanceOf['Gtk3::Adjustment']) $current ) {
	my $adjustment = $current->get_value - $current->get_step_increment;
	$current->set_value($adjustment);
}


1;
