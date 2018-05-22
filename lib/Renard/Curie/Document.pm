use Renard::Incunabula::Common::Setup;
package Renard::Curie::Document;
# ABSTRACT: Loads the roles

use Modern::Perl;
use Moo;

extends qw(Renard::Incunabula::Format::PDF::Document);

with qw(
		Renard::Curie::Document::Role::MD5
		Renard::Curie::Document::Role::PopplerText
		Renard::Curie::Document::Role::PyTextRank
		Renard::Curie::Document::Role::SchemaHelpers
);

1;
