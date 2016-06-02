use Modern::Perl;
package Renard::Curie::Component::MenuBar;

use Moo;
use URI;
use Glib::Object::Subclass 'Gtk3::Bin';

has app => ( is => 'ro', required => 1, weak_ref => 1 );

has recent_manager => ( is => 'lazy' ); # _build_recent_manager

has recent_chooser => ( is => 'lazy' ); # _build_recent_chooser

sub FOREIGNBUILDARGS {
	my ($class, %args) = @_;
	return ();
}

sub BUILD {
	my ($self) = @_;

	$self->builder->get_object('menu-item-file-open')
		->signal_connect( activate =>
			sub {
				my ($event, $self) = @_;
				$self->on_menu_file_open_activate_cb($event);
			}, $self );
	$self->builder->get_object('menu-item-file-quit')
		->signal_connect( activate =>
			sub {
				my ($event, $self) = @_;
				$self->on_menu_file_quit_activate_cb($event);
			}, $self );

	$self->builder->get_object('menu-item-file-recentfiles')
		->set_submenu($self->recent_chooser);

	$self->recent_chooser->signal_connect( "item-activated" =>
			sub {
				my ($event, $self) = @_;
				$self->on_menu_file_recentfiles_item_activated_cb($event);
			}, $self );

	# add as child for this Gtk3::Bin
	$self->add(
		$self->builder->get_object('menubar')
	);
}

sub _build_recent_manager {
	Gtk3::RecentManager::get_default;
}

sub _build_recent_chooser {
	my ($self) = @_;
	my $recent_chooser = Gtk3::RecentChooserMenu->new_for_manager( $self->recent_manager );
}


# Callbacks {{{
sub on_menu_file_open_activate_cb {
	my ($self, $event) = @_;
	$self->app->on_open_file_dialog_cb($event);
}

sub on_menu_file_quit_activate_cb {
	my ($self, $event) = @_;
	$self->app->on_application_quit_cb($event);
}

sub on_menu_file_recentfiles_item_activated_cb {
	my ($self, $recent_chooser) = @_;
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
