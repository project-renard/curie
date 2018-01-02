use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Role::Pageable;
# ABSTRACT: Role for view models that are paged

use Moo::Role;
use Renard::Incunabula::Common::Types qw(Bool);
use Renard::Incunabula::Document::Types qw(PageNumber);

=attr page_number

A L<PageNumber|Renard::Incunabula::Document::Types/PageNumber> for the current page being
drawn.

=cut
has page_number => (
	is => 'rw',
	isa => PageNumber,
	default => 1,
	trigger => 1 # _trigger_page_number
	);

=begin comment

=method _trigger_page_number

  method _trigger_page_number($new_page_number)

Called whenever the L</page_number> is changed. This allows for telling
the component to retrieve the new page and redraw.

=end comment

=cut
requires '_trigger_page_number';

=method set_current_page_to_first

  method set_current_page_to_first()

Sets the page number to the first page of the document.

=cut
method set_current_page_to_first() {
	$self->page_number( $self->document->first_page_number );
}

=method set_current_page_to_last

  method set_current_page_to_last()

Sets the current page to the last page of the document.

=cut
method set_current_page_to_last() {
	$self->page_number( $self->document->last_page_number );
}

=method can_move_to_previous_page

  method can_move_to_previous_page() :ReturnType(Bool)

Predicate to check if we can decrement the current page number.

=cut
method can_move_to_previous_page() :ReturnType(Bool) {
	$self->page_number > $self->document->first_page_number;
}

=method can_move_to_next_page

  method can_move_to_next_page() :ReturnType(Bool)

Predicate to check if we can increment the current page number.

=cut
method can_move_to_next_page() :ReturnType(Bool) {
	$self->page_number < $self->document->last_page_number;
}

=method set_current_page_forward

  method set_current_page_forward()

Increments the current page number if possible.

=cut
method set_current_page_forward() {
	if( $self->can_move_to_next_page ) {
		$self->page_number( $self->page_number + 1 );
	}
}

=method set_current_page_back

  method set_current_page_back()

Decrements the current page number if possible.

=cut
method set_current_page_back() {
	if( $self->can_move_to_previous_page ) {
		$self->page_number( $self->page_number - 1 );
	}
}

1;
