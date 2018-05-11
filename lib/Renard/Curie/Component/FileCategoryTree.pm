use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::FileCategoryTree;
# ABSTRACT: The file tree component

use Moo;
use Renard::Incunabula::Common::Types qw(InstanceOf AbsDir);

use Glib::Object::Subclass
	'Gtk3::Bin';

use Glib qw(TRUE FALSE);
use Glib::IO;
use Path::Tiny;
use Sort::Naturally qw(nsort);

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


=attr root

The FS root of the tree.

=cut
has root => (
	is => 'ro',
	required => 1,
	isa => AbsDir,
	coerce => 1,
);

=attr tree_view

The L<Gtk3::TreeView> component that displays the interactive tree.

=cut
has tree_view => (
	is => 'rw',
	isa => InstanceOf['Gtk3::TreeView'],
);

=attr model

The L<Gtk3::TreeStore> that holds tree data of heading text and page numbers.

=cut
has model => (
	is => 'lazy',
	isa => InstanceOf['Gtk3::TreeStore'],
);

=method BUILD

Constructor that sets up the view and model.

=cut
method BUILD(@) {
	my $scrolled_window = Gtk3::ScrolledWindow->new;
	$scrolled_window->set_vexpand(TRUE);
	$scrolled_window->set_hexpand(TRUE);
	$scrolled_window->set_policy( 'automatic', 'automatic');

	$self->tree_view( Gtk3::TreeView->new );

	my $text_column = Gtk3::TreeViewColumn->new_with_attributes(
		'Icon',
		Gtk3::CellRendererPixbuf->new,
		pixbuf => 1 );
	my $enabled = Gtk3::TreeViewColumn->new_with_attributes(
		'Active',
		my $toggle = Gtk3::CellRendererToggle->new,
		active => 3 );
	my $filename = Gtk3::TreeViewColumn->new_with_attributes(
		'Filename',
		Gtk3::CellRendererText->new,
		text => 2 );

	$self->tree_view->insert_column($text_column, 0);
	$self->tree_view->insert_column($enabled,     1);
	$self->tree_view->insert_column($filename,    2);

	$self->tree_view->set( 'headers-visible', FALSE );

	$toggle->signal_connect(
		toggled => method($path, @data) {
			my ($component) = @data;
			my $path = Gtk3::TreePath->new_from_string($path);
			my $iter = $component->model->get_iter($path);
			my $value = $component->model->get_value($iter, 3);
			$component->model->set($iter, 3, ! $value );
		},
		$self
	);
	$self->tree_view->signal_connect(
		'row-activated' => method($path, $column, $component) {
			my $iter = $component->model->get_iter($path);
			my $value = $component->model->get_value($iter, 0);
			if( -d path($value) ) {
				if( $self->row_expanded($path) ) {
					$self->collapse_row($path);
				} else {
					$self->expand_to_path($path);
				}
			} else {
				$component->view_manager->open_pdf_document( $value );
			}
		},
		$self
	);

	$self->tree_view->set_model( $self->model );
	$self->tree_view->signal_connect(
		'row-expanded' => method($iter, $path, $component) {
			my $child = $component->model->iter_nth_child($iter, 0);
			if ( ! defined $component->model->get_value( $child, 0 ) ) {
				my $parent = $component->model->iter_parent( $child );
				my $path = path( $component->model->get_value( $parent, 0 ) );
				$component->add_directory_to_tree(
					$component->model,
					$iter,
					$path,
				);
				$component->model->remove( $child );
			}
		},
		$self
	);

	$scrolled_window->add( $self->tree_view );
	$self->add( $scrolled_window );
}

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Initialises the L<Gtk3::Bin> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}

method add_file_to_tree( $store, $parent_iter, $child_file ) {
	my $current_iter = $store->append( $parent_iter );

	my $g_child = Glib::IO::File::new_for_path( "$child_file" );
	my $info = $g_child->query_info("standard::*", 'none', undef);
	my $icon = $info->get_icon;

	my $icon_theme = Gtk3::IconTheme::get_default;
	my $icon_sz = 16;
	my $icon_info = $icon_theme->lookup_by_gicon($icon, $icon_sz, [ qw/dir-ltr/ ] );
	my $pixbuf = $icon_info ? $icon_info->load_icon()
		: $icon_theme->load_icon( -d $child_file ? "folder" : "text-x-generic", 16, [qw/dir-ltr/]);

	$store->set( $current_iter,
		0 => $child_file->absolute->stringify,
		1 => $pixbuf,
		2 => $child_file->basename,
		3 => 0
	);

	$store->append( $current_iter ) if -d $child_file;
}

method add_directory_to_tree( $store, $parent_iter, $dir ) {
	for my $child_file (nsort $dir->children) {
		$self->add_file_to_tree( $store, $parent_iter, $child_file );
	}
}

method _build_model() {
	my $store = Gtk3::TreeStore->new(
		'Glib::String',
		'Gtk3::Gdk::Pixbuf',
		'Glib::String',
		'Glib::Boolean',
	);
	$store->clear;

	$self->add_directory_to_tree( $store, undef, $self->root );

	$store;
}

1;
