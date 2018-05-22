use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager;
# ABSTRACT: Manages the currently open views

use Moo;
use Renard::Incunabula::Common::Types qw(InstanceOf Path FileUri PositiveInt PositiveOrZeroInt);
use Renard::Incunabula::Document::Types qw(DocumentModel ZoomLevel);
use Renard::Incunabula::Format::PDF::Document;

use Glib::Object::Subclass
	'Glib::Object',
	signals => {
		'document-changed' => {
			param_types => [
				'Glib::Scalar', # DocumentModel
			]
		},
		'update-view' => {
			param_types => [
				'Glib::Scalar', # View
			]
		},
	},
	;


with qw(
	Renard::Curie::ViewModel::ViewManager::Role::Document

	Renard::Curie::ViewModel::ViewManager::Role::ViewOptions
	Renard::Curie::ViewModel::ViewManager::Role::GridView
	Renard::Curie::ViewModel::ViewManager::Role::Zoom

	Renard::Curie::ViewModel::ViewManager::Role::TTS
	Renard::Curie::ViewModel::ViewManager::Role::PhraseCloze
	Renard::Curie::ViewModel::ViewManager::Role::CardReview
);

1;
