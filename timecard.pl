use strict;
use Error::Die; # DEPEND
use TimeCard; # DEPEND
use Editor; # DEPEND

my $TIMECARD = $ENV{TIMECARD} || "$ENV{HOME}/.timecard";

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

elsif ($what eq 'comment') {
  my $tc = TimeCard->new($TIMECARD);
  $tc->comment(@ARGV ? join(' ', @ARGV) : undef);
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
  print $total->timecard_hours, " hours\n";
}

elsif ($what eq 'list') {
  my $tc = TimeCard->new($TIMECARD);
  foreach my $slot ($tc->slots) {
    print $slot->duration->timecard_hours, ' ';
    print join(' / ', $slot->comments);
    print "\n";
  }
}

elsif (!$what) {
  my $tc = TimeCard->new($TIMECARD);
  my $slot = $tc->recent;
  if ($slot && $slot->in_progress) {
    print "You are currently punched IN (",
            $slot->duration->timecard_hours, " hours)\n";
    if ($slot->comments) {
      print "Comments:\n";
      print $_, "\n" foreach $slot->comments;
    }
  }
  else {
    print "You are currently punched OUT.\n";
  }
}

else {
  die "unknown subcommand: $what";
}
