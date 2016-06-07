package PPIFPXform;

use Moo;

extends 'PPI::Transform';
use List::AllUtils qw(any);
#use Carp::Always;
use PPI::Dumper;
use constant SUBNAMES => qw(fun method classmethod);
%PPI::Lexer::STATEMENT_CLASSES = (
	%PPI::Lexer::STATEMENT_CLASSES,
	( map { ( $_ => 'PPI::Statement::Sub' ) } SUBNAMES ),
);
use feature qw(say);
use IPC::Open2;

my $TEMPLATE = <<PERL;
use Renard::Curie::Setup;
use Function::Parameters;

<REPLACE> {
	42;
};
PERL

sub document {
	my ( $self, $document ) = @_;

	my $changes = 0;

	$self->remove_return_type_sub_attribute($document);

	my $elements = $self->find_statement_and_anonymous_subs( $document );

	return undef unless defined $elements;
	return 0 unless $elements;

	say "----";
	for my $each_element (@$elements) {
		$changes += $self->process_each_sub( $each_element );
	}

	return 1;
}

sub process_each_sub {
	my ($self, $each_element) = @_;
	my $changes = 0;

	## Find the type of sub (method, classmethod, fun)
	#PPI::Dumper->new( $each_element )->print;#DEBUG
	my $sub_type = $each_element->schild(0); # one of SUBNAMES
	return 0 if $sub_type eq 'sub';
	die "Unrecognised sub type: $sub_type" unless any { $_ eq $sub_type } SUBNAMES;

	my ($name, $args);

	## Find the sub name
	my $step = 1;
	if( $each_element->schild($step)->isa('PPI::Token::Label')
			or $each_element->schild($step)->isa('PPI::Token::Word') ) {
		$name = $each_element->schild($step);
		$name =~ s/ :$//;
		die "Name has : $name" if $name =~ /:/;
		$step++;
	} else {
		$name = "ANON";
	}

	## Find the argument list of the sub
	my $has_actual_args = 0;
	if( $each_element->schild($step)->isa('PPI::Structure::List') ) {
		$args = $each_element->schild($step);
		$changes += $args->prune( 'PPI::Structure::List' ); # remove type expressions
		$has_actual_args = 1;
		#PPI::Dumper->new( $args )->print;#DEBUG
	} else {
		$args = '()';
	}


	## Generate code from template
	my $simple_sub = "$sub_type $name $args";
	#say $simple_sub;#DEBUG
	my $perl_to_deparse = $TEMPLATE =~ s/<REPLACE>/$simple_sub/r;
	my $ppi_block = $self->ppi_deparsed_block( $perl_to_deparse );

	# Remove extra whitesapce
	$ppi_block->prune(sub {
		$_[1]->isa('PPI::Token::Whitespace') or return '';
		$_[1]->parent->isa('PPI::Structure::Block') or return '';
		return 1;
	});

	## Remove the sentinel value
	$ppi_block->prune(sub {
		$_[1]->isa('PPI::Statement') or return '';
		$_[1]->schild(0)->content eq '42' or return '';
		return 1;
	});

	#PPI::Dumper->new($ppi_block)->print;#DEBUG

	## Add uncoverable comments for the new code in the deparsed block
	$ppi_block->{children} = [
		(
			map {
				my $uncoverable = "";
				my $code = "$_";
				if ( $code =~ / if / ) {
					$uncoverable .= "# uncoverable branch true\n";
				}
				$code =~ s/^\s+//; # remove leading whitespace to pass Perl::Critic
				PPI::Token->new("\n$uncoverable$code"), # hack to insert verbatim
			} @{ $ppi_block->{children} },
		),
		PPI::Token->new("\n"),
	];
	#print "@{[ $ppi_block ]}";#DEBUG

	## Insert the deparsed code and comments at the beginning of the target sub
	my $block_to_change = $each_element->block;
	#print "@{[ $block_to_change ]}";#DEBUG
	while( @{ $ppi_block->{children} } ) {
		my $element_to_insert = pop @{ $ppi_block->{children} };
		$block_to_change->child(0)->insert_before( $element_to_insert );
	}
	#print "@{[ $block_to_change ]}";#DEBUG

	{
		# change from F::P name to plain sub
		$sub_type->set_content('sub');

		# remove the argument list
		if( $has_actual_args ) {
			$args->remove;
		}
		$changes += 1;
	}

	## Need to delete the list in the fake PPI::Statement::Sub if we are
	## dealing with an anon sub
	if( $each_element->{right_before} ) {
		while( @{ $each_element->{children} } ) {
			my $element_to_insert = shift @{ $each_element->{children} };
			#$each_element->{right_before}->insert_after( $element_to_insert );
		}
	}

	#print "@{[ $each_element ]}";#DEBUG

	return $changes;
}

sub ppi_deparsed_block {
	my ($self, $perl_to_deparse) = @_;

	open2( my $out, my $in, 'perl -Ilib -MO=Deparse -');

	#say "$perl_to_deparse";
	say $in $perl_to_deparse;
	close $in;

	my $deparsed_perl = join "", <$out>;

	#say $deparsed_perl;#DEBUG
	my $ppi_deparse = PPI::Document->new(\$deparsed_perl);
	#PPI::Dumper->new($ppi_deparse)->print;#DEBUG
	$ppi_deparse->prune('PPI::Statement::Scheduled');
	$ppi_deparse->prune('PPI::Statement::Include');
	my ($ppi_sub) = @{ $ppi_deparse->find('PPI::Statement::Sub') };

	# Note: must clone because $ppi_deparse goes out of scope and causes GC
	return $ppi_sub->block->clone;
}

sub remove_return_type_sub_attribute {
	my ($self, $document) = @_;
	my $rt_elements = $document->find(sub {
		$_[1]->isa('PPI::Token::Word') or return '';
		"$_[1]" eq 'ReturnType' or return '';
		return 1;
	}) || [];
	for my $rt ( @$rt_elements ) {
		my $name = $rt->parent->schild(1);
		if( $name->content =~ /:/ ) {
			$name->content( $name->content =~ s/://r );
		}
		$rt->next_sibling->remove; # remove list after this
		$rt->remove; # remove self
	}
}


sub find_statement_and_anonymous_subs {
	my ($self, $document) = @_;
	#PPI::Dumper->new( $document )->print;#DEBUG
	my $elements = $document->find(sub {
		$_[1]->isa('PPI::Statement::Sub') or return '';
		not $_[1]->isa('PPI::Statement::Scheduled') or return '';
		return 1;
	}) || [];

	my $regexp = qr/^(@{[ join "|", SUBNAMES ]})$/;
	my $anon_sub_token = $document->find(sub {
		$_[1]->isa('PPI::Token::Word') or return '';
		not $_[1]->parent->isa('PPI::Statement::Sub') or return '';
		$_[1]->content =~ $regexp or return '';
		return 1;
	}) || [];

	for my $anon_sub (@$anon_sub_token) {
		my @part_of_sub;
		my $current_child = $anon_sub;
		my $right_before = $current_child->previous_sibling;
		my $reached_block = 0;
		do {
			$reached_block = 1 if $current_child->isa('PPI::Structure::Block');
			push @part_of_sub, $current_child;
			$current_child = $current_child->next_sibling;
		} while( not $reached_block );
		my $sub = PPI::Statement::Sub->new;
		$sub->{right_before} = $right_before;
		$sub->{children} = \@part_of_sub;
		push @$elements, $sub;
	}

	$elements;
}

1;
