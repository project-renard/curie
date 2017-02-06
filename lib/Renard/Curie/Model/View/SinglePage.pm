use Renard::Curie::Setup;
package Renard::Curie::Model::View::SinglePage;
# ABSTRACT: TODO

use Moo;
use Renard::Curie::Types qw(RenderablePageModel InstanceOf RenderableDocumentModel PageNumber ZoomLevel);

use Glib::Object::Subclass
	Glib::Object::,
	signals => { 'view-changed' => {} },
	;

=head1 SIGNALS

=for :list
* C<view-changed>: called when a view property is changed.

=cut

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Initialises the L<Glib::Object> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}


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


=begin comment

=method _trigger_page_number

  method _trigger_page_number($new_page_number)

Called whenever the L</page_number> is changed. This allows for telling
the component to retrieve the new page and redraw.

=end comment

=cut
method _trigger_page_number($new_page_number) {
	$self->signal_emit( 'view-changed' );
}

=begin comment

=method _trigger_zoom_level

  method _trigger_zoom_level($new_zoom_level)

Called whenever the L</zoom_level> is changed. This tells the component to
redraw the current page at the new zoom level.

=end comment

=cut
method _trigger_zoom_level($new_zoom_level) {
	$self->signal_emit( 'view-changed' );
}

=method draw_page

TODO

=cut
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

with qw(
	Renard::Curie::Model::View::Role::Pageable
);

1;
