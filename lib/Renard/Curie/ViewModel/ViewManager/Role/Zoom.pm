use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::Zoom;
# ABSTRACT: A role for zoom

use Moo::Role;

use Renard::Incunabula::Document::Types qw(ZoomLevel);
use Renard::Curie::Model::ViewOptions::Zoom::Percentage;

=method set_zoom_level

  method set_zoom_level( (ZoomLevel) $zoom_level )

Sets the L</current_view> to L<Renard::Curie::Model::View::Grid> with C<zoom_level>
of L<Renard::Curie::Model::ViewOptions::Zoom::Percentage> set to C<$zoom_level>.

=cut
method set_zoom_level( (ZoomLevel) $zoom_level ) {
	my $zoom_option = Renard::Curie::Model::ViewOptions::Zoom::Percentage->new(
		zoom_level => $zoom_level,
	);
	my $view_options = $self->view_options->cset(
		zoom_options => $zoom_option
	);
	$self->view_options( $view_options );
}

1;
