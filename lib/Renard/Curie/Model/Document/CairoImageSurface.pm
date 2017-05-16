use Renard::Curie::Setup;
package Renard::Curie::Model::Document::CairoImageSurface;
# ABSTRACT: Document made up of a collection of Cairo image surfaces

use Renard::Curie::Model::Page::CairoImageSurface;
use Function::Parameters;
use Renard::Curie::Types qw(PageNumber InstanceOf ArrayRef);

use Moo;

=attr image_surfaces

An L<ArrayRef> of C<Cairo::ImageSurface>s which are the backing store of this
document.

=cut
has image_surfaces => (
	is => 'ro',
	isa => ArrayRef[InstanceOf['Cairo::ImageSurface']],
	required => 1
);


=attr identity_bounds

TODO

=cut
has identity_bounds => (
	is => 'lazy', # _build_identity_bounds
);

method _build_last_page_number() :ReturnType(PageNumber) {
	return scalar @{ $self->image_surfaces };
}

=method get_rendered_page

  method get_rendered_page( (PageNumber) :$page_number )

Returns a new L<Renard::Curie::Model::Page::CairoImageSurface> object.

See L<Renard::Curie::Model::Document::Role::Renderable/get_rendered_page> for more details.

=cut
method get_rendered_page( (PageNumber) :$page_number, @) {
	my $index = $page_number - 1;

	return Renard::Curie::Model::Page::CairoImageSurface->new(
		page_number => $page_number,
		cairo_image_surface => $self->image_surfaces->[$index],
	);
}

method _build_identity_bounds() {
	my $surfaces = $self->image_surfaces;
	return [ map {
		{
			x => $surfaces->[$_]->get_height,
			y => $surfaces->[$_]->get_width,
			rotate => 0,
			pageno => $_ + 1,
			dims => {
				w => $surfaces->[$_]->get_width,
				h => $surfaces->[$_]->get_height,
			},
		}
	} 0..@$surfaces-1 ];
}

extends qw(Renard::Curie::Model::Document);

with qw(
	Renard::Curie::Model::Document::Role::Pageable
	Renard::Curie::Model::Document::Role::Renderable
);

1;
