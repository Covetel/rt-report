#!/usr/bin/env perl
use strict;
use warnings;
use Covetel::RT;
use 5.010;
use Template;
use Data::Dumper;
use utf8;

my $ticket = shift;

my $config = {
               INCLUDE_PATH => 'Templates/',  # or list ref
               OUTPUT_PATH       => 'Pod/', 
               ENCODING => 'utf8', 
           };

my $template = Template->new($config);

my $rt = Covetel::RT->new();

my @ids = $rt->client->search(
    type => 'ticket',
    query => "LinkedTo = 136",
    orderby => '-id',
);

my @tickets;

if ($ticket){
	@tickets = $rt->tickets($ticket);
} else {
	@tickets = $rt->tickets(@ids);
}

say "Procesando la plantilla: ";

my $vars = { tickets => \@tickets };

$template->process('tickets.pod.tt2', $vars, 'tickets.pod', binmode => ':utf8') || die $template->error();
