package Covetel::RT::Ticket;
use Moose;
use RT::Client::REST::Ticket;
use RT::Client::REST::User;
use Data::Dumper;
use utf8;

extends 'Covetel::RT';

has id => (
    is => "rw", 
    isa => "Int"
);

has base => (
    is  => "rw", 
    isa => "RT::Client::REST::Ticket",
    lazy => 0, 
    builder => "_builder_base", 
);

has comentarios => (
    is => "rw", 
    isa => 'ArrayRef[HashRef]', 
    lazy => 0, 
    builder => "_build_comentarios", 
);

has adjuntos => (
    is => "rw", 
    isa => 'ArrayRef[HashRef]', 
    lazy => 1, 
    builder => "_build_adjuntos", 
);

has asunto => (
    is => "rw", 
    isa => 'Str', 
    lazy => 0, 
    builder => "_build_asunto", 
);


sub _builder_base {
    my $self = shift; 
    return RT::Client::REST::Ticket->new( id => $self->id,  rt => $self->client )->retrieve;
}

sub _build_asunto {
    my $self = shift;
    my $asunto = $self->base->subject;
    return $asunto;
}

sub user {
    my ($self, $uid ) = @_;
    my $user = RT::Client::REST::User->new(
        rt => $self->client, 
        id => $uid
    )->retrieve;
    if ($user) {
        return
              $user->{_real_name} . " "
            . "(" . $user->{_email_address} . ") ";
    } else {
        return '';
    }
 
}

sub comments {
    my $self = shift; 
    my $transactions = $self->base->transactions(type => [qw/Comment/]);
    my $iterator = $transactions->get_iterator;
    my @comments; 
    while (my $tr = &$iterator) {
        my $content = $tr->content;
        push @comments,
          {
            content => $content,
            date    => $tr->created,
            creator => $self->user($tr->creator), 
            description => $tr->description 
          };
    }
    return @comments;
}

sub _build_comentarios {
    my $self = shift; 
    my $transactions = $self->base->transactions(type => [qw/Comment/]);
    my $iterator = $transactions->get_iterator;
    my @comments; 
    while (my $tr = &$iterator) {
        my $content = $tr->content;
        push @comments,
          {
            content => $content,
            date    => $tr->created,
            creator => $self->user($tr->creator), 
            description => $tr->description 
          };
    }
    my @adjuntos = $self->adjuntos();
    return \@comments;
}

sub _build_adjuntos {
    my $self = shift;

    my $attachments = $self->base->attachments;
    my @adjuntos; 

    my $count = $attachments->count;
    if ($count){
        my $iterator = $attachments->get_iterator;
        while (my $att = &$iterator) {
            next if $att->subject =~ /^\[\w+/; 
                my $content;
                if ($att->{_file_name} =~ /\.txt/){
                     $content = $att->content;
                     $content =~ s/^/ /gm;
                }
                if ($att->{_file_name}){
                    push @adjuntos, {
                        content_type => $att->content_type, 
                        file_name    => $att->{_file_name}, 
                        subject      => $att->{_subject}, 
                        content      => $content,  
                    }
                }
        }
    }
    return \@adjuntos;
}

sub body {
    my $self = shift; 
    my $transactions = $self->base->transactions(type => [qw/Create/]);
    my $iterator = $transactions->get_iterator;
    while (my $tr = &$iterator) {
            my $content = $tr->content;
          return {
            content => $content,
            date    => $tr->created,
            creator => $tr->creator, 
            description => $tr->description 
          };
    }
}

sub horas {
    my $self = shift; 
    my $minutos = $self->base->time_worked; 
    $minutos =~ s/minutes//;
    $minutos =~ s/\s+//g;
    if ($minutos){
        return sprintf "%d", $minutos/60;
    } else {
        return 0;
    }
}

1;

