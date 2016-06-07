use Renard::Curie::Setup;
package Renard::Curie::Model::Document::PDF;

use Moo;
use Renard::Curie::Data::PDF;
use Renard::Curie::Model::Page::RenderedFromPNG;
use Renard::Curie::Types qw(PageNumber);
use Function::Parameters;

extends qw(Renard::Curie::Model::Document);

method _build_last_page_number :ReturnType(PageNumber) {
	my $info = Renard::Curie::Data::PDF::get_mutool_page_info_xml(
		$self->filename
	);

	return scalar @{ $info->{page} };
}

=method get_rendered_page

See L<Renard::Curie::Model::Document::Role::Renderable>.

=cut
# TODO : need to implement zoom_level option
method get_rendered_page( (PageNumber) :$page_number ) {
	my $png_data = Renard::Curie::Data::PDF::get_mutool_pdf_page_as_png(
		$self->filename, $page_number,
	);

	return Renard::Curie::Model::Page::RenderedFromPNG->new(
		page_number => $page_number,
		png_data => $png_data,
		zoom_level => 1,
	);
}

with qw(
	Renard::Curie::Model::Document::Role::FromFile
	Renard::Curie::Model::Document::Role::Pageable
	Renard::Curie::Model::Document::Role::Renderable
);

1;
