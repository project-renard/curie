use Renard::Curie::Setup;
package Renard::Curie::Model::View::Role::ForDocument;
# ABSTRACT: Role for view model based on a document

use Moo::Role;
use Renard::Curie::Types qw(RenderableDocumentModel);

=attr document

The L<RenderableDocumentModel|Renard:Curie::Types/RenderableDocumentModel> that
this view model represents.

=cut
has document => (
	is => 'rw',
	isa => RenderableDocumentModel,
	required => 1
);

1;
