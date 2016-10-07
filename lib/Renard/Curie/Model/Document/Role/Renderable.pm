use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::Renderable;
# ABSTRACT: Role for documents that can render their pages

use Moo::Role;

=method get_rendered_page

  get_rendered_page( %opts )

Returns a C<Renard::Curie::Model::Page::Role::CairoRenderable>.

The options for this function are:

=over 4

=item * C<<page_number => PageNumber $page_number>>:

The page number to retrieve.

Required. Value must be a C<PageNumber> which must be between the
C<first_page_number> and C<last_page_number>.

=item * C<<zoom_level => ZoomLevel $zoom_level>>:

The amount of zoom to use in order to control the dimensions of the
rendered PDF page. This is C<1.0> by default.

Optional. Value must be a C<ZoomLevel>.

=back

=cut
requires 'get_rendered_page';

# TODO implement the actual method signature here

1;
