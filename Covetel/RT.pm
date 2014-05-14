package Covetel::RT;
use Moose;
use RT::Client::REST;
use Config::Any::General;
use Covetel::RT::Ticket;
use 5.010;
use utf8;

has config => (
    is      => "ro",
    isa     => "HashRef",
    lazy    => 1,
    builder => "_build_read_config"
);

has config_file => (
    is      => "rw",
    isa     => "Str",
    lazy    => 1,
    default => 'config.conf'
);

has client => (
    is      => "rw", 
    isa     => "RT::Client::REST", 
    lazy    => 1, 
    builder => "_build_client", 
);

sub _build_read_config {
	my $self = shift; 
    my $c = Config::Any::General->load($self->config_file);
	return $c;	
}

sub _build_client {
    my $self = shift; 
    my $server  = $self->config->{'Covetel::RT'}->{'server'}; 
    my $port    = $self->config->{'Covetel::RT'}->{'port'}; 
    my $user    = $self->config->{'Covetel::RT'}->{'user'}; 
    my $password    = $self->config->{'Covetel::RT'}->{'password'}; 

    my $rt = RT::Client::REST->new(
        server => $server,
        timeout => 200,
    );

    $rt->login(username => $user, password => $password);

    return $rt;
}

sub ticket  {
    my ($self, $id) = @_; 
    my $ticket = Covetel::RT::Ticket->new(id => $id);
    return $ticket;
}

sub tickets {
    my ($self, @ids) = @_; 
    my @tickets;
    foreach (@ids){
        say $_;
        my $ticket = Covetel::RT::Ticket->new(id => $_);
        push @tickets, $ticket;
    }
    return @tickets;
}


1;
