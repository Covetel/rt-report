#!/usr/bin/env perl
use strict;
use warnings;
use Covetel::RT;
use 5.010;
use Template;

my $config = {
               INCLUDE_PATH => 'Templates/',  # or list ref
               OUTPUT_PATH       => 'Latex/', 
               INTERPOLATE  => 1,               # expand "$var" in plain text
               POST_CHOMP   => 1,               # cleanup whitespace
               EVAL_PERL    => 1,               # evaluate Perl code blocks
           };

my $template = Template->new($config);

my $rt = Covetel::RT->new();

my @ids = $rt->client->search(
    type => 'ticket',
    query => "LinkedTo = 54",
    orderby => '-id',
);

my @tickets = $rt->tickets(@ids);

say "Procesando la plantilla: ";

my $vars = { tickets => \@tickets };

$template->process('tickets.tex.tt2', $vars, 'tickets.tex') || die $template->error();
