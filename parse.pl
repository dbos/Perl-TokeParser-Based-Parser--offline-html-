#!/bin/perl -w
# Author: Danny O'Sullivan
# Dependencies: HTML::TokeParser, String:Strip (both on CPAN)
# Usage: parse.pl [filename]

# This parser works only on offline files, so no there is no LWP Dependency. 
# See example.html provided for template input file

use strict;
use warnings;
use HTML::TokeParser;
use String::Strip;
open(my $fh, "<:utf8",shift || 'example.html' ) || die "Cannot open file:$!";
my $p=HTML::TokeParser->new($fh);
my %myHash;
my $firstField;
my $hashKey;

# The idea is that I find much of the field data before I am ready to create my hash entry.
# Fortunately, the data is sequential, so lexical variables are used for storage until 
# everything is ready. 

while (my $token = $p->get_tag){
	if ($token->[0] eq "strong" ){
		$token=$p->get_token;
	#Returned Token is an array, first element defines type, second is the text or tag text
	#To clarify, I want the text that comes between the <strong> tags, so I find the strong
	#tag, and then move to the next token after that, which is the text block it encloses.
		my $textBlock=$token->[1];
		#The expected first field data is a number; strip, then do the regex.
		StripSpace($textBlock);
		do {$firstField= $textBlock; $token = $p->get_tag('p');} if $textBlock=~ /^[\s\d]*$/s;
		$token=$p->get_token;
		$textBlock=$token->[1];
		#Catches "Yada Yada text string (12345)" as a string and number.
		if ($textBlock=~ /^(.*)\((\d*)\)$/s){
			$textBlock=$1;
			$hashKey=$2;
			StripSpace($hashKey);
			$myHash{$hashKey}{firstField}=$firstField;
			# The following two lines just avoid initialization warnings.
			$myHash{$hashKey}{secondField}="";
			$myHash{$hashKey}{text}="";
		}
		#Catches "Yada Yada text string. Value Rating: DataHere" as two strings, split by "Value Rating: " 
		if ($textBlock=~ /^(.*)Value Rating:(.*)$/s){
			$textBlock=$1;
			my $secondField=$2;
			StripSpace($secondField);
			$myHash{$hashKey}{secondField}=$secondField;
			$myHash{$hashKey}{text}=$textBlock;
		}
		#This time no loop necessary to find strong, it's expected this time. Otherwise Same.
		$p->get_tag('strong');
		$token=$p->get_token;
		my $thirdField= $token->[1];
		StripSpace($thirdField);
		$myHash{$hashKey}{thirdField}=$thirdField;
	}
}
print "Hash Key:\t$_\nFirst Field:\t$myHash{$_}{firstField}\nSecond Field:\t$myHash{$_}{secondField}\nThird Field:\t$myHash{$_}{thirdField}\nRemaining Text:\t$myHash{$_}{text}\n" for keys(%myHash);
