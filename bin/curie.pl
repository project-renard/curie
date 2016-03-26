#!/usr/bin/env perl
# PODNAME: curie: a document reader

use Modern::Perl;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Renard::Curie::App;

Renard::Curie::App::main;
