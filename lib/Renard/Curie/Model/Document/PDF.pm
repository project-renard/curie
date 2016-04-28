use Modern::Perl;
package Renard::Curie::Model::Document::PDF;

use Moo;
use Renard::Curie::Data::PDF;
use Renard::Curie::Model::Page::RenderedFromPNG;

sub _build_last_page_number {
	my ($self) = @_;
	my $info = Renard::Curie::Data::PDF::get_mutool_page_info_xml(
		$self->filename
	);

	return scalar @{ $info->{page} };
}

=method get_rendered_page

See L<Renard::Curie::Model::Document::Role::Renderable>.

=cut
# TODO : need to implement zoom_level option
sub get_rendered_page {
	my ($self, %opts) = @_;

	die "Missing page number" unless defined $opts{page_number};

	my $page_number = $opts{page_number};

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
);

1;
