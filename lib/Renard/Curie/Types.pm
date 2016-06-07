use Renard::Curie::Setup;
package Renard::Curie::Types;

use Type::Library 0.008 -base,
	-declare => [qw(
		DocumentModel
		RenderableDocumentModel
		PageNumber
	)];
use Type::Utils;
use Types::Common::Numeric qw(PositiveInt);

# Listed here so that scan-perl-deps can find them
use Types::Path::Tiny      ();
use Types::Standard        ();
use Types::Common::Numeric ();

use Type::Libraries;
Type::Libraries->setup_class(
	__PACKAGE__,
	qw(
		Types::Standard
		Types::Path::Tiny
		Types::Common::Numeric
	)
);

class_type "DocumentModel",
	{ class => "Renard::Curie::Model::Document" };

role_type "RenderableDocumentModel",
	{ role => "Renard::Curie::Model::Document::Role::Renderable" };

declare "PageNumber", as => PositiveInt;

1;
