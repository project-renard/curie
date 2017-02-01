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

method draw_page(
	(InstanceOf['Gtk3::DrawingArea']) $widget,
	(InstanceOf['Cairo::Context']) $cr
) {
	my $rp = $self->rendered_page;

	my $img = $rp->cairo_image_surface;

	$cr->set_source_surface($img, ($widget->get_allocated_width -
		$rp->width) / 2, 0);
	$cr->paint;

	$widget->set_size_request(
		$rp->width,
		$rp->height );
}

=method set_current_page_to_first

  method set_current_page_to_first()

Sets the page number to the first page of the document.

=cut
method set_current_page_to_first() {
	$self->page_number( $self->document->first_page_number );
}

=method set_current_page_to_last

  method set_current_page_to_last()

Sets the current page to the last page of the document.

=cut
method set_current_page_to_last() {
	$self->page_number( $self->document->last_page_number );
}

=method can_move_to_previous_page

  method can_move_to_previous_page() :ReturnType(Bool)

Predicate to check if we can decrement the current page number.

=cut
method can_move_to_previous_page() :ReturnType(Bool) {
	$self->page_number > $self->document->first_page_number;
}

=method can_move_to_next_page

  method can_move_to_next_page() :ReturnType(Bool)

Predicate to check if we can increment the current page number.

=cut
method can_move_to_next_page() :ReturnType(Bool) {
	$self->page_number < $self->document->last_page_number;
}

=method set_current_page_forward

  method set_current_page_forward()

Increments the current page number if possible.

=cut
method set_current_page_forward() {
	if( $self->can_move_to_next_page ) {
		$self->page_number( $self->page_number + 1 );
	}
}

=method set_current_page_back

  method set_current_page_back()

Decrements the current page number if possible.

=cut
method set_current_page_back() {
	if( $self->can_move_to_previous_page ) {
		$self->page_number( $self->page_number - 1 );
	}
}


1;
