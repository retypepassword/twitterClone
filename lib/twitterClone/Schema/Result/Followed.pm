use utf8;
package twitterClone::Schema::Result::Followed;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

twitterClone::Schema::Result::Followed

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

=head1 TABLE: C<followed>

=cut

__PACKAGE__->table("followed");

=head1 ACCESSORS

=head2 followed_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 follower_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "followed_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "follower_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</followed_id>

=item * L</follower_id>

=back

=cut

__PACKAGE__->set_primary_key("followed_id", "follower_id");

=head1 RELATIONS

=head2 followed

Type: belongs_to

Related object: L<twitterClone::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "followed",
  "twitterClone::Schema::Result::User",
  { id => "followed_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 follower

Type: belongs_to

Related object: L<twitterClone::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "follower",
  "twitterClone::Schema::Result::User",
  { id => "follower_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2015-01-21 23:58:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T/HpSyyRpVpeX0oghqr5nw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
