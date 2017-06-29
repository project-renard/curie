use Renard::Curie::Setup;
package Renard::Curie::Component::MainWindow::Role::PageDrawingArea;
# ABSTRACT: Role for the page drawing area

use Moo::Role;
use Renard::Curie::Component::PageDrawingArea;
use Renard::Curie::Types qw(InstanceOf DocumentModel);

use Glib 'TRUE', 'FALSE';

requires 'content_box';

=attr page_document_component

A L<Renard::Curie::Component::PageDrawingArea> that holds the currently
displayed document.

=for :list
* Predicate: C<has_page_document_component>
* Clearer: C<clear_page_document_component>

=for Pod::Coverage has_page_document_component clear_page_document_component

=cut
has page_document_component => (
	is => 'rw',
	isa => InstanceOf['Renard::Curie::Component::PageDrawingArea'],
	trigger => 1, # _trigger_page_document_component
	predicate => 1, # has_page_document_component
	clearer => 1 # clear_page_document_component
);

before page_document_component => method($new_value = undef) {
	if( defined $new_value && $self->has_page_document_component ) {
		$self->content_box->remove( $self->page_document_component );
		$self->clear_page_document_component;
	}
};

method _trigger_page_document_component($new_pd) {
	$self->content_box->pack_start( $new_pd, TRUE, TRUE, 0 );
	$new_pd->show_all;
}

=method open_document

  method open_document( (DocumentModel) $doc )

Sets the document for the application's L</page_document_component>.

=cut
method open_document( (DocumentModel) $doc ) {
	$self->page_document_component(
		Renard::Curie::Component::PageDrawingArea->new(
			document => $doc,
		)
	);

	if( $doc->can('filename') ) {
		$self->window->set_title( $doc->filename );
	}
}

1;
