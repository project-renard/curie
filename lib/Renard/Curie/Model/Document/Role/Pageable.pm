use Modern::Perl;
package Renard::Curie::Model::Document::Role::Pageable;

use Moo::Role;

=attr first_page_number

An C<Int> containing the first page number of the PDF document.
This is always C<1>.

=cut
has first_page_number => ( is => 'ro', default => sub { 1 } );


=attr last_page_number

An C<Int> containing the last page number of the PDF document.

=cut
has last_page_number => (
	is => 'lazy', # _build_last_page_number
	);


1;
