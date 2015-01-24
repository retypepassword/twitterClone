package twitterClone::Controller::Account;
use Moose;
use Digest::SHA qw/sha1_hex/;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

twitterClone::Controller::account - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub create :Path('create') :Args(0) {
    my ( $self, $c ) = @_;

    my ( $uname, $name, $pass ) = ($c->request->params->{uname},
                                   $c->request->params->{name},
                                   sha1_hex($c->request->params->{uname}.$c->request->params->{pass}));

    my $check = $c->model('DB')->resultset('User')->find({
      user => $uname
    });

    if ( ! defined $check && length $c->request->params->{pass} > 0 && length $uname > 0 && length $name > 0) {
      my $u = $c->model('DB')->resultset('User')->create({
        user => $uname,
        passphrase => $pass,
        name => $name,
        private => 0
      });

      $c->session->{user_id} = $u->id;
      $c->session->{uname} = $uname;
      $c->session->{passphrase} = $pass;
      $c->session->{private} = 0;

      $c->response->content_type("application/json");
      $c->response->body('{"status" : "User created", "user" : "'. $uname. '"}');
    }
    else {
      $c->response->content_type("application/json");
      $c->response->body('{"status" : "User already exists or not all fields filled in! Try again."}');
    }
}

sub login :Path('login') :Args(0) {
    my ( $self, $c ) = @_;

    my ( $uname, $pass ) = ($c->request->params->{uname},
                            sha1_hex($c->request->params->{uname}.$c->request->params->{pass}));

    my $check = $c->model('DB')->resultset('User')->find({
      user => $uname
    });

    if ( defined $check && $check->passphrase eq $pass ) {
      $c->session->{user_id} = $check->id;
      $c->session->{uname} = $check->user;
      $c->session->{passphrase} = $pass;
      $c->session->{private} = $check->private;

      $c->response->content_type("application/json");
      $c->response->body('{"status" : "Logged in", "user" : "'. $check->user.'"}');
    }
    else {
      $c->response->content_type("application/json");
      $c->response->body('{"status" : "Wrong username and/or password"}');
    }
}

sub private :Path('private') :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('authenticate');

    my $action = $c->request->params->{action};

    my $check = $c->model('DB')->resultset('User')->find({
      id => $c->session->{user_id}
    });

    if ( defined $check ) {
      $check->update({
        private => $action eq "private" ? 1 : 0
      });

      $c->response->content_type("application/json");
      $c->response->body('{"success" : 1, "result" : "Successfully marked ' . $action . '"}');
    }
    else {
      $c->response->body('{"success" : 0}');
    }
}

sub authenticate :Path('auth') {
  my ( $self, $c ) = @_;
 
  my $check = $c->model('DB')->resultset('User')->find({
    id => $c->session->{user_id}
  });

  if ( ! defined $check || $check->user ne $c->session->{uname} ||
       $check->passphrase ne $c->session->{passphrase}) {
    delete $c->session->{user_id};
    delete $c->session->{uname};
    delete $c->session->{passphrase};
  }
  else {
    $c->session->{private} = $check->private;
  }
}

sub delete :Path('delete') {
  my ($self, $c) = @_;

  $c->forward('authenticate');

  if ($c->request->params->{confirm}) {
    my $user = $c->model('DB')->resultset('User')->search({
      id => $c->session->{user_id}
    });

    $user->delete_all;
    $c->detach('signout');
  }
  else {
    $c->stash->{'template'} = 'account/confirm.tt2';
  }
}

sub signout :Path('signout') {
  my ( $self, $c ) = @_;

  delete $c->session->{user_id};
  delete $c->session->{uname};
  delete $c->session->{passphrase};

  $c->response->redirect($c->uri_for('/'));
}


=encoding utf8

=head1 AUTHOR

Eric Fleming Lin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
