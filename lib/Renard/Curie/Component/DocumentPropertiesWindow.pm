use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::DocumentPropertiesWindow;
# ABSTRACT: Component that implements a dialog with document metadata

use Moo;
use Glib 'TRUE', 'FALSE';
use Renard::Incunabula::Frontend::Gtk3::Helper;
use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Incunabula::Document::Types qw(DocumentModel);
use Renard::Incunabula::Format::PDF::InformationDictionary;

=attr document

A C<DocumentModel> that will be used to retrieve the document metadata.

=cut
has document => (
	is => 'ro',
	isa => DocumentModel,
	required => 1,
);

has _pdf_information_dictionary => (
	is => 'lazy',
	isa => InstanceOf['Renard::Incunabula::Format::PDF::InformationDictionary'],
);

method _build__pdf_information_dictionary() {
	my $filename = $self->document->filename;

	Renard::Incunabula::Format::PDF::InformationDictionary->new(
		filename => $filename,
	);
}

=method BUILD

  method BUILD

Initialises the proprieties window.

=cut
method BUILD(@) {
	my $log_win = $self->builder->get_object('prop-window');
	my $title = sprintf "Properties for %s", $self->document->filename;
	$log_win->set_title($title);
	$log_win->set_default_size(300, 300);

	my $prop_grid = $self->builder->get_object('prop-grid');
	$prop_grid->set_column_spacing(5);

	my $props = $self->_pdf_information_dictionary->default_properties;
	my $row = 0;
	for my $prop_key (@$props) {
		my $prop_value = $self->_pdf_information_dictionary->$prop_key();
		my $label_key = Gtk3::Label->new(
			"<b>$prop_key</b>"
		);
		$label_key->set_use_markup(TRUE);
		my $label_value = Gtk3::Label->new(
			$prop_value
		);

		for my $label ($label_key, $label_value) {
			$label->set_line_wrap(TRUE);
			if( $label->can('set_xalign' ) ) {
				# for Gtk3 >= 3.16
				$label->set_xalign(0.0);
				$label->set_yalign(0.0);
			} else {
				# for Gtk3 <= 3.14
				$label->set_alignment(0.0, 0.0);
			}
		}
		$label_value->set_selectable(TRUE);

		$prop_grid->attach($label_key, 0, $row, 1, 1);
		$prop_grid->attach($label_value, 1, $row, 1, 1);

		$row++;
	}

	$self->builder->get_object('prop-ok-button')->signal_connect(
		clicked => sub { $log_win->destroy }
	);

	$self->builder->get_object('prop-ok-button')->grab_focus;
}

=method show_all

  method show_all()

Shows the window with the document properties.

=cut
method show_all() {
	$self->builder->get_object('prop-window')->show_all;
}


with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName
);


1;
