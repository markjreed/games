#!/usr/bin/env perl
use v5.34;
use experimental qw(signatures);

my @so_far; 

while (my $arg = shift @ARGV) {
  last if $arg eq '-';
  push @so_far, $arg;
}
if (!@ARGV) {
  @ARGV = qw(answers.txt guessable.txt);
}
chomp(my @words = <>);
my $size = length($words[0]);

my @left = @words;
my $count = @left;
while (@so_far) {
  my $guess = shift @so_far;
  my $result= shift @so_far or die "Odd number of arguments\n";
  for (my $i=0; $i<$size; ++$i) {
    my $g = substr($guess,$i,1);
    my $r = substr($result,$i,1);
    die "Unrecognized result $r" unless $r =~ /[byg]/;
    if ($r eq 'b') {
      my @indices = grep { substr($guess, $_, 1) eq $g } 0..length($guess)-1;
      if (@indices == 1 || !grep { substr($result, $_, 1) ne 'b' } @indices) {
        @left = grep { !/$g/ } @left;
      } else {
        @left = grep { !/$g.*$g/ } @left;
      }
    } elsif ($r eq 'y') {
      @left = grep { /$g/ && substr($_,$i,1) ne $g } @left;
    } elsif ($r eq 'g') {
      @left = grep { substr($_,$i,1) eq $g } @left;
    }
  }
  $count = @left;
}
print "Initial reduction to $count words";
if ($count <= 100) {
  print ":"; say join ", ", @left;
} else {
  say ".";
}


my $min = +@words * @left;
my @best;
$|=1;
foreach my $try (@words) {
  #print "min=$min, trying $try:";
  my $count = 0;
  foreach my $answer (@left) {
    #print "$answer\e[${size}D";
    $count += remaining($try, $answer);
  }
  #say "\e[K$count";
  next if $count > $min;
  if ($count == $min) {
    push @best, $try;
    if (@best >= @left) {
      if (my @try = grep { my $b=$_; grep { $b eq $_ } @left } @best) {
        @best = @try;
      }
    }
  } else {
    $min = $count;
    @best = $try;
  }
}

say "Best guesses, averaging ${\($min/@left)} remaining words: @best";
exit 0;

# given a guess and the actual answer, return the number of possible words
# remaining after the guess
sub remaining($guess, $answer) {
  my @this = @left;
  for (my $i=0; $i<$size; ++$i) {
    my $g = substr($guess,$i,1);
    if (substr($answer,$i,1) eq $g) {
      @this = grep { substr($_,$i,1) eq $g } @this;
    } elsif ($answer =~ /$g/) {
      @this = grep { /$g/ && substr($_,$i,1) ne $g } @this;
    } else {
      @this = grep { !/$g/ } @this unless $guess =~ /$g.*$g/;
    }
  }
  return my $count = @this;
}
