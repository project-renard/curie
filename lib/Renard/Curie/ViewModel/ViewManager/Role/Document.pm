use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::Document;
# ABSTRACT: A role for the document

use Moo::Role;

use Renard::Incunabula::Document::Types qw(DocumentModel);
use Renard::Incunabula::Common::Types qw(Path FileUri);

has current_document => (
	is => 'rw',
	isa => DocumentModel,
	trigger => 1, # _trigger_current_document
);

method _trigger_current_document( (DocumentModel) $doc ) {
	$self->clear_view_options;
	$self->current_view(
		Renard::Curie::Model::View::Grid->new(
			view_options => $self->view_options,
			document => $doc,
		)
	);

	$self->signal_emit( 'document-changed' => $doc );
}

=method open_pdf_document

  method open_pdf_document( (Path->coercibles) $pdf_filename )

Opens a PDF file stored on the disk.

=cut
method open_pdf_document( (Path->coercibles) $pdf_filename ) {
	$pdf_filename = Path->coerce( $pdf_filename );
	if( not -f $pdf_filename ) {
		Renard::Incunabula::Common::Error::IO::FileNotFound
			->throw("PDF filename does not exist: $pdf_filename");
	}

	$self->current_document(
		Renard::Incunabula::Block::Format::PDF::Document->new(
			filename => $pdf_filename,
		)
	);
}

=method open_document_as_file_uri

  method open_document_as_file_uri( (FileUri) $uri )

Takes a file in the form of a C<FileUri> and opens the file.

=cut
method open_document_as_file_uri( (FileUri) $uri ) {
	$self->open_pdf_document( $uri->file );
}

1;
