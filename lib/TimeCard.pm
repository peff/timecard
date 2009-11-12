package TimeCard;
use strict;
use TimeSlot; # DEPEND
use POSIX;
use File::Temp;

sub new {
  my $self = bless {}, shift;
  $self->{slots} = [];
  $self->_load_fn(shift);
  return $self;
}

sub _load_fn {
  my $self = shift;
  my $fn = shift;

  open(my $fh, '<', $fn) or do {
    return if $! == POSIX::ENOENT;
    die "unable to open $fn: $!";
  };

  $self->_load_fh($fh);
}

sub _load_fh {
  my $self = shift;
  my $fh = shift;

  while (my $slot = TimeSlot->new_from_fh($fh)) {
    push @{$self->{slots}}, $slot;
  }
}

sub save {
  my $self = shift;
  my $fn = shift;

  my $temp = File::Temp->new(TEMPLATE => "$fn.XXXXXX");
  $self->_save_fh($temp);
  close($temp)
    or die "unable to write to tempfile: $!";
  rename($temp->filename, $fn)
    or die "unable to rename to $fn: $!";
}

sub _save_fh {
  my $self = shift;
  my $fh = shift;

  my $first = 1;
  foreach my $slot (@{$self->{slots}}) {
    print $fh "\n" unless $first;
    $slot->print($fh);
    $first = 0;
  }
}

sub punch_in {
  my $self = shift;

  my $old = $self->recent;
  if ($old && $old->in_progress) {
    die "you are already punched in ($old)";
  }

  my $slot = TimeSlot->new_from_data(undef, undef, @_);
  push @{$self->{slots}}, $slot;
}

sub punch_out {
  my $self = shift;
  $self->current->finish(undef, @_);
}

sub comment {
  my $self = shift;
  $self->current->comment(@_);
}

sub recent {
  my $self = shift;
  return $self->{slots}->[-1];
}

sub current {
  my $self = shift;
  my $r = $self->recent;
  if (!$r || !$r->in_progress) {
    die "you are not punched in";
  }
  return $r;
}

sub slots {
  my $self = shift;
  return @{$self->{slots}};
}

1;
