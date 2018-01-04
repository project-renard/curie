use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::ViewOptions::Zoom::Percentage;
# ABSTRACT: A set of options for zooming by a fixed amount

use Moo;
use Renard::Incunabula::Document::Types qw(ZoomLevel);

extends 'Renard::Curie::Model::ViewOptions::Zoom';

=attr zoom_level

The amount to zoom as C<ZoomLevel>.

=cut
has zoom_level => (
	is => 'ro',
	required => 1,
	isa => ZoomLevel,
);

1;
