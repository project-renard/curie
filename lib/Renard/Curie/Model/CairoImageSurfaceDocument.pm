package Renard::Curie::Model::CairoImageSurfaceDocument;

use Moo;

has image_surfaces =>( is => 'ro', required => 1 );

has first_page_number => ( is => 'ro', default => sub { 1 } );

has last_page_number => (
	is => 'lazy', # _build_last_page_number
	);

sub _build_last_page_number {
	my ($self) = @_;
	return scalar @{ $self->image_surfaces }
}

sub get_rendered_page {
	my ($self, %opts) = @_;

	die "Missing page number" unless defined $opts{page_number};

	my $page_number = $opts{page_number};

	my $index = $page_number - 1;

	return Renard::Curie::Model::CairoImageSurfaceDocumentPage->new(
		page_number => $page_number,
		cairo_image_surface => $self->image_surfaces->[$index],
	);
}

1;

package Renard::Curie::Model::CairoImageSurfaceDocumentPage;

use Moo;

has cairo_image_surface => ( is => 'ro', required => 1 );

has [ qw(width height) ] => (
	is => 'lazy' # _build_width _build_height
);

sub _build_width {
	my ($self) = @_;
	$self->cairo_image_surface->get_width;
}

sub _build_height {
	my ($self) = @_;
	$self->cairo_image_surface->get_height;
}

1;
