use Renard::Incunabula::Common::Setup;
package Renard::Curie::Document::Role::PyTextRank;
# ABSTRACT: Role to provide PyTextRank data

use Moo::Role;

use Renard::Incunabula::NLP::PyTextRank;

method pytextrank() {
	my $tr = Renard::Incunabula::NLP::PyTextRank->new();
	my $data = $tr->get_text_rank( $self->pdftotext_text );

	$data;
}

1;
