use Renard::Curie::Setup;
package Renard::Curie::ViewModel::ViewManager;
# ABSTRACT: Manages the currently open views

use Moo;
use Renard::Curie::Types qw(InstanceOf DocumentModel Path FileUri);
use Renard::Curie::Model::View::SinglePage;
use Renard::Curie::Model::View::ContinuousPage;
use Renard::Curie::Model::ViewOptions::Grid;
use Renard::Curie::Model::Document::PDF;

use Renard::Curie::Model::ViewOptions;
use Renard::Curie::Model::View::Grid;

use Glib::Object::Subclass
	'Glib::Object',
	signals => {
		'document-changed' => {
			param_types => [
				'Glib::Scalar', # DocumentModel
			]
		},
		'update-view' => {
			param_types => [
				'Glib::Scalar', # View
			]
		},
	},
	;

has current_document => (
	is => 'rw',
	isa => DocumentModel,
	trigger => 1, # _trigger_current_document
);

has current_view => (
	is => 'rw',
	isa => InstanceOf['Renard::Curie::Model::View'],
	trigger => 1, # _trigger_current_view
);

method _trigger_current_view($view) {
	$self->signal_emit( 'update-view' => $view );
}

method _trigger_current_document( (DocumentModel) $doc ) {
	$self->current_view(
		Renard::Curie::Model::View::Grid->new(
			view_options => Renard::Curie::Model::ViewOptions->new(
				grid_options => Renard::Curie::Model::ViewOptions::Grid->new(
					rows => undef,
					columns => 4,
				)
			),
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
		Renard::Curie::Error::IO::FileNotFound
			->throw("PDF filename does not exist: $pdf_filename");
	}

	$self->current_document(
		Renard::Curie::Model::Document::PDF->new(
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

=method set_view_to_continuous_page

  method set_view_to_continuous_page()

Sets the L</current_view> to L<Renard::Curie::Model::View::ContinuousPage>.

=cut
method set_view_to_continuous_page() {
	$self->current_view(
		Renard::Curie::Model::View::ContinuousPage->new(
			document => $self->current_document
		)
	);
}

=method set_view_to_single_page

  method set_view_to_single_page()

Sets the L</current_view> to L<Renard::Curie::Model::View::SinglePage>.

=cut
method set_view_to_single_page() {
	$self->current_view(
		Renard::Curie::Model::View::SinglePage->new(
			document => $self->current_document
		)
	);
}

1;
