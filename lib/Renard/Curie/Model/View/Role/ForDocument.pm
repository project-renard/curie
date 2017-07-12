use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Role::ForDocument;
# ABSTRACT: Role for view model based on a document

use Moo::Role;
use Renard::Incunabula::Common::Types qw(RenderableDocumentModel);

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
