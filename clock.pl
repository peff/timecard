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

elsif ($what eq 'sum') {
  my $tc = TimeCard->new($TIMECARD);
  my $total = DateTime::Duration->new;
  $total += $_->duration foreach $tc->slots;
  my $hours = $total->hours + ($total->minutes / 60);
  printf "%.2f hours\n", $hours;
}

else {
  die "unknown subcommand: $what";
}
