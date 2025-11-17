#!/usr/bin/perl

use strict;
use Getopt::Long;
use Bio::SeqIO;
use IO::String;
use Data::Dumper;

my($inFasta,$mappingFile,$restoredFasta);
&GetOptions('inFasta=s' => \$inFasta,
            'mappingFile=s' => \$mappingFile,
            'restoredFasta=s' => \$restoredFasta);

open(MAP, "<$mappingFile") || die "Could not open error file $mappingFile";
my %deflineMap;
while (my $line = <MAP>) {
    chomp $line;
    if ($line =~ /(\S+)\t(\S+)/) {
	my $internal = $1;
	my $actual = $2;
        $deflineMap{$internal} = $actual;
    }
    else {
        die "Improper mapping file format: $!";
    }
}
close MAP;

open(SEQ, '<', $inFasta) || die "Could not open file $inFasta: $!";
open(OUT, ">$restoredFasta") || die "Could not open outFile $restoredFasta";

while (my $line = <SEQ>) {
    chomp $line;
    if ($line =~ /^>(\S+)/) {
        print OUT ">$deflineMap{$1}\n";
    }
    else {
        print OUT "$line\n";
    }
}

close SEQ;
close OUT;
