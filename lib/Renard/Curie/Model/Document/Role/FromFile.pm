use Modern::Perl;
package Renard::Curie::Model::Document::Role::FromFile;

use Moo::Role;

=attr filename

A C<Str> containing the path to the PDF document.

=cut
has filename => ( is => 'ro' );

1;
