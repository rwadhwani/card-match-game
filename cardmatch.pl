#!/usr/bin/perl

#use warnings;
use POSIX;
use List::Util qw(shuffle max);

# define variables, constants and arrays
$DEBUG = 0;												# turn on (1) to print along on the screen
$packs_of_cards = 1;									# default packs of cards to use
$TOTAL_CARDS = 52;										# number of cards in one pack
$TOTAL_PLAYERS = 2;										# total number of players
$ALLOWED_MATCHING_CONDITIONS = "face|suit|both";
@SUITES = ("clubs", "spades", "hearts", "diamonds");
@CARD_VALUE = ("2", "3", "4", "5", "6", "7", "8", "9", "10", "king", "queen", "jack", "ace");

# get user input to initiate the Match! game
{
	print "\nCARDS MATCH GAME ($TOTAL_PLAYERS players)\n\n";
	print "How many pack of cards to use? [press enter for $packs_of_cards pack]: ";
	my $packs = <STDIN>;
	$packs_of_cards = ($packs !~ /^\d$/ || $packs < 1)?$packs_of_cards:$packs;
	
	print "Which of the three matching conditions to use? [face, suit, both]: ";
	$matching_condition = lc(<STDIN>);
	chomp($matching_condition);
	chomp($packs_of_cards);
		
	exit if ($matching_condition !~ /^($ALLOWED_MATCHING_CONDITIONS)$/);		# exit the game if matching condition input by the user is invalid
	if ($DEBUG) { print "You've chosen $packs_of_cards pack of cards and matching condition as $matching_condition\n"; }
}

foreach my $poc (0..$packs_of_cards - 1) {
	my @pack;
	if ($DEBUG) { print "\nPACK #" . ($poc + 1); }
	foreach $suit (0..$#SUITES) {
		if ($DEBUG) { print "\n$SUITES[$suit] -> { "; }
		foreach (0..$#CARD_VALUE) {
			my %cards;
			$cards{'suit'} = $SUITES[$suit];
			$cards{'value'} = $CARD_VALUE[$_];
			if ($DEBUG) { print "$cards{'value'} "; }
			push (@pack, \%cards);
		}
		if ($DEBUG) { print " }"; }
	}
	if ($DEBUG) { print "\n"; }
	
	shuffle (keys %pack);
	$packs{$poc} = \@pack;
}

foreach my $card (0..$TOTAL_CARDS - 1) {
	foreach my $pack (keys %packs) {
		if ($matching_condition eq "face") { $match = $packs{$pack}[$card]{'value'}; }
		elsif ($matching_condition eq "suit") { $match = $packs{$pack}[$card]{'suit'}; }
		else { $match = $packs{$pack}[$card]{'value'} . " " . $packs{$pack}[$card]{'suit'}; }
		
		if (defined($check{$match})) {
			my $winner = ceil(rand($TOTAL_PLAYERS));
			$matches{$winner} += $packs_of_cards;
		}
		$check{$match}{$pack}++;
	}
}

print "\n\nRESULT\n==========";

if (!%matches) {
	$match_result = "No winner!";
} else {
	my $max_count = max values %matches;
	my $winner_count = 0;
	foreach my $player ( sort keys %matches) {
		print "\n$player -> $matches{$player}";
		if ( $matches{$player} == $max_count) {
			push @result, $player;
		}
	}
	$match_result = ( $#result > 0 )?"Draw between players ".join(' and ',@result)."!":"$result[0] is the winner!";
}

print "\n$match_result\n";
