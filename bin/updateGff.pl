#!/usr/bin/perl

use strict;
use Getopt::Long;
use Bio::SeqIO;
use IO::String;
use Data::Dumper;

my($inGff,$mappingFile,$newGff);
&GetOptions('inGff=s' => \$inGff,
            'mappingFile=s' => \$mappingFile,
            'newGff=s' => \$newGff);

open(MAP, "<$mappingFile") || die "Could not open error file $mappingFile";
open(OUT, ">$newGff") || die "Could not open outFile $newGff";
open(my $data, "<$inGff") || die "Could not open outFile $inGff";

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

while (my $line = <$data>) {
    chomp $line;
    if ($line =~ /^(fakeId_\d+)(\tRepeatMasker.*)/) {	
        print OUT "$deflineMap{$1}" . $2 . "\n";
    }
    else {
        print OUT $line . "\n";
    }
}
