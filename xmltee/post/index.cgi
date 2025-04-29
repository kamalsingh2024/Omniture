#!/usr/bin/perl -w

my $omnitureUrl = 'http://info.telstra.com/b/ss//6';
#my $omnitureUrl = 'http://stout.rumble.net/xmlposter/test.pl';

my $time = `date +-%F_%H-%M-%S-%N`;
chomp($time);

my $xmlstring;

for(<STDIN>) {
    $xmlstring = $xmlstring . $_;
}

($macaddress) = ($xmlstring =~ /\<visitorID\>(.*)\<\/visitorID\>/);

if (!$macaddress) {
    $macaddress = 'MAC-not-found';
}

my $outputfile = '/var/www/data/' . $macaddress . $time . '.xml';

print "Content-Type: text/xml\n\n";

print '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
print '<status>SUCCESS</status>' . "\n";

open(my $fh, '>>', $outputfile) || die "Can't open $outputfile\n";
print $fh $xmlstring;
close($fh);

my $curlCommand = 'curl ' . $omnitureUrl . ' --data-binary @' . $outputfile . ' -o /tmp/curloutput';
my $curlOutput = system($curlCommand);
#print STDERR $curlOutput;
