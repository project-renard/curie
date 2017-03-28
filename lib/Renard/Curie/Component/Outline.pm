use Renard::Curie::Setup;
package Renard::Curie::Component::Outline;
# ABSTRACT: Component that provides a list of headings for navigating

use Moo;
use Glib::Object::Subclass 'Gtk3::Revealer';
use Glib 'TRUE', 'FALSE';
use Renard::Curie::Types qw(InstanceOf PageNumber);
use Function::Parameters;

=attr tree_view

The L<Gtk3::TreeView> component that displays the interactive tree.

=cut
has tree_view => (
	is => 'rw',
	isa => InstanceOf['Gtk3::TreeView'],
);

=attr model

The L<Gtk3::TreeStore> that holds tree data of heading text and page numbers.

When set, triggers an update to the model for L</tree_view>.

=cut
has model => (
	is => 'rw',
	trigger => 1, # _trigger_model
	isa => InstanceOf['Gtk3::TreeStore'],
);

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Builds the L<Gtk3::Revealer> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}

=method BUILD

Constructor that sets up the view and model.

This class is a subclass of L<Gtk3::Revealer> which allows the visible state to
be toggled.

=cut
method BUILD(@) {
	my $frame = Gtk3::Frame->new('Outline');
	my $scrolled_window = Gtk3::ScrolledWindow->new;
	$scrolled_window->set_vexpand(TRUE);
	$scrolled_window->set_hexpand(TRUE);
	$scrolled_window->set_policy( 'automatic', 'automatic');

	$self->tree_view( Gtk3::TreeView->new );

	my $text_column = Gtk3::TreeViewColumn->new_with_attributes(
		'Heading',
		Gtk3::CellRendererText->new,
		text => 0 );
	my $page_number = Gtk3::TreeViewColumn->new_with_attributes(
		'Page',
		Gtk3::CellRendererText->new,
		text => 1 );

	$self->tree_view->insert_column($text_column, 0);
	$self->tree_view->insert_column($page_number, 1);

	$self->tree_view->set( 'headers-visible', FALSE );

	$self->tree_view->signal_connect(
		'row-activated' => \&on_tree_view_row_activate_cb, $self );

	$self->set_transition_type( 'slide-right' );

	$scrolled_window->add( $self->tree_view );
	$frame->add( $scrolled_window );
	$self->add( $frame );
	$self->reveal( FALSE );
}

=method update

  method update( $doc )

Updates the outline's model to correspond to the outline of the currently
displayed document.

=cut
method update( $doc ) {
	return unless $doc->DOES('Renard::Curie::Model::Document::Role::Outlineable');
	$self->model( $doc->outline->tree_store );
}

=method _trigger_model

  method _trigger_model($new_model)

Trigger that updates the model for the underlying L<tree_view> attribute.

=cut
method _trigger_model($new_model) {
	$self->tree_view->set_model( $new_model );
}

=callback on_tree_view_row_activate_cb

  fun on_tree_view_row_activate_cb( $tree_view, $path, $column, $self )

Callback that navigates the current document to the position that corresponds
to a row of the tree that has been clicked.

=cut
fun on_tree_view_row_activate_cb( $tree_view, $path, $column, $self ) {
	# NOTE : This needs more error checking.

	my $pd = $self->app->page_document_component;

	my $iter = $self->model->get_iter( $path );
	my $page_num = $self->model->get_value($iter, 1);

	PageNumber->check($page_num) and $pd->current_page_number( $page_num );
}

=method reveal

  method reveal( $should_reveal )

Wrapper around the L<Gtk3::Revealer::set_reveal_child> method that sets the
C<hexpand> property for this widget at the same time so that the parent
container gives an appropriate amount of width to the widget.

Without this, the revealer widget may still expand to take up some space when
the child is not visible.

=cut
method reveal( $should_reveal ) {
	$self->set( 'hexpand' => $should_reveal );
	$self->set_reveal_child( $should_reveal );
}

with qw(
	Renard::Curie::Component::Role::HasParentApp
);

1;
