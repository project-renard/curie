use Renard::Curie::Setup;
package Renard::Curie::Model::Page::Role::Bounds;
# ABSTRACT: Role for pages that have a height and width

use Moo::Role;

=attr width

An C<PositiveOrZeroInt> which represents the width of the page in pixels.

=cut
requires 'width';

=attr height

An C<PositiveOrZeroInt> which represents the height of the page in pixels.

=cut
requires 'height';

1;
