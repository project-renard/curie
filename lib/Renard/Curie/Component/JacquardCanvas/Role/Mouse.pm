use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::JacquardCanvas::Role::Mouse;
# ABSTRACT: Mouse things for the canvas

use Role::Tiny;

use Glib qw(TRUE FALSE);
use Scalar::Util qw(refaddr);
use Renard::Yarn::Types qw(Point Size);

	around new => sub {
		my $orig = shift;
		my $self = $orig->(@_);

		$self->{selection}{state} = 0;

		$self->signal_connect(
			'motion-notify-event' => \&cb_on_motion_notify,
			$self
		);
		$self->signal_connect( 'button-press-event' => \&cb_on_button_press_event, $self );
		$self->signal_connect( 'button-release-event' => \&cb_on_button_release_event, $self );

		$self->add_events([qw/
			pointer-motion-mask
			button-press-mask
			button-release-mask
		/]);

		$self;
	};

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



1;
