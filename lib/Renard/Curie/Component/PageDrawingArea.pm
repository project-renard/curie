use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea;
# ABSTRACT: Component that implements document page navigation

use Moo;

use Renard::Incunabula::Frontend::Gtk3::Helper;
use Glib 'TRUE', 'FALSE';
use Glib::Object::Subclass
	'Gtk3::Bin',
	signals => {
		'update-scroll-adjustment' => {},
	},
	;
use Renard::Incunabula::Common::Types qw(Bool InstanceOf);
use Renard::Incunabula::Document::Types qw(PageNumber ZoomLevel);
use Renard::Incunabula::Format::Cairo::Types qw(RenderableDocumentModel RenderablePageModel);

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

=attr drawing_area

The L<Gtk3::DrawingArea> that is used to draw the document on.

=cut
has drawing_area => (
	is => 'rw',
	isa => InstanceOf['Gtk3::DrawingArea'],
);

=attr scrolled_window

The L<Gtk3::ScrolledWindow> container for the L</drawing_area>.

=cut
has scrolled_window => (
	is => 'rw',
	isa => InstanceOf['Gtk3::ScrolledWindow'],
);

=head1 SIGNALS

=for :list
* C<update-scroll-adjustment>: called when the widget has been horizontally or vertically scrolled

=cut

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Initialises the L<Gtk3::Bin> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}

=method BUILD

  method BUILD

Initialises the component's contained widgets and signals.

=cut
method BUILD(@) {
	$self->signal_connect( 'update-scroll-adjustment', sub {
		if( $self->view->can('update_scroll_adjustment') ) {
			$self->view->update_scroll_adjustment(
				$self->scrolled_window->get_hadjustment,
				$self->scrolled_window->get_vadjustment,
			);
		}
	});
	$self->set_can_focus( TRUE );

	$self->setup_drawing_area;

	# add as child for this L<Gtk3::Bin>
	$self->add(
		$self->builder->get_object('page-drawing-component')
	);

	$self->view_manager->signal_connect(
		'update-view' => fun( $view_manager, $view ) {
			$self->update_view( $view );
		}
	);
	$self->update_view( $self->view_manager->current_view );
	$self->view->signal_emit('view-changed');
}

=method setup_drawing_area

  method setup_drawing_area()

Sets up the L</drawing_area> so that it draws the current page.

=cut
method setup_drawing_area() {
	my $drawing_area = Gtk3::DrawingArea->new();
	$self->drawing_area( $drawing_area );
	$drawing_area->signal_connect( draw => callback(
			(InstanceOf['Gtk3::DrawingArea']) $widget,
			(InstanceOf['Cairo::Context']) $cr) {
		$self->on_draw_page_cb( $cr );

		return TRUE;
	}, $self);

	my $scrolled_window = Gtk3::ScrolledWindow->new();
	$scrolled_window->set_hexpand(TRUE);
	$scrolled_window->set_vexpand(TRUE);

	$scrolled_window->add($drawing_area);
	$scrolled_window->set_policy( 'automatic', 'automatic');
	$self->scrolled_window($scrolled_window);

	my @adjustments = (
		$self->scrolled_window->get_hadjustment,
		$self->scrolled_window->get_vadjustment,
	);
	my $callback = fun($adjustment) {
		$self->signal_emit('update-scroll-adjustment');
	};
	for my $adjustment (@adjustments) {
		$adjustment->signal_connect( 'value-changed' => $callback );
		$adjustment->signal_connect( 'changed' => $callback );
	}

	my $vbox = $self->builder->get_object('page-drawing-component');
	$vbox->pack_start( $scrolled_window, TRUE, TRUE, 0);
}

=method refresh_drawing_area

  method refresh_drawing_area()

This forces the drawing area to redraw.

=cut
method refresh_drawing_area() {
	return unless $self->drawing_area;

	$self->drawing_area->queue_draw;
}

=callback on_draw_page_cb

  method on_draw_page_cb( (InstanceOf['Cairo::Context']) $cr )

Callback that draws the current page on to the L</drawing_area>.

=cut
method on_draw_page_cb( (InstanceOf['Cairo::Context']) $cr ) {
	# NOTE: we may want to change the signature to match the other
	# callbacks with $self as the last argument.
	$self->set_navigation_buttons_sensitivity;

	$self->view->draw_page( $self->drawing_area, $cr );
	$self->on_draw_page_cb_highlight( $cr );

	my $page_number = $self->view->page_number;
	if( $self->view->can('_first_page_in_viewport') ) {
		$page_number = $self->view->_first_page_in_viewport;
	}

	$self->builder->get_object('page-number-entry')
		->set_text($page_number);
}

=method on_draw_page_cb_highlight

  method on_draw_page_cb_highlight( (InstanceOf['Cairo::Context']) $cr )

Highlights the current sentence on the page.

=cut
method on_draw_page_cb_highlight( (InstanceOf['Cairo::Context']) $cr ) {
	my @top_left = (0,0);
	if( @{ $self->view_manager->current_text_page } ) {
		my $sentence = $self->view_manager->current_text_page->[
			$self->view_manager->current_sentence_number
		];
		for my $bbox_str ( @{ $sentence->{bbox} } ) {
			my $bbox = [ split ' ', $bbox_str ];
			$cr->rectangle(
				$top_left[0] + $bbox->[0],
				$top_left[1] + $bbox->[1],
				$bbox->[2] - $bbox->[0],
				$bbox->[3] - $bbox->[1],
			);
			$cr->set_source_rgba(1, 0, 0, 0.2);
			$cr->fill;
		}
	}
}


=method update_view

  method update_view($new_view)

Sets up the signals for a new view.

=cut
method update_view($new_view) {
	# so that the widget can take input
	$self->view->signal_connect( 'view-changed', sub {
		$self->signal_emit('update-scroll-adjustment');
		if( $self->view->can('get_size_request') ) {
			if( $self->drawing_area ) {
				$self->drawing_area->set_size_request(
					$self->view->get_size_request
				);
				$self->refresh_drawing_area;
			}
		} else {
			$self->refresh_drawing_area;
		}
	} );

	$self->view->signal_emit('view-changed');
}

with qw(
	Renard::Incunabula::Frontend::Gtk3::Component::Role::FromBuilder
	Renard::Incunabula::Frontend::Gtk3::Component::Role::UIFileFromPackageName

	Renard::Curie::Component::PageDrawingArea::Role::KeyBindings
	Renard::Curie::Component::PageDrawingArea::Role::MouseScrollBindings
	Renard::Curie::Component::PageDrawingArea::Role::NavigationButtons
	Renard::Curie::Component::PageDrawingArea::Role::PageEntry
	Renard::Curie::Component::PageDrawingArea::Role::PageLabel
	Renard::Curie::Component::PageDrawingArea::Role::ScrollWindow
);


1;
