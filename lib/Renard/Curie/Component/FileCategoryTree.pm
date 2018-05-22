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
use List::UtilsBy qw(nsort_by);
use Sort::Naturally qw(nsort);
use Try::Tiny;

use Renard::Curie::Document;

use constant COLUMNS => {
	PATH                  => { index => 0, type => 'Glib::String' },
	ICON                  => { index => 1, type => 'Gtk3::Gdk::Pixbuf' },
	PYTEXTRANK_PROCESSED  => { index => 2, type => 'Glib::Boolean' },
	IGNORE_DOC            => { index => 3, type => 'Glib::Boolean' },
	REVIEW                => { index => 4, type => 'Glib::Boolean' },
	BACKGROUND_COLOR      => { index => 5, type => 'Glib::String' },
	FILENAME_BASE         => { index => 6,  type => 'Glib::String' },
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

	$self->tree_view->set('activate-on-single-click', FALSE);
	$self->tree_view->set( 'headers-visible', FALSE );


	$self->tree_view->insert_column(
		Gtk3::TreeViewColumn->new_with_attributes(
			'Icon',
			Gtk3::CellRendererPixbuf->new,
			pixbuf => COLUMNS->{'ICON'}{'index'},
			'cell-background' => COLUMNS->{'BACKGROUND_COLOR'}{'index'},
		),
		0
	);
	$self->tree_view->insert_column(
		Gtk3::TreeViewColumn->new_with_attributes(
			'Review?',
			my $toggle = Gtk3::CellRendererToggle->new,
			active => COLUMNS->{'REVIEW'}{'index'},
			'cell-background' => COLUMNS->{'BACKGROUND_COLOR'}{'index'},
		),
		1
	);
	$self->tree_view->insert_column(
		Gtk3::TreeViewColumn->new_with_attributes(
			'Filename',
			Gtk3::CellRendererText->new,
			text => COLUMNS->{'FILENAME_BASE'}->{'index'},
			'cell-background' => COLUMNS->{'BACKGROUND_COLOR'}{'index'},
		),
		2
	);

	$toggle->signal_connect(
		toggled => method($path, @data) {
			my ($component) = @data;
			my $path = Gtk3::TreePath->new_from_string($path);
			my $iter = $component->model->get_iter($path);

			my $filename = $component->model->get_value($iter, COLUMNS->{'PATH'}{'index'});
			my $is_review = $component->model->get_value($iter, COLUMNS->{'REVIEW'}{'index'});
			if( $is_review ) {
				$component->view_manager->card_review->remove_path( $filename );
			} else {
				$component->view_manager->card_review->add_path( $filename );
			}

			$component->model->set($iter, COLUMNS->{'REVIEW'}{'index'}, (! $is_review) );
		},
		$self
	);
	$self->tree_view->signal_connect(
		'row-activated' => method($path, $column, $component) {
			my $iter = $component->model->get_iter($path);
			my $value = $component->model->get_value($iter, COLUMNS->{'PATH'}{'index'});
			if( -d path($value) ) {
				if( $self->row_expanded($path) ) {
					$self->collapse_row($path);
				} else {
					$self->expand_to_path($path);
				}
			} else {
				try {
					$component->view_manager->open_pdf_document( $value );
					$component->update_iter_using_schema($iter);
				} catch {
					# NOP
				};
			}
		},
		$self
	);


	$self->tree_view->signal_connect( "button-press-event", \&view_onButtonPressed, $self);
	$self->tree_view->signal_connect("popup-menu", \&view_onPopupMenu, $self);

	$self->tree_view->set_model( $self->model );
	$self->tree_view->signal_connect(
		'row-expanded' => method($iter, $path, $component) {
			my $child = $component->model->iter_nth_child($iter, 0);
			if ( ! defined $component->model->get_value( $child, COLUMNS->{'PATH'}{'index'} ) ) {
				my $parent = $component->model->iter_parent( $child );
				my $path = path( $component->model->get_value( $parent, COLUMNS->{'PATH'}{'index'} ) );
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

	$self->add_directory_to_tree( $self->model, undef, $self->root );

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
		COLUMNS->{'PATH'}{'index'} => $child_file->absolute->stringify,
		COLUMNS->{'ICON'}{'index'} => $pixbuf,
		COLUMNS->{'FILENAME_BASE'}{'index'} => $child_file->basename,
		COLUMNS->{'REVIEW'}{'index'} => 0,
	);

	$store->append( $current_iter ) if -d $child_file;

	$self->update_iter_using_schema($current_iter);
}

method update_iter_using_schema( $iter ) {
	my $file = $self->model->get_value($iter, COLUMNS->{'PATH'}{'index'});
	return unless $self->can_handle_filepath($file);

	my $schema = $self->view_manager->schema;
	if( my $doc = $self->iter_to_document($iter) ) {
		if( $doc->is_ignored($schema) ) {
			$self->model->set($iter,
				COLUMNS->{'BACKGROUND_COLOR'}{'index'},
				'red' );
		} elsif( $doc->is_processed_pytextrank($schema) ) {
			$self->model->set($iter,
				COLUMNS->{'BACKGROUND_COLOR'}{'index'},
				'green' );
		} else {
			$self->model->set($iter,
				COLUMNS->{'BACKGROUND_COLOR'}{'index'},
				undef );
		}
	}
}

method iter_to_document( $iter ) {
	my $file = $self->model->get_value($iter, COLUMNS->{'PATH'}{'index'});

	return unless $self->can_handle_filepath($file);

	my $doc = Renard::Curie::Document->new(
		filename => $file
	);
}

method add_directory_to_tree( $store, $parent_iter, $dir ) {
	for my $child_file (nsort $dir->children) {
		$self->add_file_to_tree( $store, $parent_iter, $child_file );
	}
}

method _build_model() {
	my $store = Gtk3::TreeStore->new(
		map { $_->{type} }
		nsort_by { $_->{index} }
		values %{ COLUMNS() }
	);
	$store->clear;

	$store;
}

method can_handle_filepath($file) {
	return -f $file && $file =~ /\.pdf$/i;
}

callback view_popup_menu_on_process ($menu_item, $data) {
	my ($path, $component) = @$data;
	my $iter = $component->model->get_iter($path);
	if( my $doc = $component->iter_to_document($iter) ) {
		$doc->process_pytextrank($component->view_manager->schema);
		$component->update_iter_using_schema($iter);
	}
}

callback view_popup_menu_on_ignore ($menu_item, $data) {
	my ($path, $component) = @$data;
	my $iter = $component->model->get_iter($path);
	if( my $doc = $component->iter_to_document($iter) ) {
		$doc->toggle_ignore($component->view_manager->schema);
		$component->update_iter_using_schema($iter);
	}
}


callback view_popup_menu ($tree_view, $path, $component) {
	my $menu = Gtk3::Menu->new;

	my $iter = $component->model->get_iter($path);
	my $schema = $component->view_manager->schema;
	if( my $doc = $component->iter_to_document($iter) ) {
		my $mi_process = Gtk3::MenuItem->new_with_label("Process");
		$mi_process->set_sensitive( ! $doc->is_processed_pytextrank($schema) );

		my $mi_ignore  = Gtk3::MenuItem->new_with_label(
			! $doc->is_ignored($schema)
			? "Ignore"
			: "Unignore"
		);

		$mi_process->signal_connect( 'activate' => \&view_popup_menu_on_process, [$path, $component]);
		$mi_ignore->signal_connect( 'activate' => \&view_popup_menu_on_ignore,  [$path, $component]);

		$menu->append( $mi_process );
		$menu->append( $mi_ignore );

		$menu->show_all;

		$menu->popup_at_pointer;
	}
}


callback view_onButtonPressed ($tree_view, $event, $component) {
	if ( $event->type eq 'button-press'  &&  $event->button == 3) {
		# single click with the right mouse button?
		my @data = $tree_view->get_path_at_pos($event->x, $event->y);
		my $path = $data[0];
		if( @data ) {
			view_popup_menu($tree_view, $path, $component);
		}
		return TRUE;
	}

	return FALSE;
}


callback view_onPopupMenu($tree_view, $component) {
	my $path = $component->model->get_path( ( $tree_view->get_selection->get_selected )[1] );
	view_popup_menu($tree_view, $path, $component);
	return TRUE;
}



1;
