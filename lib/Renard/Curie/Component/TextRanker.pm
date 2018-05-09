use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::TextRanker;
# ABSTRACT: Process text for keyphrases

use Moo;
use Renard::Incunabula::Common::Types qw(InstanceOf AbsDir);

use Glib::Object::Subclass
	'Gtk3::Bin';

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

=method BUILD

Constructor that sets up the view and model.

=cut
method BUILD(@) {
	$self->builder->get_object('text-ranker-refresh')->signal_connect(
		clicked => fun() {
			my $text = $self->view_manager->current_text_page;
			use Alien::Poppler;
			use Capture::Tiny qw(capture_merged);
			my $pdftotext = Alien::Poppler->pdftotext_path;

			my ($merged, $result) = capture_merged {
				system($pdftotext, $self->view_manager->current_document->filename , qw(-));
			};
			#my $page_number = $self->view_manager->current_view->page_number;
			#my $txt = $self->view_manager->current_document->get_textual_page($page_number);
			my $txt = $merged;
			use Renard::Incunabula::NLP::PyTextRank;
			my $tr = Renard::Incunabula::NLP::PyTextRank->new();
			my $data = $tr->get_text_rank( $txt );
			use Data::Dumper; my $output = Dumper $data;
			$self->builder->get_object('text-ranker-textview')
				->get_buffer
				->set_text( $output );
				#->set_text(join "\n",('abc'x100)x100)
		}
	);
	$self->add( $self->builder->get_object('text-ranker-box') );
}

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Initialises the L<Gtk3::Bin> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}

with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName
);

1;