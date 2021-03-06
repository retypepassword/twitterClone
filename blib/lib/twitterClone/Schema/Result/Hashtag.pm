use utf8;
package twitterClone::Schema::Result::Hashtag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

twitterClone::Schema::Result::Hashtag

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

=head1 TABLE: C<hashtag>

=cut

__PACKAGE__->table("hashtag");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tag

  data_type: 'varchar'
  is_nullable: 1
  size: 140

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "tag",
  { data_type => "varchar", is_nullable => 1, size => 140 },
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
  { "foreign.tag_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tweets

Type: many_to_many

Composing rels: L</tweet_hashtags> -> tweet

=cut

__PACKAGE__->many_to_many("tweets", "tweet_hashtags", "tweet");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2015-01-22 20:50:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hf/neSsavdhJTQx9ZX1KxQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
