use strict;
use warnings;

use twitterClone;

my $app = twitterClone->apply_default_middlewares(twitterClone->psgi_app);
$app;

