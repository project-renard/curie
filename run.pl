#!/usr/bin/env perl

use Gtk3 -init;
use Cairo;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';

use Moo;

use constant UI_FILE => "curie.glade";

has [qw{table dock master layout dockbar box}] => ( is => 'rw' );

has window => ( is => 'lazy' );
	sub _build_window {
		my ($self) = @_;
		my $window = $self->builder->get_object('main_window');
	}

has builder => ( is => 'lazy', clearer => 1 );
	sub _build_builder {
		Gtk3::Builder->new ();
	}

sub gval ($$) { Glib::Object::Introspection::GValueWrapper->new('Glib::'.ucfirst($_[0]) => $_[1]) } # GValue wrapper shortcut
sub genum { Glib::Object::Introspection->convert_sv_to_enum($_[0], $_[1]) }

sub setup_gtk {
	Glib::Object::Introspection->setup(
		basename => 'Gdl',
		version => '3',
		package => 'Gdl', );
}

sub setup_window {
	my ($self) = @_;

	$self->builder->add_from_file( UI_FILE );
	$self->builder->connect_signals;

	$self->setup_drawing_area_example;
}

sub setup_drawing_area_example {
	my ($self) = @_;

	my $vbox = $self->builder->get_object('application_vbox');

	my $drawing_area = Gtk3::DrawingArea->new();
	$drawing_area->signal_connect( draw => sub {
		my ($widget, $cr) = @_;

		my $img = Cairo::ImageSurface->create_from_png( 'peppers.png' );
		$cr->set_source_surface($img, 0, 0);
		$cr->paint;

		return TRUE;
	});

	$vbox->pack_start( $drawing_area, TRUE, TRUE, 0);
}

sub setup_docking_example {
	my ($self) = @_;

	#/* table */
	$self->table( Gtk3::Box->new("GTK_ORIENTATION_VERTICAL", 5) );
	my $vbox = $self->builder->get_object('application_vbox');
	$vbox->pack_start( $self->table, TRUE, TRUE, 0);
	$self->table->set_border_width( 10 );

	#/* create the dock */
	$self->dock( Gdl::Dock->new () );
	$self->master( Gdl::DockObject::get_master($self->dock) );
	$self->master->set("tab-pos", "GTK_POS_TOP");
	$self->master->set("tab-reorderable", TRUE);

	#/* ... and the layout manager */
	$self->layout( Gdl::DockLayout->new( $self->dock ) );

	#/* create the dockbar */
	$self->dockbar( Gdl::DockBar->new( $self->dock ));
	$self->dockbar->set_style( "GDL_DOCK_BAR_TEXT" );

	$self->box( Gtk3::Box->new("GTK_ORIENTATION_HORIZONTAL", 5) );
	$self->table->pack_start( $self->box, TRUE, TRUE, 0);

	$self->box->pack_start( $self->dockbar, FALSE, FALSE, 0);
	$self->box->pack_end( $self->dock, TRUE, TRUE, 0 );

	my $first_item = Gdl::DockItem->new_with_stock("Item #4", "Item #4",
						  "GTK_STOCK_JUSTIFY_FILL",
						  [ "GDL_DOCK_ITEM_BEH_NORMAL",
						  "GDL_DOCK_ITEM_BEH_CANT_ICONIFY" ]);
	$first_item->add( create_text_item() );
	$first_item->show;
	$self->dock->add_item( $first_item, "GDL_DOCK_TOP" );
	for (my $i = 1; $i < 3; $i++) {
		my $name = sprintf "Item #%d", $i + 4;
		my $item = Gdl::DockItem->new_with_stock ($name, $name, "GTK_STOCK_NEW",
					"GDL_DOCK_ITEM_BEH_NORMAL");
		$item->add( create_text_item() );
		$item->show();

		$self->dock->add_item( $item, 'GDL_DOCK_TOP' );
	}
}



sub create_text_item {
	my $vbox1;
	my $scrolledwindow1;
	my $text;

	$vbox1 = Gtk3::Box->new ("GTK_ORIENTATION_VERTICAL", 0);
	$vbox1->show;

	$scrolledwindow1 = Gtk3::ScrolledWindow->new(undef, undef);
	$scrolledwindow1->show;
	$vbox1->pack_start( $scrolledwindow1, TRUE, TRUE, 0);
	$text = Gtk3::TextView->new();
	$text->set( "wrap-mode", "GTK_WRAP_WORD");
	$text->show;
	$scrolledwindow1->add( $text );

	return $vbox1;
}


sub main {
	setup_gtk;

	my $self = __PACKAGE__->new;
	$self->setup_window;

	$self->window->signal_connect(destroy => sub { Gtk3::main_quit });
	$self->window->set_default_size( 800, 600 );
	$self->window->show_all;


	Gtk3::main;
}

main;
