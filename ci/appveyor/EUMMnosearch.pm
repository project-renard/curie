package EUMMnosearch;

package main;
# only run when we call the Makefile.PL script
if( $0 eq "Makefile.PL"  ) {
	require ExtUtils::MakeMaker;

	my $i = ExtUtils::MakeMaker->can("import");
	no warnings "redefine";
	*ExtUtils::MakeMaker::import = sub {
		&$i;
		my $targ = caller;
		my $wm = $targ->can("WriteMakefile");
		*{"${targ}::WriteMakefile"} = sub {
			my %args = @_;
			$args{LIBS} =~ s/^/:nosearch /;
			$wm->(%args);
		};
	};

        do "Makefile.PL" or die "Hack failed: $@";

        # we can exit now that we are done
        exit 0;
}

1;
