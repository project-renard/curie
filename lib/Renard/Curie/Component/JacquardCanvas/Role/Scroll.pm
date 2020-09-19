use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::JacquardCanvas::Role::Scroll;
# ABSTRACT: Scroll role

use Role::Tiny;
use feature qw(current_sub);

	use Object::Util magic => 0;
	use Renard::Yarn::Types qw(Point Size);

	around new => sub {
		my $orig = shift;
		my $self = $orig->(@_);

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

		$self->add_events('scroll-mask');

		$self;
	};

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

1;
