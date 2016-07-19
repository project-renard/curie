use Renard::Curie::Setup;
package Renard::Curie::Component::Outline;

# TODO
# - Create an Model::Outline.
# - Role for documents that have an outline.
# - Sidebar list <https://metacpan.org/pod/Gtk3::SimpleList>.
# - Make sure that the menu-item-view-sidebar object matches the state of the Revealer.
use Moo;
use Glib::Object::Subclass 'Gtk3::Revealer';
use Glib 'TRUE', 'FALSE';
use Function::Parameters;

=attr tree_view

TODO

=cut
has tree_view => (
	is => 'rw'
);

=attr model

TODO

=cut
has model => (
	is => 'rw'
);

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Builds the L<Gtk3::Revealer> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}

=method BUILD

TODO

=cut
method BUILD {
	my $frame = Gtk3::Frame->new('Outline');
	my $scrolled_window = Gtk3::ScrolledWindow->new;
	$scrolled_window->set_vexpand(TRUE);
	$scrolled_window->set_hexpand(TRUE);
	$scrolled_window->set_policy( 'automatic', 'automatic');

	$self->tree_view( Gtk3::TreeView->new );

	my $data = Gtk3::TreeStore->new( 'Glib::String', 'Glib::String', );
	$self->model( $data );

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

	$self->tree_view->set_model( $data );
	$self->tree_view->set( 'headers-visible', FALSE );

	$self->tree_view->signal_connect(
		'row-activated' => \&on_tree_view_row_activate_cb, $self );

	$self->set_transition_type( 'slide-right' );

	$scrolled_window->add( $self->tree_view );
	$frame->add( $scrolled_window );
	$self->add( $frame );
}

=method update

TODO

=cut
method update( $doc ) {
	my $tree_view = $self->tree_view;
	my $data = $self->model;

	$data->clear;

	return unless $doc->DOES('Renard::Curie::Model::Document::Role::Outlineable');
	my $outline_items = $doc->outline->items;
	my $level = 0;
	my $iter = undef;
	my @parents = ();
	for my $item (@$outline_items) {
		no autovivification;

		# If we need to go up to the parent iterators.
		while( @parents && $item->{level} < @parents ) {
			$iter = pop @parents;
		}

		if( $item->{level} > @parents ) {
			# If we need to go one level down to a child.
			# NOTE : This is not a while(...) loop because the
			# outline should only increase one level at a time.
			push @parents, $iter;
			$iter = $data->append($iter);
			$level++;

			# But if going down one level is not enough, this is a
			# malformed outline. It should not be possible to go
			# down multiple levels at a time.
			if( $item->{level} > @parents ) {
				die "Something went wrong with the outline data. It may be malformed."
					." The level for the current item '@{[ $item->{text} ]}'"
					." is @{[ $item->{level} ]},"
					." but we are only at @{[ scalar @parents ]}."
			}
		} else {
			# We are still at the same level. Just add a new row to
			# that last parent (or undef if we are at the root).
			$iter = $data->append( $parents[-1] // undef );
		}

		$data->set( $iter,
			0 => $item->{text} // '',
			1 => $item->{page} );
	}
}

=callback on_tree_view_row_activate_cb

TODO

=cut
fun on_tree_view_row_activate_cb( $tree_view, $path, $column, $self ) {
	# NOTE : This needs more error checking.

	my $pd = $self->app->page_document_component;

	my $iter = $self->model->get_iter( $path );
	my $page_num = $self->model->get_value($iter, 1);

	$pd->current_page_number( $page_num );
}

with qw(
	Renard::Curie::Component::Role::HasParentApp
);

1;
