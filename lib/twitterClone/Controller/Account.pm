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


# Creates an account. Stores the data in TABLE USER in plaintext, except for the password, which is
# hashed with SHA1.
#
# Input: POST parameters: uname (desired username), name (real name), pass (password)
#
# Output: application/json with information about whether or not account creation was successful, and if
# not, if there were any errors. Also includes the username so javascript caller can change the page
# to the user's new profile

sub create :Path('create') :Args(0) {
    my ( $self, $c ) = @_;

    my ( $uname, $name, $pass ) = ($c->request->params->{uname},
                                   $c->request->params->{name},
                                   sha1_hex($c->request->params->{uname}.$c->request->params->{pass}));

    # Make sure the username specified doesn't already exist.
    my $check = $c->model('DB')->resultset('User')->find({
      user => $uname
    });

    # Don't create an account if any of the fields were left blank.
    if ( ! defined $check && length $c->request->params->{pass} > 0 && length $uname > 0 && length $name > 0) {
      my $u = $c->model('DB')->resultset('User')->create({
        user => $uname,
        passphrase => $pass,
        name => $name,
        private => 0
      });

      # Store user information in the session cookie. These data are used throughout the site for
      # deciding what to display.
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

# Logs in to an account (by putting user info in session storage), if supplied credentials are correct
#
# Input: POST parameters: uname (username), pass (password).
#
# Output: Information about whether or not log in was successful and the user's username (for Javascript
# to redirect the user to their profile).

sub login :Path('login') :Args(0) {
    my ( $self, $c ) = @_;

    my ( $uname, $pass ) = ($c->request->params->{uname},
                            sha1_hex($c->request->params->{uname}.$c->request->params->{pass}));

    # Make sure the user exists
    my $check = $c->model('DB')->resultset('User')->find({
      user => $uname
    });

    # Make sure they gave a password
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

# Sets an account as private/public, depending on input. Alters the column `private` in TABLE USER.
# In the column, 1 means private, and 0 means public.
#
# Input: POST parameter: action (valid values: private or unprivate). The action parameter specifies
# whether or not an account should be made private (private) or public (unprivate).
#
# Output: Success status (application/json)

sub private :Path('private') :Args(0) {
    my ( $self, $c ) = @_;

    # Make sure the user is properly logged in and hasn't altered any session data (i.e., the user and
    # password session variables have to match up).
    $c->forward('authenticate');

    # Find out which action is requested
    my $action = $c->request->params->{action};

    # Get the user for this session.
    my $check = $c->model('DB')->resultset('User')->find({
      id => $c->session->{user_id}
    });

    # Alter the private state depending on the action.
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

# Authenticates/double checks the current session variables. Makes sure the user id, username,
# and password all match up to what's in the database. In the unlikely event that they've been
# altered, deletes the session variables and logs out the user.

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

# Deletes the account for the user who is logged in. Requires confirmation before continuing.
#
# Input: None (shows confirmation page)
#        POST Parameter: confirm. Empty variable that confirms the user wants to delete their
#                        account.
# 
# Output: Confirmation page or none.

sub delete :Path('delete') {
  my ($self, $c) = @_;

  $c->forward('authenticate');

  # Only delete the user's account if they've confirmed that they want it deleted.
  if ($c->request->params->{confirm}) {
    # Could have used resultset->find here, too, and then DBIx::Row::delete to
    # do the cascading delete.
    my $user = $c->model('DB')->resultset('User')->search({
      id => $c->session->{user_id}
    });

    # delete_all does cascading deletes for ResultSets (which are returned by search)
    $user->delete_all;

    # Delete the user's session variables. Authenticate would be a hacky way to do this,
    # but should technically work, barring race conditions.
    $c->detach('signout');
  }
  else {
    $c->stash->{'template'} = 'account/confirm.tt2';
  }
}

# Signs out the logged in user. Deletes session variables and returns to /.

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
