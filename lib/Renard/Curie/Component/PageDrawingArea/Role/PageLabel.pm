use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::PageLabel;
# ABSTRACT: A role for the number of pages label

use Moo::Role;

after BUILD => method(@) {
	$self->setup_number_of_pages_label;
};

=method setup_number_of_pages_label

  method setup_number_of_pages_label()

Sets up the label that shows the number of pages in the document.

=cut
method setup_number_of_pages_label() {
	$self->builder->get_object("number-of-pages-label")
		->set_text( $self->view->document->number_of_pages );
}

1;
