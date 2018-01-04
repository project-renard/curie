use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::MainWindow::Role::Outline;
# ABSTRACT: Role for outline

use Moo::Role;
use Renard::Curie::Component::Outline;
use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Incunabula::Document::Types qw(DocumentModel);

use Glib 'TRUE', 'FALSE';

requires 'content_box';

=attr outline

A L<Renard::Curie::Component::Outline> which makes up the outline sidebar for
this window.

=cut
has outline => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Component::Outline'],
);

after setup_window => method() {
	$self->content_box->pack_start( $self->outline , FALSE, TRUE, 0 );
};

after open_document => method( (DocumentModel) $doc ) {
	$self->outline->update( $doc );
};

1;
