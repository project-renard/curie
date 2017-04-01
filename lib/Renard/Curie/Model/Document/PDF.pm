use Renard::Curie::Setup;
package Renard::Curie::Model::Document::PDF;
# ABSTRACT: document that represents a PDF file

use Moo;
use Renard::Curie::Data::PDF;
use Renard::Curie::Model::Page::RenderedFromPNG;
use Renard::Curie::Model::Outline;
use Renard::Curie::Types qw(PageNumber ZoomLevel);
use Function::Parameters;

extends qw(Renard::Curie::Model::Document);

=begin comment

=method _build_last_page_number

Retrieves the last page number of the PDF. Currently implemented through
C<mutool>.

=end comment

=cut
method _build_last_page_number() :ReturnType(PageNumber) {
	my $info = Renard::Curie::Data::PDF::get_mutool_page_info_xml(
		$self->filename
	);

	return scalar @{ $info->{page} };
}

=method get_rendered_page

  method get_rendered_page( (PageNumber) :$page_number )

See L<Renard::Curie::Model::Document::Role::Renderable>.

=cut
method get_rendered_page( (PageNumber) :$page_number, (ZoomLevel) :$zoom_level = 1.0 ) {
	my $png_data = Renard::Curie::Data::PDF::get_mutool_pdf_page_as_png(
		$self->filename, $page_number, $zoom_level
	);

	return Renard::Curie::Model::Page::RenderedFromPNG->new(
		page_number => $page_number,
		png_data => $png_data,
		zoom_level => $zoom_level,
	);
}

method _build_outline() {
	my $outline_data = Renard::Curie::Data::PDF::get_mutool_outline_simple(
		$self->filename
	);

	return Renard::Curie::Model::Outline->new( items => $outline_data );
}

with qw(
	Renard::Curie::Model::Document::Role::FromFile
	Renard::Curie::Model::Document::Role::Pageable
	Renard::Curie::Model::Document::Role::Renderable
	Renard::Curie::Model::Document::Role::Cacheable
	Renard::Curie::Model::Document::Role::Outlineable
);

1;
