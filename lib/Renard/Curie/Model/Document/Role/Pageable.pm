use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::Pageable;

use Moo::Role;
use Renard::Curie::Types qw(PageNumber);

=attr first_page_number

An C<Int> containing the first page number of the PDF document.
This is always C<1>.

=cut
has first_page_number => (
	is => 'ro',
	isa => PageNumber,
	default => 1,
);


=attr last_page_number

An C<Int> containing the last page number of the PDF document.

=cut
has last_page_number => (
	is => 'lazy', # _build_last_page_number
	isa => PageNumber,
);


1;
