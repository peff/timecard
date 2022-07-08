package TimeSlot;
use strict;
use overload '""' => \&as_string;
use DateTime;

sub DateTime::Duration::timecard_hours {
  sprintf '%.2f', $_[0]->hours + ($_[0]->minutes / 60);
}

sub new_from_data {
  my $self = bless {}, shift;

  $self->{start} = shift;
  $self->{start} ||= _now();
  $self->{end} = shift;
  $self->{end} ||= 'INPROGRESS';
  $self->{comments} = [@_];

  return $self;
}

sub new_from_fh {
  my $self = bless {}, shift;
  my $fh = shift;

  $self->{comments} = [];

  while(<$fh>) {
    chomp;

    if (!$self->{start}) {
      next if /^$/;
      /^\d+-\d+-\d+ \d+:\d+$/
        or die "invalid start time: $_";
      $self->{start} = $_;
    }

    elsif (!$self->{end}) {
      /^(\d+-\d+-\d+ )?\d+:\d+$/ ||
      /^INPROGRESS$/
        or die "invalid end time: $_";
      $self->{end} = $_;
    }

    else {
      return $self if /^$/;
      push @{$self->{comments}}, $_;
    }
  }

  return defined($self->{start}) ? $self : undef;
}

sub print {
  my $self = shift;
  my $fh = shift;

  print $fh $self->{start}, "\n";
  print $fh $self->{end}, "\n";
  print $fh $_, "\n" foreach @{$self->{comments}};
}

sub as_string {
  my $self = shift;
  return "$self->{start} - $self->{end}";
}

sub in_progress {
  my $self = shift;
  return $self->{end} eq 'INPROGRESS';
}

sub finish {
  my $self = shift;
  $self->{end} = shift;
  $self->{end} ||= _now();
  push @{$self->{comments}}, @_;
}

sub comment {
  my $self = shift;
  push @{$self->{comments}}, @_;
}

sub comments {
  my $self = shift;
  return @{$self->{comments}};
}

sub duration {
  my $self = shift;
  my ($start, $end) = $self->_times;
  $end >= $start
    or die "backwards time: $self->{start} - $self->{end}";
  return $end - $start;
}

sub date {
  my $self = shift;
  return (split / /, $self->{start})[0];
}

sub _now_dt {
  return DateTime->now(time_zone => 'local');
}

sub _now {
  my $now = _now_dt();
  return sprintf('%d-%02d-%02d %02d:%02d',
    $now->year, $now->month, $now->day, $now->hour, $now->minute
  );
}

sub _times {
  my $self = shift;

  $self->{start} =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+)$/
    or die "unable to parse start time: $self->{start}";
  my $start = DateTime->new(
    year => $1, month => $2, day => $3,
    hour => $4, minute => $5,
    time_zone => 'local'
  );

  my $end =
    $self->{end} =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+)$/ ?
      DateTime->new(
        year => $1, month => $2, day => $3,
        hour => $4, minute => $5,
        time_zone => 'local'
      ) :
    $self->{end} =~ /^(\d+):(\d+)$/ ?
      DateTime->new(
        year => $start->year, month => $start->month, day => $start->day,
        hour => $1, minute => $2,
        time_zone => 'local'
      ) :
    $self->{end} eq 'INPROGRESS' ?
      _now_dt() :
    die "unable to parse end time: $self->{end}";

  return ($start, $end);
}

1;
