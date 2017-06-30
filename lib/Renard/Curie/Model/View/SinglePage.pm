use Renard::Curie::Setup;
package Renard::Curie::Model::View::SinglePage;
# ABSTRACT: A view model for single page views

use Moo;
use MooX::Struct
	BBox => [ qw( width height x y) ]
;
use POSIX qw(ceil);
use Renard::Curie::Types qw(RenderablePageModel InstanceOf SizeRequest);

use Renard::Curie::Model::View;
use Glib::Object::Subclass
	'Renard::Curie::Model::View';
extends 'Renard::Curie::Model::View';

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Initialises the L<Glib::Object> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}


=method rendered_page

A L<RenderablePageModel|Renard:Curie::Types/RenderablePageModel> for the
current page.

=cut
method rendered_page() :ReturnType(RenderablePageModel) {
	my $rp = $self->document->get_rendered_page(
		page_number => $self->page_number,
		zoom_level => $self->zoom_level,
	);
}

method _trigger_page_number($new_page_number) {
	$self->signal_emit( 'view-changed' );
}

method _trigger_zoom_level($new_zoom_level) {
	$self->signal_emit( 'view-changed' );
}

=method draw_page

See L<Renard::Curie::Model::View::Role::Renderable/draw_page>.

=cut
method draw_page(
	(InstanceOf['Gtk3::DrawingArea']) $widget,
	(InstanceOf['Cairo::Context']) $cr
) {
	my $rp = $self->rendered_page;
	my $img = $rp->cairo_image_surface;

	# get the widget dimensions so that the position is correct
	$self->_widget_dims([
		$widget->get_allocated_width,
		$widget->get_allocated_height,
	]);
	$cr->set_source_surface($img, $self->_get_page_pos );

	$cr->paint;
}

=method update_scroll_adjustment

Updates the position of the scrollbar for the view.

=cut
method update_scroll_adjustment(
	(InstanceOf['Gtk3::Adjustment']) $hadjustment,
	(InstanceOf['Gtk3::Adjustment']) $vadjustment,
	) {

	#say join "; ",
		#map {
			#my $list = join ", ", (
				#$_->get_lower,
				#$_->get_value,
				#$_->get_value + $_->get_page_size,
				#$_->get_upper,
			#);
			#"[ $list ]";
		#} ($hadjustment, $vadjustment);
}

has _widget_dims => (
	is => 'rw',
);

method _page_bbox() {
	my ($w, $h) = $self->get_size_request;

	# centre the page
	my $x = ($self->_widget_dims->[0] - $w) / 2;
	my $y = 0;

	my $bbox = BBox->new(
		width => $w, height => $h,
		x => $x, y => $y,
	);

	return $bbox;
}

method _get_page_pos() {
	return ($self->_page_bbox->x, $self->_page_bbox->y);
}

=method get_size_request

See L<Renard::Curie::Model::View::Role::Renderable/get_size_request>.

=cut
method get_size_request() :ReturnType( list => SizeRequest) {
	my $page_identity = $self->document
		->identity_bounds
		->[ $self->page_number - 1 ];

	# multiply to account for zoom-level
	my $w = ceil($page_identity->{dims}{w} * $self->zoom_level);
	my $h = ceil($page_identity->{dims}{h} * $self->zoom_level);

	return ( $w, $h );
}

with qw(
	Renard::Curie::Model::View::Role::ForDocument
	Renard::Curie::Model::View::Role::Pageable
	Renard::Curie::Model::View::Role::Zoomable
	Renard::Curie::Model::View::Role::Renderable
);

1;
