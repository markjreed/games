#!/usr/bin/env raku
unit sub MAIN($chars, $pattern is copy);
my @c = $chars.comb.Array;
my @sets;
my $slots = +$pattern.comb.grep('x');
$pattern .= &{ .subst('x','%s',:g).subst('=','==',:g) };
if @c == $slots {
  @sets = [@c,];
} else {
  @sets = gather for @c.combinations($slots - @c) {
    take [|@c,|$_]
  }
}
my @strings = gather for @sets».permutations {
   for @$_ {
     take sprintf $pattern, |$_;
   }
}.unique;
.subst('==','=').say for @strings.grep: {
  # filter out some invalid expressions 
  /^\d .* \d '==' \d+ $/  &&
  # and some that Raku likes but Nerdle doesn't
  !/ '//' / &&
  try { use MONKEY-SEE-NO-EVAL; EVAL "no worries; $_"; };
};
