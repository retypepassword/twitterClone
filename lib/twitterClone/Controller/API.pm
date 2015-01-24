package twitterClone::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

# Create POST, GET, PUT, and DELETE handlers for the action tweet. I'm only using
# POST here, because not all browsers support PUT (apparently).
sub tweet : Local ActionClass('REST') { }

# Handles posting a tweet and returns all the associated information (username, author, date, etc.)
# so it can be displayed below the tweet box automagically after the tweet is posted. Also includes
# the tweet's id for the delete button.
# 
# Input: The tweet's text (POST: tweet).
#
# Output: All information associated with the tweet
sub tweet_POST {
  my ($self, $c) = @_;

  # Make sure the user is logged in.
  $c->forward('/account/authenticate');

  # Post a tweet for the logged in user
  if ($c->session->{user_id}) {
    # Retrieve tweet from params
    my $text = $c->request->params->{tweet} || '';

    # Post the tweet
    my $wholetweet = $c->model('DB::Tweet')->create({
      text => $text,
      user_id => $c->session->{user_id},
      date => DateTime->now
    });

    # Create relationships for any hashtags or @people that showed up in the tweet's text.
    $wholetweet->updateTagsAndPeople();

    $self->status_created(
      $c,
      location => $c->req->uri->as_string,
      entity => {
        id => $wholetweet->id,
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

# Actions for delete_tweet
sub delete_tweet : Local ActionClass('REST') { }

# Deletes a tweet, given the tweet's id (obviously authenticates first).
#
# Input: tweet id (POST: tweet)
#
# Output: Success status
sub delete_tweet_POST {
  my ($self, $c) = @_;

  # Make sure the user is logged in.
  $c->forward('/account/authenticate');

  if ($c->session->{user_id}) {
    # Get the tweet's id
    my $id = $c->request->params->{tweet} || '';

    # Find it and delete it.
    my $tweet = $c->model('DB')->resultset('Tweet')->find({ id => $id });
    if ($tweet && $tweet->user_id == $c->session->{user_id}) {
      # The delete used here is from DBIx::Class::Row, which does cascading deletes, and
      # deletes the relationships between this tweet and any relevant hashtags/people.
      $tweet->delete;

      # Success status.
      $self->status_accepted(
        $c,
        entity => { success => 1 }
      );
    }
    else {
      $self->status_bad_request($c, message => "You did not create this tweet, so you can't delete it");
    }
  }
  else {
    $self->status_bad_request($c, message => "Not logged in");
  }
}

sub follow : Local ActionClass('REST') { }

# Creates row specifying relationship between a followed user and the following user.
#
# Input: user id to be followed (POST: uid)
#        whether to follow or to un-follow the user (POST: action)
#
# Output: Success status

sub follow_POST {
  my ($self, $c) = @_;

  # Make sure the user is logged in
  $c->forward('/account/authenticate');

  if ($c->session->{user_id}) {
    # Get the user id for the user that this logged in user wants to follow or unfollow
    my $uid = $c->request->params->{uid} || '';
    # and what the user wants to do (follow or unfollow)
    my $del = $c->request->params->{action} || '';

    # success status
    my $didit = 0;

    # ORM resultset for the followed table. Creating it here so we can reuse it for
    # following or unfollowing.
    my $followed_set = $c->model('DB')->resultset('Followed');
    
    # The row to be created (contains the follower's user id and the followed's user id)
    my $obj = {
          followed_id => $uid,
          follower_id => $c->session->{user_id}
        };

    # Make sure a user was specified
    if ($uid ne '') {
      if ($del eq "follow") {
        # Add the relationship if the user wants to follow the other user
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
          # Delete the relationship otherwise.
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
