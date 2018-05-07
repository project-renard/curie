use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::MainWindow;
# ABSTRACT: Main window of the application

use Renard::Incunabula::Frontend::Gtk3::Helper;

use Gtk3;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';

use Moo 2.001001;

use MooX::Role::Logger ();
use MooX::Lsub;

use Renard::Incunabula::Common::Types qw(InstanceOf Path Str);
use Renard::Incunabula::Document::Types qw(DocumentModel);

use IO::Async::Loop::Glib;

=attr loop

Glib event loop.

=cut
has loop => ( is => 'lazy' );

sub _build_loop {
	IO::Async::Loop::Glib->new;
}

=attr window

A L<Gtk3::Window> that contains the main window for the application.

=cut
lsub window => method() { # :ReturnType(InstanceOf['Gtk3::Window'])
	(InstanceOf['Gtk3::Window'])->(
		$self->builder->get_object('main-window')
	);
};

=attr content_box

A horizontal L<Gtk3::Box> which is used to split the main application area into
two different regions.

The left region contains L</outline> and the right region contains L</page_document_component>.

=cut
lsub content_box => method() { # :ReturnType(InstanceOf['Gtk3::Box'])
	(InstanceOf['Gtk3::Box'])->(
		Gtk3::Box->new( 'horizontal', 0 )
	);
};

=method setup_window

  method setup_window()

Sets up components that make up the window shell for the application
including:

=for :list
* L</menu_bar>
* L</content_box>
* L</log_window>

=cut
method setup_window() {
	$self->builder->get_object('application-vbox')
		->pack_start( $self->content_box, TRUE, TRUE, 0 );
}

=method show_all

  method show_all()

Shows the C<window> widget of this component and its subwidgets.

=cut
method show_all() {
	$self->window->show_all;
}

=method BUILD

  method BUILD

Initialises the application and sets up signals.

=cut
method BUILD(@) {
	$self->setup_window;

	$self->window->signal_connect(
		destroy => \&on_application_quit_cb, $self );
	$self->window->set_default_size( 800, 600 );
}

# Callbacks {{{
=callback on_application_quit_cb

  callback on_application_quit_cb( $event, $self )

Callback that stops the L<Gtk3> main loop.

=cut
callback on_application_quit_cb( $event, $self ) {
	Gtk3::main_quit;
}
# }}}

with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName
	MooX::Role::Logger

	Renard::Curie::Component::MainWindow::Role::PageDrawingArea

	Renard::Curie::Component::MainWindow::Role::DragAndDrop
	Renard::Curie::Component::MainWindow::Role::LogWindow
	Renard::Curie::Component::MainWindow::Role::AccelMap
	Renard::Curie::Component::MainWindow::Role::MenuBar
	Renard::Curie::Component::MainWindow::Role::Outline
	Renard::Curie::Component::MainWindow::Role::TTSWindow
	Renard::Curie::Component::MainWindow::Role::ExceptionHandler
);

1;
