use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::PageEntry;
# ABSTRACT: A role for the text entry box for the page number

use Moo::Role;

after BUILD => method(@) {
	$self->setup_text_entry_events;
};

=method setup_text_entry_events

  method setup_text_entry_events()

Sets up the signals for the text entry box so the user can enter in page
numbers.

=cut
method setup_text_entry_events() {
	$self->builder->get_object('page-number-entry')->signal_connect(
		activate => \&on_activate_page_number_entry_cb, $self );
}

=callback on_activate_page_number_entry_cb

  callback on_activate_page_number_entry_cb( $entry, $self )

Callback that is called when text has been entered into the page number entry.

=cut
callback on_activate_page_number_entry_cb( $entry, $self ) {
	my $text = $entry->get_text;
	if( $self->view->document->is_valid_page_number($text) ) {
		$self->view->page_number( $text );
	} else {
		Renard::Curie::Error::User::InvalidPageNumber->throw({
			payload => {
				text => $text,
				range => [
					$self->view->document->first_page_number,
					$self->view->document->last_page_number
				],
			}
		});
	}
}

1;
