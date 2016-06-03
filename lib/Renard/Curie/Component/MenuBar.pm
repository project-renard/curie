use Renard::Curie::Setup;
package Renard::Curie::Component::MenuBar;

use Moo;
use URI;
use Glib::Object::Subclass 'Gtk3::Bin';
use Function::Parameters;
use Renard::Curie::Types qw(InstanceOf);

has app => (
	is => 'ro',
	isa => InstanceOf['Renard::Curie::App'],
	required => 1,
	weak_ref => 1
);

has recent_manager => (
	is => 'lazy', # _build_recent_manager
	isa => InstanceOf['Gtk3::RecentManager'],
);

has recent_chooser => (
	is => 'lazy', # _build_recent_chooser
	isa => InstanceOf['Gtk3::RecentChooserMenu'],
);

classmethod FOREIGNBUILDARGS(@) {
	return ();
}

method BUILD {
	$self->builder->get_object('menu-item-file-open')
		->signal_connect( activate =>
			fun ($event, $self) {
				$self->on_menu_file_open_activate_cb($event);
			}, $self );
	$self->builder->get_object('menu-item-file-quit')
		->signal_connect( activate =>
			fun ($event, $self) {
				$self->on_menu_file_quit_activate_cb($event);
			}, $self );

	$self->builder->get_object('menu-item-file-recentfiles')
		->set_submenu($self->recent_chooser);

	$self->recent_chooser->signal_connect( "item-activated" =>
			fun ($event, $self) {
				$self->on_menu_file_recentfiles_item_activated_cb($event);
			}, $self );

	# add as child for this Gtk3::Bin
	$self->add(
		$self->builder->get_object('menubar')
	);
}

method _build_recent_manager :ReturnType(InstanceOf['Gtk3::RecentManager']) {
	Gtk3::RecentManager::get_default;
}

method _build_recent_chooser :ReturnType(InstanceOf['Gtk3::RecentChooserMenu']) {
	my $recent_chooser = Gtk3::RecentChooserMenu->new_for_manager( $self->recent_manager );
}


# Callbacks {{{
method on_menu_file_open_activate_cb($event) {
	$self->app->on_open_file_dialog_cb($event);
}

method on_menu_file_quit_activate_cb($event) {
	$self->app->on_application_quit_cb($event);
}

method on_menu_file_recentfiles_item_activated_cb( (InstanceOf['Gtk3::RecentChooserMenu']) $recent_chooser ) {
	my $selected_item = $recent_chooser->get_current_item;
	my $uri = $selected_item->get_uri;
	my $file = URI->new( $uri )->file;
	$self->app->open_pdf_document( $file );
}
# }}}


with qw(
	Renard::Curie::Component::Role::FromBuilder
	Renard::Curie::Component::Role::UIFileFromPackageName
);

1;
