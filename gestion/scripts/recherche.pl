#! /usr/bin/perl

use strict;
use CGI;
use warnings;
use lib '/srv/konica/scripts';
use Ldaptest;
use JSON;

my $cgi = CGI->new();
my $recherche = $cgi->param('term');


print "Content-type: application/json\n\n";

my $resultats = Ldaptest::Recherche("$recherche");
my @list_resultat;
foreach (keys %$resultats) {
	my $temp = "$_";
	my $eduprim = $$resultats{$temp}[1] ;
	if ( "$eduprim" ne 'student' ) {
		push (@list_resultat, {'uid' => "$temp",'value' => $$resultats{"$temp"}[0] });
	}
}

print JSON::to_json(\@list_resultat);