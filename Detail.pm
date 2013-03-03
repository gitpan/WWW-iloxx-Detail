package WWW::iloxx::Detail;
use strict;
#use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/iloxxcheck/;
our $VERSION = '0.2';
use LWP::Simple;
use LWP::UserAgent;

sub iloxxcheck {
	my $paketnummer = shift;
	my $language = shift || 'de';

	my @newdata;
	my $firstdata1 = get("http://www.iloxx.de/net/einzelversand/tracking.aspx?ix=$paketnummer");
	my($detail) = ($firstdata1 =~ /<td><\/td><td class="contentheadline">Sendungsdetails<\/td><td><\/td>(.*)<table id="ctl00_cphM_Tracking_Table5" cellspacing="0" cellpadding="0"/s);
	my($paketnumber) = ($detail =~ /<span id="ctl00_cphM_Tracking_labPaketnummer">([^<]*)<\/span>/);
	my($product) = ($detail =~ /<span id="ctl00_cphM_Tracking_labProdukt">([^<]*)<\/span>/);
	my($weight) = ($detail =~ /<span id="ctl00_cphM_Tracking_labGewicht">([^<]*)<\/span>/);
	my($reference) = ($detail =~ /<span id="ctl00_cphM_Tracking_labReferenz">([^<]*)<\/span>/);
	my($content) = ($detail =~ /<span id="ctl00_cphM_Tracking_labInhalt">([^<]*)<\/span>/);
	my($signature) = ($detail =~ /<span id="ctl00_cphM_Tracking_labSignatur">([^<]*)<\/span>/);
	my($to) = ($detail =~ /<span id="ctl00_cphM_Tracking_labEmpfaenger">(.*?)<\/span>/);
	$to =~ s/<br>//g;
	my($data) = ($detail =~ /<table cellspacing="0" border="0" width="558" id="tableRepeater"(.*?)<\/table>/s);
	$data =~ s/[\n\r]//g;

	while($data =~ /<tr(.*?)<\/tr>/ig){
		my $detailone = $1;
		my($datum,$ort,$daten) = ($detailone =~ /<td style="[^"]*" class="repaddresslistcontent">\s*([^<]*)\s*<\/td>\s*<td style="[^"]*" class="repaddresslistcontent">\s*([^<]*)\s*<\/td>\s*<td style="[^"]*" class="repaddresslistcontent">\s*([^<]*)\s*<\/td>/);
		next unless($daten);
		$datum =~ s/\s\s*/ /g;
		$datum =~ s/^\s*|\s*$//g;
		$ort =~ s/\s\s*/ /g;
		$ort =~ s/^\s*|\s*$//g;
		$daten =~ s/\s\s*/ /g;
		$daten =~ s/^\s*|\s*$//g;
		my %details;
		$details{'datum'} = $datum;
		$details{'ort'} = $ort;
		$details{'daten'} = $daten;
		push(@newdata,\%details)
	}

	return(\@newdata,({
		'shipnumber' => $paketnumber,
		'product' => $product,
		'weight' => $weight,
		'reference' => $reference,
		'content' => $content,
		'signature' => $signature,
		'to' => $to
		})
	);
}


=pod

=head1 NAME

WWW::iloxx::Detail - Perl module for the iloxx online tracking service with details.

=head1 SYNOPSIS

	use WWW::iloxx::Detail;
	my($newdata,$other) = iloxxcheck('paketnumber','de');#de for text in german

	foreach my $key (keys %$other){# shipnumber, product, weight, reference, content, signature, to
		print $key . ": " . ${$other}{$key} . "\n";
	}
	print "\nDetails:\n";

	foreach my $key (@{$newdata}){
		#foreach my $key2 (keys %{$key}){#datum, ort, daten
		#	print ${$key}{$key2};
		#	print "\t";
		#}

		print ${$key}{ort};
		print "\t";
		print ${$key}{datum};
		print "\t";
		print ${$key}{daten};
		print "\n";
	}

=head1 DESCRIPTION

WWW::iloxx::Detail - Perl module for the iloxx online tracking service with details.

=head1 AUTHOR

    -

=head1 COPYRIGHT

	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
