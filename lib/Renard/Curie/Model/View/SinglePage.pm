use Renard::Curie::Setup;
package Renard::Curie::Model::View::SinglePage;
# ABSTRACT: TODO

use Moo;
use Renard::Curie::Types qw(RenderableDocumentModel RenderablePageModel
	PageNumber ZoomLevel Bool InstanceOf);

# HACK TODO
has _pd => (
	is => 'rw',
);


=attr document

The L<RenderableDocumentModel|Renard:Curie::Types/RenderableDocumentModel> that
this component displays.

=cut
has document => (
	is => 'rw',
	isa => RenderableDocumentModel,
	required => 1
);

=attr page_number

A L<PageNumber|Renard:Curie::Types/PageNumber> for the current page being
drawn.

=cut
has page_number => (
	is => 'rw',
	isa => PageNumber,
	default => 1,
	trigger => 1 # _trigger_page_number
	);

=attr zoom_level

A L<ZoomLevel|Renard::Curie::Types/ZoomLevel> for the current zoom level for
the document.

=cut
has zoom_level => (
	is => 'rw',
	isa => ZoomLevel,
	default => 1.0,
	trigger => 1 # _trigger_zoom_level
	);

=attr rendered_page

A L<RenderablePageModel|Renard:Curie::Types/RenderablePageModel> for the
current page.

=cut
method rendered_page() :ReturnType(RenderablePageModel) {
	my $rp = $self->document->get_rendered_page(
		page_number => $self->page_number,
		zoom_level => $self->zoom_level,
	);
}


# HACK TODO
=begin comment

=method _trigger_page_number

  method _trigger_page_number($new_page_number)

Called whenever the L</page_number> is changed. This allows for telling
the component to retrieve the new page and redraw.

=end comment

=cut
method _trigger_page_number($new_page_number) {
	$self->_pd->refresh_drawing_area;
}

# HACK TODO
=begin comment

=method _trigger_zoom_level

  method _trigger_zoom_level($new_zoom_level)

Called whenever the L</zoom_level> is changed. This tells the component to
redraw the current page at the new zoom level.

=end comment

=cut
method _trigger_zoom_level($new_zoom_level) {
	$self->_pd->refresh_drawing_area;
}

1;