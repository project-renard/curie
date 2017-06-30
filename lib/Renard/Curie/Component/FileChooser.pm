use Renard::Curie::Setup;
package Renard::Curie::Component::FileChooser;
# ABSTRACT: Component that implements a file chooser dialog

use Moo;
use Renard::Curie::Helper;
use Renard::Curie::Types qw(InstanceOf);

=attr all_filter

A L<Gtk3::FileFilter> that displays all files.

=cut
has all_filter => (
	is => 'lazy', # _build_all_filter
	isa => InstanceOf['Gtk3::FileFilter'],
);

=attr pdf_filter

A L<Gtk3::FileFilter> that displays only C<application/pdf> files.

=cut
has pdf_filter => (
	is => 'lazy', # _build_pdf_filter
	isa => InstanceOf['Gtk3::FileFilter'],
);

method _build_all_filter() :ReturnType(InstanceOf['Gtk3::FileFilter']) {
	my $filter = Gtk3::FileFilter->new;
	$filter->set_name("All files");
	$filter->add_pattern("*");

	return $filter;
}

method _build_pdf_filter() :ReturnType(InstanceOf['Gtk3::FileFilter']) {
	my $filter = Gtk3::FileFilter->new;
	$filter->set_name("PDF files");
	$filter->add_mime_type("application/pdf");

	return $filter;
}

=method get_open_file_dialog

  method get_open_file_dialog() :ReturnType(InstanceOf['Gtk3::FileChooserDialog'])

Returns an instance of L<Gtk3::FileChooserDialog> for opening files.

=cut
method get_open_file_dialog() :ReturnType(InstanceOf['Gtk3::FileChooserDialog']) {
	my $dialog = Gtk3::FileChooserDialog->new(
		"Open File",
		$self->main_window->window,
		'GTK_FILE_CHOOSER_ACTION_OPEN',
		'gtk-cancel' => 'cancel',
		'gtk-open' => 'accept',
	);

	return $dialog;
}

=method get_open_file_dialog_with_filters

  method get_open_file_dialog_with_filters() :ReturnType(InstanceOf['Gtk3::FileChooserDialog'])

Same as L</get_open_file_dialog> but with the following filters added:

=for :list
* L</pdf_filter>
* L</all_filter>

=cut
method get_open_file_dialog_with_filters() :ReturnType(InstanceOf['Gtk3::FileChooserDialog']) {
	my $dialog = $self->get_open_file_dialog;

	$dialog->add_filter( $self->pdf_filter );
	$dialog->add_filter( $self->all_filter );

	return $dialog;
}

with qw(
	Renard::Curie::Component::Role::HasParentMainWindow
);

1;
