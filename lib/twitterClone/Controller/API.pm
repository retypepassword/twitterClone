package twitterClone::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

sub tweet : Local ActionClass('REST') { }

sub tweet_POST {
  my ($self, $c) = @_;

  $c->forward('account/authenticate');

  if ($c->session->{user_id}) {
    # Retrieve tweet from params
    my $text = $c->request->params->{tweet} || '';

    my $wholetweet = $c->model('DB::Tweet')->create({
      text => $text,
      user_id => $c->session->{user_id},
      date => DateTime->now
    });

    $wholetweet->updateTagsAndPeople();
    $self->status_created(
      $c,
      location => $c->req->uri->as_string,
      entity => {
        text => $wholetweet->html(),
        username => $wholetweet->user->user,
        author => $wholetweet->user->name,
        date => $wholetweet->getDate(),
      },
    );
  }
  else {
    $self->status_bad_request($c, message => "Not logged in");
  }
}

sub follow : Local ActionClass('REST') { }

sub follow_POST {
  my ($self, $c) = @_;

  $c->forward('account/authenticate');

  if ($c->session->{user_id}) {
    my $uid = $c->request->params->{uid} || '';
    my $del = $c->request->params->{action} || '';
    my $didit = 0;
    my $followed_set = $c->model('DB')->resultset('Followed');
    my $obj = {
          followed_id => $uid,
          follower_id => $c->session->{user_id}
        };

    if ($uid ne '') {
      if ($del eq "follow") {
        my $followed = $followed_set->create($obj);

        $didit = 1;

        $self->status_created(
          $c,
          location => $c->req->uri->as_string,
          entity => { success => $didit }
        );
      }
      else {
        my $followed = $followed_set->find($obj);
        if ($followed) {
          $followed->delete;

          $self->status_accepted(
            $c,
            entity => { success => 1 }
          );
        }
      }
    }
    else {
      $self->status_bad_request($c, message => "No user specified");
    }
  }
  else {
    $self->status_bad_request($c, message => "Not logged in");
  }
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
