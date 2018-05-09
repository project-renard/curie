use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::MainWindow::Role::ActionNotebookWindow;
# ABSTRACT: Role for action notebook window

use Moo::Role;
use Renard::Curie::Component::ActionNotebookWindow;
use Renard::Incunabula::Common::Types qw(InstanceOf);

use Renard::Curie::Component::TextRanker;

use Glib 'TRUE', 'FALSE';

requires 'content_box';

=attr action_notebook_window

A L<Renard::Curie::Component::ActionNotebookWindow>.

=cut
has action_notebook_window => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Component::ActionNotebookWindow'],
);

after setup_window => method() {
	$self->action_notebook_window->append_notebook_tab(
		"Text ranker",
		Renard::Curie::Component::TextRanker->new(
			view_manager => $self->view_manager
		),
	);

	$self->action_notebook_window->show_all;
};

1;
