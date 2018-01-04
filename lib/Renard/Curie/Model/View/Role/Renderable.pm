use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Role::Renderable;
# ABSTRACT: Role for rendering a view model

use Moo::Role;
use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Incunabula::Frontend::Gtk3::Types qw(SizeRequest);

=method draw_page

Draws the pages for the current view model to a C<Gtk3::DrawingArea>.

=cut
method draw_page(
	(InstanceOf['Gtk3::DrawingArea']) $widget,
	(InstanceOf['Cairo::Context']) $cr
) {
	# uncoverable subroutine
	... # uncoverable statement
}

=method get_size_request

Determines the size request for the current view.

=cut
method get_size_request() :ReturnType( list => SizeRequest) {
	# uncoverable subroutine
	... # uncoverable statement
}

1;
