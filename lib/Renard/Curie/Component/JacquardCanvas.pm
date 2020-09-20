use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::JacquardCanvas;
# ABSTRACT: Canvas component

use Role::Tiny::With;

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

	use Glib qw(TRUE FALSE);
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

		$self->signal_connect( draw => \&cb_on_draw );

		$self;
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

	sub GET_BORDER { (FALSE, undef); }

with qw(
	Renard::Curie::Component::JacquardCanvas::Role::Mouse
	Renard::Curie::Component::JacquardCanvas::Role::MouseCursor
	Renard::Curie::Component::JacquardCanvas::Role::MouseSelection
	Renard::Curie::Component::JacquardCanvas::Role::MousePageTooltip
	Renard::Curie::Component::JacquardCanvas::Role::Scroll
);

1;
