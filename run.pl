#!/usr/bin/env perl

use Gtk3 -init;
use Glib::Object::Introspection;

use Moo;

has toplevel_window => ( is => 'lazy' );
 
sub setup_gtk {
	Glib::Object::Introspection->setup(
		basename => 'Gdl',
		version => '3',
		package => 'Gtk3::Gdl', );

}

sub main {
	setup_gtk;

	my $self = __PACKAGE__->new;

	my $button = Gtk3::Button->new ('Quit');
	$button->signal_connect (clicked => sub { Gtk3::main_quit });
	$self->toplevel_window->add ($button);
	$self->toplevel_window->set_default_size( 200, 200 );
	$self->toplevel_window->show_all;

	Gtk3::main;
}

sub _build_toplevel_window {
	my $window = Gtk3::Window->new ('toplevel');

}

main;
