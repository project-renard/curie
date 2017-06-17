use Renard::Curie::Setup;
package Renard::Curie::Model::Document::PDF;
# ABSTRACT: document that represents a PDF file

use Moo;
use Renard::Curie::Data::PDF;
use Renard::Curie::Model::Page::RenderedFromPNG;
use Renard::Curie::Model::Outline;
use Renard::Curie::Types qw(PageNumber ZoomLevel);

use Math::Trig;
use Math::Polygon;

use Function::Parameters;

extends qw(Renard::Curie::Model::Document);

has _raw_bounds => (
	is => 'lazy', # _build_raw_bounds
);

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

method _build__raw_bounds() {
	my $info = Renard::Curie::Data::PDF::get_mutool_page_info_xml(
		$self->filename
	);
}

method _build_identity_bounds() {
	my $compute_rotate_dim = sub {
		my ($info) = @_;
		my $theta_deg = $info->{rotate} // 0;
		my $theta_rad = $theta_deg * pi / 180;

		my ($x, $y) = ($info->{x}, $info->{y});
		my $poly = Math::Polygon->new(
			points => [
				[0, 0],
				[$x, 0],
				[$x, $y],
				[0, $y],
			],
		);

		my $rotated_poly = $poly->rotate(
			degrees => $theta_deg,
			center => [ $x/2, $y/2 ],
		);

		my ($xmin, $ymin, $xmax, $ymax) = $rotated_poly->bbox;


		return { w => $xmax - $xmin, h => $ymax - $ymin };
	};

	my $bounds = $self->_raw_bounds;
	my @page_xy = map {
		my $p = {
			x => $_->{MediaBox}{r},
			y => $_->{MediaBox}{t},
			rotate => $_->{Rotate}{v} // 0,
			pageno => $_->{pagenum},
		};
		if( exists $p->{rotate} ) {
			$p->{dims} = $compute_rotate_dim->( $p );
		}

		$p;
	} @{ $bounds->{page} };

	return \@page_xy;
}

with qw(
	Renard::Curie::Model::Document::Role::FromFile
	Renard::Curie::Model::Document::Role::Pageable
	Renard::Curie::Model::Document::Role::Renderable
	Renard::Curie::Model::Document::Role::Cacheable
	Renard::Curie::Model::Document::Role::Outlineable
	Renard::Curie::Model::Document::Role::Boundable
);

1;
