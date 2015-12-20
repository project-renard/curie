#!/usr/bin/env perl

use Gtk3 -init;
use Glib::Object::Introspection;
use Glib 'TRUE', 'FALSE';

use Moo;

has window => ( is => 'lazy' );

has [qw{table dock master layout dockbar box}] => ( is => 'rw' );
 

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

	#/* table */
	#table = gtk_box_new (GTK_ORIENTATION_VERTICAL, 5);
	$self->table( Gtk3::Box->new("GTK_ORIENTATION_VERTICAL", 5) );
	#gtk_container_add (GTK_CONTAINER (win), table);
	$self->window->add( $self->table );
	#gtk_container_set_border_width (GTK_CONTAINER (table), 10);
	$self->table->set_border_width( 10 );

	#/* create the dock */
	#dock = gdl_dock_new ();
	$self->dock( Gdl::Dock->new () );
	#GdlDockMaster *master = GDL_DOCK_MASTER (gdl_dock_object_get_master (GDL_DOCK_OBJECT (dock)));
	$self->master( Gdl::DockObject::get_master($self->dock) );
	#g_object_set (master, "tab-pos", GTK_POS_TOP, NULL);
	$self->master->set("tab-pos", "GTK_POS_TOP");
	#g_object_set (master, "tab-reorderable", TRUE, NULL);
	$self->master->set("tab-reorderable", TRUE);

	#/* ... and the layout manager */
	#layout = gdl_dock_layout_new (G_OBJECT (dock));
	$self->layout( Gdl::DockLayout->new( $self->dock ) );

	#/* create the dockbar */
	#dockbar = gdl_dock_bar_new (G_OBJECT (dock));
	$self->dockbar( Gdl::DockBar->new( $self->dock ));
	#gdl_dock_bar_set_style(GDL_DOCK_BAR(dockbar), GDL_DOCK_BAR_TEXT);
	$self->dockbar->set_style( "GDL_DOCK_BAR_TEXT" );

	#box = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 5);
	$self->box( Gtk3::Box->new("GTK_ORIENTATION_HORIZONTAL", 5) );
	#gtk_box_pack_start (GTK_BOX (table), box, TRUE, TRUE, 0);
	$self->table->pack_start( $self->box, TRUE, TRUE, 0);

        #gtk_box_pack_start (GTK_BOX (box), dockbar, FALSE, FALSE, 0);
	$self->box->pack_start( $self->dockbar, FALSE, FALSE, 0);
        #gtk_box_pack_end (GTK_BOX (box), dock, TRUE, TRUE, 0);
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
	};
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
	#gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scrolledwindow1),
					#GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
        #gtk_scrolled_window_set_shadow_type (GTK_SCROLLED_WINDOW (scrolledwindow1),
                                             #GTK_SHADOW_ETCHED_IN);
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

	#my $button = Gtk3::Button->new ('Quit');
	#$button->signal_connect (clicked => sub { Gtk3::main_quit });
	#$self->window->add ($button);
	$self->window->set_default_size( 200, 200 );
	$self->window->show_all;


	Gtk3::main;
}

sub _build_window {
	my $window = Gtk3::Window->new ('toplevel');
}

main;
