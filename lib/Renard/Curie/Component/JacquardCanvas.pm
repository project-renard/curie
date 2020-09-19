use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::JacquardCanvas;
# ABSTRACT: Canvas component

use Renard::API::Gtk3::Helper;
use Glib qw(TRUE FALSE);

use feature qw(current_sub);

	use Glib::Object::Subclass
		'Gtk3::DrawingArea',
		interfaces => [ 'Gtk3::Scrollable', ],
		properties => [
			# Gtk3::Scrollable interface
			Glib::ParamSpec->object ('hadjustment','hadj','', Gtk3::Adjustment::, [qw/readable writable construct/] ),
			Glib::ParamSpec->object ('vadjustment','vadj','', Gtk3::Adjustment::, [qw/readable writable construct/] ),
			Glib::ParamSpec->enum   ('hscroll-policy','hpol','', "Gtk3::ScrollablePolicy", "GTK_SCROLL_MINIMUM", [qw/readable writable/]),
			Glib::ParamSpec->enum   ('vscroll-policy','vpol','', "Gtk3::ScrollablePolicy", "GTK_SCROLL_MINIMUM", [qw/readable writable/]),
		],
		signals => {
			'view-changed' => {},
			'text-found' => {},
		},
	;

	use Object::Util magic => 0;
	use Glib qw(TRUE FALSE);
	use Scalar::Util qw(refaddr);
	use List::AllUtils qw(first);

	use Renard::Yarn::Types qw(Point Size);

	use constant HIGHLIGHT_BOUNDS => $ENV{T_GRID_HIGHLIGHT_BOUNDS} // 0;
	use constant HIGHLIGHT_LAYERS => $ENV{T_GRID_HIGHLIGHT_LAYERS} // 0;

	sub new {
		my ($class, %args) = @_;

		my $data = {
			sg => delete $args{sg},
			scale => delete $args{scale}
		};

		my $self = $class->SUPER::new(%args);

		$self->{sg} = $data->{sg};
		$self->{scale} = $data->{scale};

		my %page_map;
		my $map_pages = sub {
			my ($g) = @_;
			if( $g->isa('Renard::Curie::Model::View::Grid::PageActor' ) ) {
				$page_map{ $g->page_number} = $g;
			}
			__SUB__->($_) for @{ $g->children };
		};
		$map_pages->($self->{sg});
		$self->{pages} = \%page_map;

		$self->{selection}{state} = 0;

		$self->signal_connect(
			realize => sub {
				my $bounds = $self->{sg}->bounds;

				$self->get_hadjustment
					->$_tap( set_lower => 0 )
					->$_tap( set_upper =>  $self->{scale} * $bounds->size->width)
					;
				$self->get_vadjustment
					->$_tap( set_lower => 0 )
					->$_tap( set_upper => $self->{scale} * $bounds->size->height )
					;

				for my $adj (qw(get_hadjustment get_vadjustment)) {
					for my $sig (qw(changed value-changed)) {
						$self->$adj->signal_connect(
							$sig => \&cb_on_scroll, $self );
					}
				}
				cb_on_scroll(undef, $self);
			}
		);

		$self->signal_connect(
			'size-allocate' => sub {
				my ($widget, $allocation) = @_;
				$self->get_hadjustment
					->set_page_size( $allocation->{width} );
				$self->get_vadjustment
					->set_page_size( $allocation->{height} );
			}
		);

		$self->signal_connect( draw => \&cb_on_draw );
		$self->signal_connect(
			'motion-notify-event' => \&cb_on_motion_notify,
			$self
		);
		$self->signal_connect( 'button-press-event' => \&cb_on_button_press_event, $self );
		$self->signal_connect( 'button-release-event' => \&cb_on_button_release_event, $self );

		$self->add_events('scroll-mask');
		$self->add_events([qw/
			pointer-motion-mask
			button-press-mask
			button-release-mask
		/]);

		$self;
	}

	sub _get_data_for_pointer {
		my ($self, $event_point) = @_;

		state $last_point;
		state $data;

		my ($h, $v) = (
			$self->get_hadjustment,
			$self->get_vadjustment,
		);
		my $matrix = Renard::Yarn::Graphene::Matrix->new;
		$matrix->init_from_2d( 1, 0 , 0 , 1, $h->get_value, $v->get_value );

		my $point = $matrix * $event_point;

		if( defined $last_point && $last_point == $point ) {
			return $data;
		}

		my @intersects = map {
			$_->{bounds}->contains_point($point)
			? $_
			: ();
		} @{ $self->{views} };

		my @pages = map { $_->{page_number} } @intersects;

		$last_point = $point;

		$data = {
			intersects => \@intersects,
			pages => \@pages,
			point => $point,
		};

		return $data;
	}

	sub _get_text_data_for_pointer {
		my ($self, $pointer_data) = @_;

		state $last_pointer_data;
		state $text_data;

		if( defined $last_pointer_data && refaddr($last_pointer_data) == refaddr($pointer_data) ) {
			return $text_data;
		} else {
			$text_data = undef;
		}

		my @intersects = @{ $pointer_data->{intersects} };
		my $point = $pointer_data->{point};

		if( @intersects ) {
			my $actor = $intersects[0]->{actor};
			my $matrix = $intersects[0]->{matrix};
			my $bounds = $intersects[0]->{bounds};

			my $test_point = $matrix->untransform_point( $point, $bounds );

			$text_data = $actor->text_at_point( $test_point );
			if( @$text_data ) {
				$_->{t_bbox} = ($matrix->inverse)[1]
					->untransform_bounds(
						$_->{bbox},
						$bounds
				) for @$text_data;
			}
		}

		return $text_data;
	}

	sub _set_cursor_to_name {
		my ($self, $name) = @_;
		$self->get_window->set_cursor(
			Gtk3::Gdk::Cursor->new_from_name($self->get_display, $name)
		);
	}

	sub cb_on_scroll {
		my ($adjustment, $self) = @_;
		my ($h, $v) = (
			$self->get_hadjustment,
			$self->get_vadjustment,
		);

		my $vp_origin = Point->coerce([ $h->get_value, $v->get_value ]);
		my $vp_size = Size->coerce([ $h->get_page_size, $v->get_page_size ]);

		my $vp_bounds = Renard::Yarn::Graphene::Rect->new(
			origin => $vp_origin,
			size => $vp_size,
		);

		my @views;
		my $vp_is_visible = sub {
			my ($g, $g_matrix) = @_;
			my $t_matrix = Renard::Yarn::Graphene::Matrix->new;
			if( $g->does('Renard::Jacquard::Role::Render::QnD::Layout') ) {
				$t_matrix->init_from_2d( 1, 0 , 0 , 1, $g->x->value, $g->y->value );
			} else {
				# position translation is already incorporated into bounds of non-layout
				$t_matrix->init_from_2d( 1, 0 , 0 , 1, 0, 0 );
			}
			my $matrix = $t_matrix x $g_matrix;
			if( $g->isa('Renard::Curie::Model::View::Grid::PageActor') &&
				( (my $t_bounds = $matrix->transform_bounds($g->bounds))->intersection($vp_bounds) )[0]
			) {
				$g->{visible} = 1;
				push @views, {
					page_number => $g->page_number,
					actor => $g,
					bounds => $t_bounds,
					matrix => $matrix,
					g_matrix => $g_matrix,
					t_matrix => $t_matrix,
				};
			}
			__SUB__->($_, $matrix) for @{ $g->children };
		};

		my $matrix = Renard::Yarn::Graphene::Matrix->new;
		$matrix->init_scale($self->{scale}, $self->{scale}, 1);
		$vp_is_visible->($self->{sg}, $matrix);

		$self->{views} = \@views;

		$self->signal_emit( 'view-changed' );
	}

	sub cb_on_draw {
		my ($self, $cr) = @_;

		$cr->save;

		my ($h, $v) = (
			$self->get_hadjustment,
			$self->get_vadjustment,
		);

		$cr->translate( -$h->get_value, -$v->get_value );

		$cr->scale($self->{scale}, $self->{scale});

		$cr->set_source_rgb(0, 0, 0);
		$cr->paint;

		$self->{sg}->render_cairo( $cr );

		$cr->restore;

		if( $self->{selection}{state} ) {
			my $start_pages = $self->{selection}{start}{pointer}{pages};
			my $end_pages = $self->{selection}{end}{pointer}{pages};
			if( @$start_pages && @$end_pages ) {
				my @sorted = sort ( $start_pages->[0] , $end_pages->[0] );
				my @pgs = ( $sorted[0] .. $sorted[1] );
				my @bboxes;
				for my $page_number (@pgs) {
					my $page = $self->{pages}{$page_number};
					my $view = first { $_->{page_number} == $page_number } @{ $self->{views} };
					next unless $view;

					my $matrix = $view->{matrix};
					my $bounds = $view->{bounds};

					my @extents = $page->get_extents_from_selection(
						$self->{selection}{start},
						$self->{selection}{end}
					);
					if( @extents ) {
						my @page_bboxes = $page->get_bboxes_from_extents(@extents);
						push @bboxes, ($matrix->inverse)[1]
							->untransform_bounds(
								$_,
								$bounds
						) for @page_bboxes;
					}
				}
				for my $bounds (@bboxes) {
					$self->_draw_bounds_as_rectangle($cr, $bounds);
					$cr->set_source_rgba(0, 0, 1, 0.2);
					$cr->fill;
				}
			}
		}


		if( HIGHLIGHT_LAYERS() && exists $self->{text} ) {
			for my $layer (@{ $self->{text}{layers} }) {
				my $bounds = $layer->{t_bbox};
				$self->_draw_bounds_as_rectangle($cr, $bounds);
				$cr->set_source_rgba(0, 0, 0, 0.5);
				$cr->set_line_width(1);
				$cr->stroke_preserve;
				$cr->set_source_rgba(1, 0.5, 0.5, 0.2);
				$cr->fill;
			}
		}

		if( HIGHLIGHT_BOUNDS() ) {
			#say "Drawing # of bounds: @{[ scalar @{ $self->{views} } ]}";
			for my $bounds (map { $_->{bounds} } @{ $self->{views} }) {
				$self->_draw_bounds_as_rectangle($cr, $bounds);
				$cr->set_source_rgba(1, 0, 0, 0.2);
				$cr->fill;
			}
		}
	}

	sub _draw_bounds_as_rectangle {
		my ($self, $cr, $bounds) = @_;

		my ($h, $v) = (
			$self->get_hadjustment,
			$self->get_vadjustment,
		);

		$cr->rectangle(
			$bounds->get_x - $h->get_value,
			$bounds->get_y - $v->get_value,
			$bounds->get_width,
			$bounds->get_height,
		);
	}

	sub mark_selection_start {
		my ($self, $event_point) = @_;

		my $pointer_data = $self->_get_data_for_pointer($event_point);
		my $text_data = $self->_get_text_data_for_pointer( $pointer_data );
		$self->{selection}{start} = { pointer => $pointer_data, text => $text_data };
		$self->{selection}{end} = $self->{selection}{start};
	}

	sub mark_selection_end {
		my ($self, $event_point) = @_;

		my $pointer_data = $self->_get_data_for_pointer($event_point);
		my $text_data = $self->_get_text_data_for_pointer( $pointer_data );
		$self->{selection}{end} = { pointer => $pointer_data, text => $text_data };
		$self->queue_draw;
	}

	sub clear_selection {
		my ($self) = @_;
		$self->{selection}{state} = 0;
	}

	sub cb_on_button_press_event {
		my ($widget, $event, $self) = @_;

		if( $event->button == Gtk3::Gdk::BUTTON_PRIMARY ) {
			#say "Start selection";
			my $event_point = Point->coerce([ $event->x, $event->y ]);
			$self->mark_selection_start($event_point);
			$self->{selection}{state} = 1;
		}

		return TRUE;
	}

	sub cb_on_button_release_event {
		my ($widget, $event, $self) = @_;

		if( $event->state & 'button1-mask' ) {
			#say "End selection";
			my $event_point = Point->coerce([ $event->x, $event->y ]);
			if( $self->{selection}{state} == 2 ) {
				$self->clear_selection;
			} else {
				$self->mark_selection_end($event_point);
				$self->{selection}{state} = 2;
			}
		}

		return TRUE;
	}

	sub cb_on_motion_notify {
		my ($widget, $event, $self) = @_;

		if( $event->state & 'button1-mask' ) {
			cb_on_motion_notify_button1($widget, $event, $self);
		} else {
			cb_on_motion_notify_hover($widget, $event, $self);
		}
	}

	sub cb_on_motion_notify_button1 {
		my ($widget, $event, $self) = @_;

		if( $event->state & 'button1-mask' ) {
			#say "Continuing selection";
			my $event_point = Point->coerce([ $event->x, $event->y ]);
			$self->mark_selection_end($event_point);
			$self->{selection}{state} = 1;
		}

		return TRUE;
	}

	sub cb_on_motion_notify_hover {
		my ($widget, $event, $self) = @_;
		my $event_point = Point->coerce([ $event->x, $event->y ]);

		my $pointer_data = $self->_get_data_for_pointer($event_point);

		my @intersects = @{ $pointer_data->{intersects} };
		my @pages = @{ $pointer_data->{pages} };
		my $point = $pointer_data->{point};

		if( @pages) {
			$self->set_tooltip_text("@pages");
		} else {
			$self->set_has_tooltip(FALSE);
		}

		my $text_data = $self->_get_text_data_for_pointer($pointer_data);
		if( defined $text_data ) {
			if( @$text_data ) {
				my $block = $text_data->[0];
				$self->{text}{substr} = $block->{extent}->substr;
				$self->{text}{data} = $block;

				$self->{text}{layers} = $text_data;

				if( $text_data->[-1]{tag} eq 'char' ) {
					$self->_set_cursor_to_name('text');
				} else {
					$self->_set_cursor_to_name('default');
				}

				$self->signal_emit( 'text-found' );
			} else {
				delete $self->{text};
				$self->_set_cursor_to_name('default');
			}
			$self->queue_draw;
		}

		return TRUE;
	}


	sub GET_BORDER { (FALSE, undef); }

1;
