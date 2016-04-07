use Modern::Perl;
package Renard::Curie::Model::Document::CairoImageSurface;

use Renard::Curie::Model::Page::CairoImageSurface;

use Moo;

has image_surfaces => ( is => 'ro', required => 1 );

sub _build_last_page_number {
	my ($self) = @_;
	return scalar @{ $self->image_surfaces }
}

sub get_rendered_page {
	my ($self, %opts) = @_;

	die "Missing page number" unless defined $opts{page_number};

	my $page_number = $opts{page_number};

	my $index = $page_number - 1;

	return Renard::Curie::Model::Page::CairoImageSurface->new(
		page_number => $page_number,
		cairo_image_surface => $self->image_surfaces->[$index],
	);
}

with qw(
	Renard::Curie::Model::Document::Role::Pageable
	Renard::Curie::Model::Document::Role::Renderable
);

1;
