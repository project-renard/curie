use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::MainWindow::Role::DragAndDrop;
# ABSTRACT: Role for drag-and-drop

use Moo::Role;
use MooX::Lsub;

use URI::file;

lsub DND_TARGET_URI_LIST => sub { 0 };
lsub DND_TARGET_TEXT     => sub { 1 };

requires 'content_box';

after BUILD => method() {
	$self->setup_dnd;
};

=method setup_dnd

  method setup_dnd()

Setup drag and drop.

=cut
method setup_dnd() {
	$self->content_box->drag_dest_set('all', [], 'copy');
	my $target_list = Gtk3::TargetList->new([
		Gtk3::TargetEntry->new( 'text/uri-list', 0, $self->DND_TARGET_URI_LIST ),
		Gtk3::TargetEntry->new( 'text/plain'   , 0, $self->DND_TARGET_TEXT     )
	]);
	$self->content_box->drag_dest_set_target_list($target_list);

	$self->content_box->signal_connect('drag-data-received' =>
		\&on_drag_data_received_cb, $self );
}

=callback on_drag_data_received_cb

  on_drag_data_received_cb

Whenever the drag and drop data is received by the application.

=cut
callback on_drag_data_received_cb( $widget, $context, $x, $y, $data, $info, $time, $self ) {
	my $pdf_filename_text;

	if( $info == $self->DND_TARGET_URI_LIST ) {
		my @uris = @{ $data->get_uris };
		$pdf_filename_text = $uris[0];
	} elsif( $info == $self->DND_TARGET_TEXT ) {
		my $text = $data->get_text;
		if( $text =~ /^file:/ ) {
			$pdf_filename_text = $text;
		} else {
			warn "Do not know what to do with text drag-and-drop data: $text";
		}
	}

	if( defined $pdf_filename_text ) {
		$self->view_manager->open_document_as_file_uri(
			URI->new($pdf_filename_text, 'file')
		);
	}
}

1;
