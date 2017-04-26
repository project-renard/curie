use Renard::Curie::Setup;
package Renard::Curie::Model::View::ContinuousPage;
# ABSTRACT: TODO

use Moo;
use Renard::Curie::Types qw(RenderablePageModel InstanceOf);
use POSIX qw(ceil);

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

=method draw_page

TODO

=cut
method draw_page(
	(InstanceOf['Gtk3::DrawingArea']) $widget,
	(InstanceOf['Cairo::Context']) $cr
) {
	my $p =  $widget->get_parent;
	my $v = $p->get_vadjustment;

	my $view_y_min = $v->get_value;
	my $view_y_max = $v->get_value + $v->get_page_size;

	$self->widget_dims([
		$widget->get_allocated_width,
		$widget->get_allocated_height,
	]);
	$self->_clear_page_info;
	my $page_xy = $self->_page_info->{page_xy};
	my $zoom_level = $self->zoom_level;
	for my $page (@$page_xy) {
		next if $page->{bbox}[3] < $view_y_min
			|| $page->{bbox}[1] > $view_y_max;

		my $rp = $self->document->get_rendered_page(
			page_number => $page->{pageno},
			zoom_level => $zoom_level,
		);

		my $img = $rp->cairo_image_surface;

		$cr->set_source_surface($img,
			$page->{bbox}[0],
			$page->{bbox}[1]);

		$cr->paint;
	}

=begin comment

	my $img = $rp->cairo_image_surface;

	$cr->set_source_surface($img, ($widget->get_allocated_width -
		$rp->width) / 2, 0);
	$cr->paint;

	$widget->set_size_request(
		$rp->width,
		$rp->height );

=cut
}

method _trigger_page_number($new_page_number) {
	$self->signal_emit( 'view-changed' );
}

method _trigger_zoom_level($new_zoom_level) {
	$self->_clear_page_info;
	$self->signal_emit( 'view-changed' );
}

has widget_dims => (
	is => 'rw',
	default => sub { [0, 0] },
);

has _page_info => (
	is => 'lazy',
	clearer => 1, # _clear_page_info
);

method _build__page_info() {
	my $interpage = 10;
	my $page_xy = $self->document->identity_bounds;
	my $largest_x = 0;
	my $y_so_far = 0;
	for my $page (@$page_xy) {
		# multiply to account for zoom-level
		my $w = ceil($page->{dims}{w} * $self->zoom_level);
		my $h = ceil($page->{dims}{h} * $self->zoom_level);

		$page->{bbox} = [-1, -1, -1, -1];

		# xmin
		$page->{bbox}[0] = ($self->widget_dims->[0] - $w) / 2;
		# ymin
		$page->{bbox}[1] = $y_so_far;
		# xmax
		$page->{bbox}[2] = $page->{bbox}[0] + $w;
		# ymax
		$page->{bbox}[3] = $y_so_far + $h;

		if( $w > $largest_x ) {
			$largest_x = $w;
		}

		$y_so_far += $h + $interpage;
	}
	my $total_y = $y_so_far - $interpage;

	return {
		page_xy => $page_xy,
		total_y => $total_y,
		largest_x => $largest_x,
	};
}

method get_size_request() {
	my $page_info = $self->_page_info;
	return ( $page_info->{largest_x}, $page_info->{total_y} );
}

with qw(
	Renard::Curie::Model::View::Role::ForDocument
	Renard::Curie::Model::View::Role::Pageable
	Renard::Curie::Model::View::Role::Zoomable
);

1;
