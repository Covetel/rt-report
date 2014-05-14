#!/usr/bin/env perl
use strict;
use warnings;
use Covetel::RT;
use 5.010;
use Data::Dumper;

my $rt = Covetel::RT->new();

my @ids = $rt->client->search(
    type => 'ticket',
    query => "LinkedTo = 54",
    orderby => '-id',
);

my @tickets = $rt->tickets(@ids);

foreach (@tickets){
    say "\n\n";
    say "#".$_->id.":"; 
    say "-" x 30;
    say "Asunto: " . $_->base->subject;
    say "Fecha: " . $_->base->created;
    my $body = $_->body;
    say "Cuerpo del Ticket:";
    say $body->{content};
    say "Horas Trabajadas: ". $_->horas;

    my $comentarios = $_->comments; 
    if ($comentarios > 0){
        say "Comentarios:\n";
        foreach my $comentario ($_->comments){

            say "Autor: ".$comentario->{creator};
            say $comentario->{content};
        }
    }
}

=pod 
my $ticket = $rt->ticket(4);

my @comments = $ticket->comments();

print Dumper $ticket->base->created;
print Dumper $ticket->base->owner;
print Dumper $ticket->base->status;
print Dumper $ticket->base->subject;
print Dumper $ticket->base->time_worked;
print Dumper @comments;

#say $ticket->transactions->count();

=cut 



=pod
my $rt = RT::Client::REST->new(
    server => 'http://localhost:8000',
    timeout => 30,
);

$rt->login(username => 'root', password => 'password');

=pod 

my @ids = $rt->search(
    type => 'ticket',
    query => "LinkedTo = 5",
    orderby => '-id',
  );


foreach my $id (@ids){
    my $ticket = RT::Client::REST::Ticket->new(
            rt => $rt,
            id => $id,
    )->retrieve;
    
    print Dumper $ticket;

}


my @tickets;

my $ticket = RT::Client::REST::Ticket->new(rt => $rt,  id => 4)->retrieve; 
my $transactions = $ticket->transactions;

my $iterator = $transactions->get_iterator;
  while (my $tr = &$iterator) {
      print "Id: ", $tr->id, "; Type: ", $tr->type, "\n";
      if ($tr->type eq 'Comment' || $tr->type eq 'Create'){
        say $tr->content;
      }
  }
=cut 
