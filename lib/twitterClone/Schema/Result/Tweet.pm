use utf8;
package twitterClone::Schema::Result::Tweet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

twitterClone::Schema::Result::Tweet

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

=head1 TABLE: C<tweet>

=cut

__PACKAGE__->table("tweet");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 text

  data_type: 'varchar'
  is_nullable: 1
  size: 141

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "text",
  { data_type => "varchar", is_nullable => 1, size => 141 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 tweet_hashtags

Type: has_many

Related object: L<twitterClone::Schema::Result::TweetHashtag>

=cut

__PACKAGE__->has_many(
  "tweet_hashtags",
  "twitterClone::Schema::Result::TweetHashtag",
  { "foreign.tweet_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tweets_to

Type: has_many

Related object: L<twitterClone::Schema::Result::TweetTo>

=cut

__PACKAGE__->has_many(
  "tweets_to",
  "twitterClone::Schema::Result::TweetTo",
  { "foreign.tweet_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hashtags

Type: many_to_many

Composing rels: L</tweet_hashtags> -> hashtag

=cut

__PACKAGE__->many_to_many("hashtags", "tweet_hashtags", "hashtag");

=head2 users

Type: many_to_many

Composing rels: L</tweets_to> -> user

=cut

__PACKAGE__->many_to_many("users", "tweets_to", "user");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2015-01-22 07:52:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2swb34l5PGHMeBWyJevG9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
