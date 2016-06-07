use Renard::Curie::Setup;
package Renard::Curie::Model::Document::CairoImageSurface;

use Renard::Curie::Model::Page::CairoImageSurface;
use Function::Parameters;
use Renard::Curie::Types qw(PageNumber InstanceOf ArrayRef);

use Moo;

has image_surfaces => (
	is => 'ro',
	isa => ArrayRef[InstanceOf['Cairo::ImageSurface']],
	required => 1
);

method _build_last_page_number :ReturnType(PageNumber) {
	return scalar @{ $self->image_surfaces };
}

method get_rendered_page( (PageNumber) :$page_number ) {
	my $index = $page_number - 1;

	return Renard::Curie::Model::Page::CairoImageSurface->new(
		page_number => $page_number,
		cairo_image_surface => $self->image_surfaces->[$index],
	);
}

extends qw(Renard::Curie::Model::Document);

with qw(
	Renard::Curie::Model::Document::Role::Pageable
	Renard::Curie::Model::Document::Role::Renderable
);

1;
