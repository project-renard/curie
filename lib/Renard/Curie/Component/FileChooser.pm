use Modern::Perl;
package Renard::Curie::Component::FileChooser;

use Moo;

has app => ( is => 'ro', required => 1, weak_ref => 1 );

has all_filter => ( is => 'lazy' ); # _build_all_filter

has pdf_filter => ( is => 'lazy' ); # _build_pdf_filter

sub _build_all_filter {
	my ($self) = @_;

	my $filter = Gtk3::FileFilter->new();
	$filter->set_name("All files");
	$filter->add_pattern("*");

	return $filter;
}

sub _build_pdf_filter {
	my ($self) = @_;

	my $filter = Gtk3::FileFilter->new();
	$filter->set_name("PDF files");
	$filter->add_mime_type("application/pdf");

	return $filter;
}

sub get_open_file_dialog {
	my ($self) = @_;

	my $dialog = Gtk3::FileChooserDialog->new(
		"Open File",
		$self->app->window,
		'GTK_FILE_CHOOSER_ACTION_OPEN',
		'gtk-cancel' => 'cancel',
		'gtk-open' => 'accept',
	);

	return $dialog;
}

sub get_open_file_dialog_with_filters {
	my ($self) = @_;

	my $dialog = $self->get_open_file_dialog;

	$dialog->add_filter( $self->pdf_filter );
	$dialog->add_filter( $self->all_filter );

	return $dialog;
}

1;
