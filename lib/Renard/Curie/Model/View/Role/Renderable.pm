use Renard::Curie::Setup;
package Renard::Curie::Model::View::Role::Renderable;
# ABSTRACT: Role for rendering a view model

use Moo::Role;
use Renard::Curie::Types qw(InstanceOf SizeRequest);

=method draw_page

Draws the pages for the current view model to a C<Gtk3::DrawingArea>.

=cut
method draw_page(
	(InstanceOf['Gtk3::DrawingArea']) $widget,
	(InstanceOf['Cairo::Context']) $cr
) {
	...
}

=method get_size_request

Determines the size request for the current view.

=cut
method get_size_request() :ReturnType( list => SizeRequest) {
	...
}

1;
