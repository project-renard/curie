use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Role::ForDocument;
# ABSTRACT: Role for view model based on a document

use Moo::Role;
use Renard::Incunabula::Format::Cairo::Types qw(RenderableDocumentModel);

=attr document

The L<RenderableDocumentModel|Renard::Incunabula::Format::Cairo::Types/RenderableDocumentModel> that
this view model represents.

=cut
has document => (
	is => 'rw',
	isa => RenderableDocumentModel,
	required => 1
);

1;
