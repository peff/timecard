package TimeSlot;
use strict;
use overload '""' => \&as_string;
use DateTime;

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
  push @{$self->{comment}}, @_;
}

sub _now() {
  my $now = DateTime->now(time_zone => 'local');
  return sprintf('%d-%02d-%02d %02d:%02d',
    $now->year, $now->month, $now->day, $now->hour, $now->minute
  );
}

1;
