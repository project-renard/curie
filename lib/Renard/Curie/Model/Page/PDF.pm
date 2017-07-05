use Renard::Curie::Setup;
package Renard::Curie::Model::Page::PDF;
# ABSTRACT: Page from a PDF document

use Moo;
use MooX::HandlesVia;
use Cairo;
use POSIX qw(ceil);

use Renard::Curie::Types qw(Str InstanceOf ZoomLevel PageNumber HashRef);

extends 'Renard::Curie::Model::Page::RenderedFromPNG';

has document => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Model::Document::PDF'],
);

has page_number => ( is => 'ro', required => 1, isa => PageNumber, );
has zoom_level => ( is => 'ro', required => 1, isa => ZoomLevel, );

has png_data => (
	is => 'lazy', # _build_png_data
	isa => Str,
);

method _build_png_data() {
	my $png_data = Renard::Curie::Data::PDF::get_mutool_pdf_page_as_png(
		$self->document->filename, $self->page_number, $self->zoom_level
	);
}


has _size => (
	is => 'lazy',
	isa => HashRef,
	handles_via => 'Hash',
	handles => {
		width => ['get', 'width'],
		height => ['get', 'height'],
	},
);

method _build__size() {
	my $page_identity = $self->document
		->identity_bounds
		->[ $self->page_number - 1 ];

	# multiply to account for zoom-level
	my $w = ceil($page_identity->{dims}{w} * $self->zoom_level);
	my $h = ceil($page_identity->{dims}{h} * $self->zoom_level);

	{ width => $w, height => $h };
}



with qw(
	Renard::Curie::Model::Page::Role::CairoRenderable
);

1;
