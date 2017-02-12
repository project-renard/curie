use Renard::Curie::Setup;
package Renard::Curie::Model::View::Role::ForDocument;
# ABSTRACT: TODO

use Moo::Role;
use Renard::Curie::Types qw(RenderableDocumentModel);

=attr document

The L<RenderableDocumentModel|Renard:Curie::Types/RenderableDocumentModel> that
this component displays.

=cut
has document => (
	is => 'rw',
	isa => RenderableDocumentModel,
	required => 1
);

1;
