use Renard::Curie::Setup;
package Renard::Curie::Types;
# ABSTRACT: Type library

use Type::Library 0.008 -base,
	-declare => [qw(
		DocumentModel
		RenderableDocumentModel
		PageNumber
	)];
use Type::Utils -all;

# Listed here so that scan-perl-deps can find them
use Types::Path::Tiny      ();
use Types::Standard        ();
use Types::Common::Numeric qw(PositiveInt PositiveOrZeroInt PositiveNum);

use Type::Libraries;
Type::Libraries->setup_class(
	__PACKAGE__,
	qw(
		Types::Standard
		Types::Path::Tiny
		Types::Common::Numeric
	)
);

=head1 TYPE LIBRARIES

=for :list
* L<Types::Standard>
* L<Types::Path::Tiny>
* L<Types::Common::Numeric>

=cut

=type DocumentModel

A type for any reference that extends L<Renard::Curie::Model::Document>.

=cut
class_type "DocumentModel",
	{ class => "Renard::Curie::Model::Document" };

=type RenderableDocumentModel

A type for any reference that does
L<Renard::Curie::Model::Document::Role::Renderable>.

=cut
role_type "RenderableDocumentModel",
	{ role => "Renard::Curie::Model::Document::Role::Renderable" };

=type RenderablePageModel

A type for any reference that does
L<Renard::Curie::Model::Page::Role::CairoRenderable>.

=cut
role_type "RenderablePageModel",
	{ role => "Renard::Curie::Model::Page::Role::CairoRenderable" };

=type PageNumber

An alias to L<PositiveInt> that can be used for document page number semantics.

=cut
declare "PageNumber", parent => PositiveInt;

=type LaxPageNumber

An alias to L<PositiveOrZeroInt> that can be used for document page number
semantics when the source data may contain invalid pages.

=cut
declare "LaxPageNumber", parent => PositiveOrZeroInt;

=type ZoomLevel

The amount to zoom in on a page. This is a multiplier such that

=for :list
* when the value is C<1.0>, the page area is the standard area
* when the value is C<2.0>, the page is C<4> times the standard area
* when the value is C<0.5>, the page is C<0.25> times the standard area

=cut
declare "ZoomLevel", parent => PositiveNum;

1;
