#! /usr/bin/perl -w

use MIME::Lite;
use strict;
use lib '/srv/konica/scripts';  # Emplacement absolu des scripts
use Ldaptest;
use DateTime;
use DBtest;
use DateTime::Format::MySQL;


my $dtnow = DateTime->now;
my $dtavant = $dtnow->clone();
$dtavant->subtract( weeks => 1);
my $hash_ref = DBtest::QueryCompteurs(undef, "$dtavant->epoch()", "$dtnow->epoch()", "tous", undef);
my $dbid;
my $uid;
my $tableau;
my @details_ldap = undef;
my %user_hash;
my $css_tableau = q$
	<html>
	<style type="text/css">
	table.gridtable {
		font-family: verdana,arial,sans-serif;
		font-size:16px;
		background: #e1e1e1;
		border-width: 1px;
		border-color: #666666;
		border-collapse: collapse;
		width:100%;
	}
	table.gridtable th {
		border-width: 1px;
		padding: 8px;
		border-style: solid;
		border-color: #666666;
		background-color: #57bbd0;
	}
	table.gridtable td {
		text-align: center; 
		border-width: 1px;
		padding: 8px;
		border-style: solid;
		border-color: #666666;
		background-color: #ffffff;
	}
	</style>
	<body>
$;

# Partie globale pour les gestionnaires
my $uid_gestionnaires = DBtest::QueryNotifCompteurs;
local our @adresses_mail_gestionnaires;
foreach (@$uid_gestionnaires) {
	my @temp = Ldaptest::Details("$_");
	push (@adresses_mail_gestionnaires, $temp[1]);
}


if (keys $hash_ref) {
	$tableau = qq[$css_tableau <table class="gridtable"><tr><th>Date</th><th>Nom</th><th>Type</th><th>Media</th><th>Nombre</th><th>Recto/Verso</th><th>N & B</th><th>prix</th></tr>];
	foreach (sort (keys $hash_ref)) {
		my $datetime = DateTime::Format::MySQL->parse_timestamp( $hash_ref->{"$_"}->{'Date'} );
		$dbid = $hash_ref->{"$_"}->{'ID'};
		if ( !exists ($user_hash{"$dbid"}{'uid'}) ) {
			my @resultats = DBtest::QueryUID("$dbid");
			$uid = $resultats[0];
			@details_ldap = Ldaptest::Details("$uid");
			$user_hash{"$dbid"} = {'uid' => "$uid", 'cn' => "$details_ldap[2]", 'mail' => "$details_ldap[1]" };
		}
		push @{$user_hash{"$dbid"}{'jobs'}}, "$_";
		$tableau .= "<tr>";
		$tableau .= "<td>" . $datetime->dmy('/') . " - " .  $datetime->hms."</td>";
		$tableau .= "<td>" . $user_hash{"$dbid"}{'cn'} . "</td>";
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'Type'} . "</td>";
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'Media'} . "</td>";
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'nombre'} . "</td>";
		if ( $hash_ref->{"$_"}->{'recto'} ) { $tableau .= "<td>Recto</td>"; }
		else {$tableau .= "<td>Recto/Verso</td>"; }
		if ( $hash_ref->{"$_"}->{'NB'} ) { $tableau .= "<td>N & B</td>"; }
		else {$tableau .= "<td>Couleur</td>";}
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'prix'} . "</td>";
		$tableau .= "</tr>";
	}
	$tableau .= "</table></body></html>";
}
else {$tableau = "<h3>Il n'y a pas d'information d'utilisation du copieur sur la période.</h3>"}
if ( @adresses_mail_gestionnaires ){
	my $msg = MIME::Lite->new(
		From    => 'gestion-copieur@univ-orleans.fr',
		To      => @adresses_mail_gestionnaires ,
		Subject => "Compteurs hebdomadaire de Bourges - ".$dtavant->dmy('/')." à ".$dtnow->dmy('/'),
		Subject => "Compteurs hebdomadaire de Bourges - ".$dtavant->dmy('/')." à ".$dtnow->dmy('/'),
		Data    => "Ceci est le relevé automatique des compteurs du copieur de Bourges, depuis le ".$dtavant->dmy('/')." jusqu'au ".$dtnow->dmy('/').".\nSi vous ne souhaitez plus les recevoir, rendez-vous sur la page Administration de l'application Web de gestion du copieur."
	);
	my $part = MIME::Lite->new(
		Type     =>'text/html',
		Data     => $tableau,
		Encoding => 'quoted-printable',
	);
	$msg->attach($part);
	$msg->send;
}
else { warn "[konica-app][cronjob] No managers mail address found" }


# Partie personnelle pour chaque utilisateur

foreach $dbid ( keys %user_hash) {
	$tableau = qq[$css_tableau <table class="gridtable"><tr><th>Date</th><th>Type</th><th>Media</th><th>Nombre</th><th>Recto/Verso</th><th>N & B</th><th>prix</th></tr>];
	
	foreach (@{$user_hash{"$dbid"}{'jobs'}}){
		my $datetime = DateTime::Format::MySQL->parse_timestamp( $hash_ref->{"$_"}->{'Date'} );
		$tableau .= "<tr>";
		$tableau .= "<td>" . $datetime->dmy('/') . " - " .  $datetime->hms."</td>";
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'Type'} . "</td>";
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'Media'} . "</td>";
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'nombre'} . "</td>";
		if ( $hash_ref->{"$_"}->{'recto'} ) { $tableau .= "<td>Recto</td>"; }
		else {$tableau .= "<td>Recto/Verso</td>"; }
		if ( $hash_ref->{"$_"}->{'NB'} ) { $tableau .= "<td>N & B</td>"; }
		else {$tableau .= "<td>Couleur</td>";}
		$tableau .= "<td>" . $hash_ref->{"$_"}->{'prix'} . "</td>";
		$tableau .= "</tr>";
	}
	my $msg = MIME::Lite->new(
	From    => 'gestion-copieur-bourges@univ-orleans.fr',
	To      =>  $user_hash{"$dbid"}{'mail'},
	Subject => "Compteurs hebdomadaire de Bourges - ".$dtavant->dmy('/')." à ".$dtnow->dmy('/'),
	Data    => "Ceci est le relevé automatique des compteurs du copieur de l'ESPE de Bourges, depuis le ".$dtavant->dmy('/')." jusqu'au ".$dtnow->dmy('/')
	);
	my $part = MIME::Lite->new(
		Type     =>'text/html',
		Data     => $tableau,
		Enconding => 'quoted-printable'
	);
	$msg->attach($part);
	$msg->send;
}
