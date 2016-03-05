package Renard::Curie::Model::PDFDocument;

use Moo;
use Renard::Curie::Data::PDF;
use Renard::Curie::Model::RenderedDocumentPage;

=attr filename

A C<Str> containing the path to the PDF document.

=cut
has filename => ( is => 'ro' );

=attr first_page_number

An C<Int> containing the first page number of the PDF document.
This is always C<1>.

=cut
has first_page_number => ( is => 'ro', default => sub { 1 } );


=attr last_page_number

An C<Int> containing the last page number of the PDF document.

=cut
has last_page_number => (
	is => 'lazy', # _build_last_page_number
	);

sub _build_last_page_number {
	my ($self) = @_;
	my $info = Renard::Curie::Data::PDF::get_pdfinfo_for_filename(
		$self->filename
	);

	return $info->{Pages};
}

=method get_rendered_page( %opts )

Returns a C<Renard::Curie::Model::RenderedDocumentPage>.

The options for this function are:

=over 4

=item * C<page_number>:

The page number to retrieve.

Required. Value must be an Int which must be between the
C<first_page_number> and C<last_page_number>.

=item * C<zoom_level>: 

The amount of zoom to use in order to control the dimensions of the
rendered PDF page. This is C<1.0> by default.

Optional. Value must be a Float.

TODO : need to implement this option

=back

=cut

sub get_rendered_page {
	my ($self, %opts) = @_;

	die "Missing page number" unless defined $opts{page_number};

	my $page_number = $opts{page_number};

	my $png_data = Renard::Curie::Data::PDF::mudraw_get_pdf_page_as_png(
		$self->filename, $page_number,
	);

	return Renard::Curie::Model::RenderedDocumentPage->new(
		page_number => $page_number,
		png_data => $png_data,
		zoom_level => 1,
	);
}

1;
