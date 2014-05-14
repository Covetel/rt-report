#!/usr/bin/env perl
use strict;
use warnings;
use Covetel::RT;
use 5.010;
use Template;
use Data::Dumper;
use utf8;

my $ticket = shift;
my $horas = 0;
my $tickets = 0;
my $rt = Covetel::RT->new();

my @ids = $rt->client->search(
    type => 'ticket',
    query => "LinkedTo = $ticket",
    orderby => '-id',
);

push @ids, $ticket;

my @tickets = $rt->tickets(@ids);

foreach (@tickets){
   print $_->id." ".$_->asunto."\n";
   $tickets++;
   $horas += $_->horas; 
}

print "Horas: $horas\n";
print "Tickets: $tickets\n";
