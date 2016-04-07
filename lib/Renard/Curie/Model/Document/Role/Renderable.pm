use Modern::Perl;
package Renard::Curie::Model::Document::Role::Renderable;

use Moo::Role;

=method get_rendered_page

  get_rendered_page( %opts )

Returns a C<Renard::Curie::Model::Page::Role::CairoRenderable>.

The options for this function are:

=over 4

=item * C<page_number>:

The page number to retrieve.

Required. Value must be an Int which must be between the
C<first_page_number> and C<last_page_number>.

=item * C<zoom_level>:

The amount of zoom to use in order to control the dimensions of the
rendered PDF page. This is C<1.0> by default.

Optional. Value must be a Float.


=back

=cut
requires 'get_rendered_page';

1;
