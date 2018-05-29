use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::PhraseCloze;

use Moo::Role;
use MooX::Lsub;

use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Curie::Schema;
use Renard::Curie::Process::PyTextRank;

use namespace::clean;

has current_phrase_schema_result => (
	is => 'rw',
	trigger => 1, # _trigger_current_phrase_schema_result
);

method _trigger_current_phrase_schema_result($phrase) {
	if( ! defined $self->current_document || $phrase->document_id->path ne $self->current_document->filename  ) {
		$self->open_pdf_document( $phrase->document_id->path );
	}

	if( $phrase->page != $self->current_view->page_number ) {
		$self->current_view->page_number( $phrase->page );
	}
}

has schema => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Schema'],
);

method current_document_schema_result() {
	$self->_get_pytextrank_process->document_result;
}

method _get_pytextrank_process() {
	$self->current_document->get_pytextrank_process( $self->schema );
}

method run_process_pytextrank() {
	$self->_get_pytextrank_process->process;
}

method phrases_on_current_page() {
	$self->run_process_pytextrank;

	return $self->current_document_schema_result->phrase_cloze->search({
		page => $self->current_view->page_number
	});
}

1;
