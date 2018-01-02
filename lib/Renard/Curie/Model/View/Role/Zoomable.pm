use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Role::Zoomable;
# ABSTRACT: Role for view models that support zooming

use Moo::Role;
use Renard::Incunabula::Document::Types qw(ZoomLevel);

=attr zoom_level

A L<ZoomLevel|Renard::Incunabula::Document::Types/ZoomLevel> for the current zoom level for
the document.

=cut
has zoom_level => (
	is => 'rw',
	isa => ZoomLevel,
	default => 1.0,
	trigger => 1 # _trigger_zoom_level
	);

=begin comment

=method _trigger_zoom_level

  method _trigger_zoom_level($new_zoom_level)

Called whenever the L</zoom_level> is changed. This tells the component to
redraw the current page at the new zoom level.

=end comment

=cut
requires '_trigger_zoom_level';

1;
