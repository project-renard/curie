use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::ReviewControl;
# ABSTRACT: Control for reviewing flashcards

use Moo;
use MooX::Lsub;

use Renard::Incunabula::Common::Types qw(InstanceOf);

use Glib::Object::Subclass
	'Gtk3::Bin';

use Glib qw(TRUE FALSE);
use List::UtilsBy qw(nsort_by);

use constant
METHOD_RADIO_BUTTON => {
	sequential => "radio-schedule-sequential",
	random     => "radio-schedule-random",
	srs        => "radio-schedule-srs",
};

=attr view_manager

The view manager model for this application.

=cut
has view_manager => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::ViewModel::ViewManager'],
	handles => {
		view => current_view =>,
	},
);

method BUILD(@) {
	$self->add( $self->builder->get_object('review-control-box'));

	$self->builder->get_object('button-next')->signal_connect(
		clicked => callback($button, $self) {
			$self->view_manager->next_card;
		},
		$self,
	);
	for my $method (keys %{ METHOD_RADIO_BUTTON() }) {
		my $button_id = METHOD_RADIO_BUTTON->{$method};

		$self->builder->get_object($button_id)->signal_connect(
			toggled => callback($button) {
				if( $button->get_active ) {
					$self->view_manager->set_method($method);
				}
			}
		);
	}
}

method update_buttons() {
	$self->builder->get_object("button-start")->set_label(
		$self->view_manager->is_running_review ? 'Stop review' : 'Start review'
	);
}

classmethod FOREIGNBUILDARGS(@) {
	();
}

with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName
);

1;
