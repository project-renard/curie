use Renard::Incunabula::Common::Setup;
package Renard::Curie::Document::Role::SchemaHelpers;

use Moo::Role;

use Renard::Curie::Process::PyTextRank;
use namespace::clean;

method get_schema_result( $schema ) {
	my $doc = $schema->resultset('Document')->find_or_create(
		{
			md5sum => $self->md5sum_hex,
			path => $self->filename
		},
	);
}

method is_ignored($schema) {
	my $doc = $self->get_schema_result( $schema );
	defined $doc->ignored && $doc->ignored->ignored;
}

method toggle_ignore($schema) {
	my $doc = $self->get_schema_result( $schema );
	$doc->update_or_create_related('ignored', { ignored => 0 + ! $self->is_ignored( $schema ) } );
}

method is_processed_pytextrank($schema) {
	defined $self->get_schema_result($schema)->processed_doc_pytextrank
		&& $self->get_schema_result($schema)->processed_doc_pytextrank->processed;
}

method process_pytextrank($schema) {
	$self->get_pytextrank_process($schema)->process;
}

method get_pytextrank_process($schema) {
	my $pytextrank_process = Renard::Curie::Process::PyTextRank->new(
		schema => $schema,
		document => $self,
	);
}

1;
