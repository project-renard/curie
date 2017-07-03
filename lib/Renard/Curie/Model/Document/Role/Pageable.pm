use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::Pageable;
# ABSTRACT: Role for documents that have numbered pages

use Moo::Role;
use Renard::Curie::Types qw(PageNumber PageCount Bool);
use MooX::Lsub;

=attr first_page_number

A C<PageNumber> containing the first page number of the document.
This is always C<1>.

=cut
has first_page_number => (
	is => 'ro',
	isa => PageNumber,
	default => 1,
);


=attr last_page_number

A C<PageNumber> containing the last page number of the document.

=cut
has last_page_number => (
	is => 'lazy', # _build_last_page_number
	isa => PageNumber,
);

=method is_valid_page_number

  method is_valid_page_number( $page_number ) :ReturnType(Bool)

Returns true if C<$page_number> is a valid C<PageNumber> and is between the
first and last page numbers inclusive.

=cut
method is_valid_page_number( $page_number ) :ReturnType(Bool) {
	# uncoverable condition right
	PageNumber->check($page_number)
		&& $page_number >= $self->first_page_number
		&& $page_number <= $self->last_page_number
}

=attr number_of_pages

  isa => PageCount

Calculates the number of pages between the C<first_page_number> and C<last_page_number>.

=cut
lsub number_of_pages => method() {
	(PageCount)->(
		$self->last_page_number - $self->first_page_number + 1
	);
};


1;
