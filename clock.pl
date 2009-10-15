use strict;
use Error::Die; # DEPEND
use TimeCard; # DEPEND
use Editor; # DEPEND

my $TIMECARD = "$ENV{HOME}/.timecard";

my $what = shift;

if ($what eq 'in') {
  my $tc = TimeCard->new($TIMECARD);
  $tc->punch_in(@ARGV ? join(' ', @ARGV) : undef);
  $tc->save($TIMECARD);
}

elsif ($what eq 'out') {
  my $tc = TimeCard->new($TIMECARD);
  $tc->punch_out(@ARGV ? join(' ', @ARGV) : undef);
  $tc->save($TIMECARD);
}

elsif ($what eq 'edit') {
  my $e = Editor::guess;
  exec $e, $TIMECARD
    or die "unable to exec editor '$e': $!";
}

else {
  die "unknown subcommand: $what";
}
