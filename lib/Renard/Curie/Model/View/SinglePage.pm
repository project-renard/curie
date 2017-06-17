use Renard::Curie::Setup;
package Renard::Curie::Model::View::SinglePage;
# ABSTRACT: TODO

use Moo;
use MooX::Struct
	BBox => [ qw( width height x y) ]
;
use POSIX qw(ceil);
use Renard::Curie::Types qw(RenderablePageModel InstanceOf);

use Glib::Object::Subclass
	'Glib::Object',
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

TODO

=cut
method draw_page(
	(InstanceOf['Gtk3::DrawingArea']) $widget,
	(InstanceOf['Cairo::Context']) $cr
) {
	say "called draw";

	$self->widget_dims([
		$widget->get_allocated_width,
		$widget->get_allocated_height,
	]);

	my @previous_size_request = $widget->get_size_request;
	my @current_size_request  = $self->get_size_request;
	unless( $current_size_request[0] == $previous_size_request[0]
		&& $current_size_request[1] == $previous_size_request[1] ) {

		$widget->set_size_request( $self->get_size_request );

		# Do not draw this time. Draw the next time after the size is
		# changed.
		return;
	}

	my $rp = $self->rendered_page;
	my $img = $rp->cairo_image_surface;

	$cr->set_source_surface($img, $self->get_page_pos );
	$cr->paint;
}

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

has widget_dims => (
	is => 'rw',
);

method page_bbox() {
	my $page_identity = $self->document
		->identity_bounds
		->[ $self->page_number - 1 ];

	# multiply to account for zoom-level
	my $w = ceil($page_identity->{dims}{w} * $self->zoom_level);
	my $h = ceil($page_identity->{dims}{h} * $self->zoom_level);

	# centre the page
	my $x = ($self->widget_dims->[0] - $w) / 2;
	my $y = 0;

	my $bbox = BBox->new(
		width => $w, height => $h,
		x => $x, y => $y,
	);

	return $bbox;
}

method get_page_pos() {
	return ($self->page_bbox->x, $self->page_bbox->y);
}

method get_size_request() {
	return ($self->page_bbox->width, $self->page_bbox->height);
}


with qw(
	Renard::Curie::Model::View::Role::ForDocument
	Renard::Curie::Model::View::Role::Pageable
	Renard::Curie::Model::View::Role::Zoomable
);

1;
