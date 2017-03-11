use Renard::Curie::Setup;
package Renard::Curie::Model::View::SinglePage;
# ABSTRACT: TODO

use Moo;
use Renard::Curie::Types qw(RenderablePageModel InstanceOf);

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
	my $rp = $self->rendered_page;

	my $img = $rp->cairo_image_surface;

	$cr->set_source_surface($img, ($widget->get_allocated_width -
		$rp->width) / 2, 0);
	$cr->paint;

	$widget->set_size_request(
		$rp->width,
		$rp->height );
}

method update_scroll_adjustment(
	(InstanceOf['Gtk3::Adjustment']) $hadjustment,
	(InstanceOf['Gtk3::Adjustment']) $vadjustment,
	) {

	say join "; ",
		map {
			my $list = join ", ", (
				$_->get_lower,
				$_->get_value,
				$_->get_value + $_->get_page_size,
				$_->get_upper,
			);
			"[ $list ]";
		} ($hadjustment, $vadjustment);
}

with qw(
	Renard::Curie::Model::View::Role::ForDocument
	Renard::Curie::Model::View::Role::Pageable
	Renard::Curie::Model::View::Role::Zoomable
);

1;
