use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::MainWindow::Role::MenuBar;
# ABSTRACT: Role for menu bar

use Moo::Role;

use Renard::Curie::Component::MenuBar;
use Renard::Curie::Component::FileChooser;
use Renard::Incunabula::Common::Types qw(InstanceOf DocumentModel);

use Glib 'TRUE', 'FALSE';

=attr menu_bar

A L<Renard::Curie::Component::MenuBar> for the application's menu-bar.

=cut
has menu_bar => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Component::MenuBar'],
);


before setup_window => method() {
	$self->builder->get_object('application-vbox')
		->pack_start( $self->menu_bar, FALSE, TRUE, 0 );
};

after open_document => method( (DocumentModel) $doc ) {
	if( $doc->can('filename_uri') ) {
		my $rm_added = $self->menu_bar->recent_manager->add_item( $doc->filename_uri );
	}
};

=callback on_open_file_dialog_cb

  callback on_open_file_dialog_cb( $event, $self )

Callback that opens a L<Renard::Curie::Component::FileChooser> component.

=cut
callback on_open_file_dialog_cb( $event, $self ) {
	my $file_chooser = Renard::Curie::Component::FileChooser->new( main_window => $self );
	my $dialog = $file_chooser->get_open_file_dialog_with_filters;

	my $result = $dialog->run;

	if ( $result eq 'accept' ) {
		my $filename = $dialog->get_filename;
		$dialog->destroy;
		$self->view_manager->open_pdf_document($filename);
	} else {
		$dialog->destroy;
	}
}


1;
