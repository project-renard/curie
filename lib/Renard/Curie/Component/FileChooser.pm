use Renard::Curie::Setup;
package Renard::Curie::Component::FileChooser;

use Moo;
use Renard::Curie::Types qw(InstanceOf);
use Function::Parameters;

has app => (
	is => 'ro',
	isa => InstanceOf['Renard::Curie::App'],
	required => 1,
	weak_ref => 1
);

has all_filter => (
	is => 'lazy', # _build_all_filter
	isa => InstanceOf['Gtk3::FileFilter'],
);

has pdf_filter => (
	is => 'lazy', # _build_pdf_filter
	isa => InstanceOf['Gtk3::FileFilter'],
);

method _build_all_filter :ReturnType(InstanceOf['Gtk3::FileFilter']) {
	my $filter = Gtk3::FileFilter->new;
	$filter->set_name("All files");
	$filter->add_pattern("*");

	return $filter;
}

method _build_pdf_filter :ReturnType(InstanceOf['Gtk3::FileFilter']) {
	my $filter = Gtk3::FileFilter->new;
	$filter->set_name("PDF files");
	$filter->add_mime_type("application/pdf");

	return $filter;
}

method get_open_file_dialog() :ReturnType(InstanceOf['Gtk3::FileChooserDialog']) {
	my $dialog = Gtk3::FileChooserDialog->new(
		"Open File",
		$self->app->window,
		'GTK_FILE_CHOOSER_ACTION_OPEN',
		'gtk-cancel' => 'cancel',
		'gtk-open' => 'accept',
	);

	return $dialog;
}

method get_open_file_dialog_with_filters() :ReturnType(InstanceOf['Gtk3::FileChooserDialog']) {
	my $dialog = $self->get_open_file_dialog;

	$dialog->add_filter( $self->pdf_filter );
	$dialog->add_filter( $self->all_filter );

	return $dialog;
}

1;
