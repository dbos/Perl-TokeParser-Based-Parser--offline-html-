#!/bin/perl 
use strict;
use warnings;
use HTML::TokeParser;
use String::Strip;
open(my $fh, "<:utf8","print.html") || die "Cannot open file:$!";
my $p=HTML::TokeParser->new($fh);
my $activecspc;
my %wines;
my $score;
my $cspc;
while (my $token = $p->get_tag){
	if ($token->[0] eq "strong" ){
		$token=$p->get_token;
		my $text=$token->[1];
		StripSpace($text);
		do {$score= $text; $token = $p->get_tag('p');} if $text=~ /^[\s\d]*$/s;
		$token=$p->get_token;
		$text=$token->[1];
		if ($text=~ /^(.*)\((\d*)\)$/s){
			$text=$1;
			$cspc=$2;
			StripSpace($cspc);
			$wines{$cspc}{score}=$score;
			$wines{$cspc}{vr}="";
			$wines{$cspc}{text}="";
		}
		if ($text=~ /^(.*)Value Rating:(.*)$/s){
			my $text=$1;
			my $vr=$2;
			StripSpace($vr);
			$wines{$cspc}{vr}=$vr;
			$wines{$cspc}{text}=$text;
		}
		$p->get_tag('strong');
		$token=$p->get_token;
		my $price = $token->[1];
	}
}
print "CSPC:$_\nScore:$wines{$_}{score}\nText:$wines{$_}{text}\nVR:$wines{$_}{vr} \n" for keys(%wines);
