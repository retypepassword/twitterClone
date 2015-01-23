use utf8;
package twitterClone::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

twitterClone::Schema::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 passphrase

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 private

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "passphrase",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "private",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 followed_followeds

Type: has_many

Related object: L<twitterClone::Schema::Result::Followed>

=cut

__PACKAGE__->has_many(
  "followed_followeds",
  "twitterClone::Schema::Result::Followed",
  { "foreign.followed_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 followed_followers

Type: has_many

Related object: L<twitterClone::Schema::Result::Followed>

=cut

__PACKAGE__->has_many(
  "followed_followers",
  "twitterClone::Schema::Result::Followed",
  { "foreign.follower_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tweets_2s

Type: has_many

Related object: L<twitterClone::Schema::Result::Tweet>

=cut

__PACKAGE__->has_many(
  "tweets_2s",
  "twitterClone::Schema::Result::Tweet",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tweets_to

Type: has_many

Related object: L<twitterClone::Schema::Result::TweetTo>

=cut

__PACKAGE__->has_many(
  "tweets_to",
  "twitterClone::Schema::Result::TweetTo",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 followeds

Type: many_to_many

Composing rels: L</followed_followeds> -> followed

=cut

__PACKAGE__->many_to_many("followeds", "followed_followeds", "followed");

=head2 followers

Type: many_to_many

Composing rels: L</followed_followeds> -> follower

=cut

__PACKAGE__->many_to_many("followers", "followed_followeds", "follower");

=head2 tweets

Type: many_to_many

Composing rels: L</tweets_to> -> tweet

=cut

__PACKAGE__->many_to_many("tweets", "tweets_to", "tweet");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2015-01-22 20:50:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9zZ2lFDwrdcM5n3U+FC9rg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
