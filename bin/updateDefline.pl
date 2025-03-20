#!/usr/bin/perl

use strict;
use Getopt::Long;
use Bio::SeqIO;
use IO::String;
use Data::Dumper;

my($inFasta,$mappingFile,$newFasta);
&GetOptions('inFasta=s' => \$inFasta,
            'mappingFile=s' => \$mappingFile,
            'newFasta=s' => \$newFasta);

open(MAP, ">$mappingFile") || die "Could not open error file $mappingFile";
open(OUT, ">$newFasta") || die "Could not open outFile $newFasta";

my $in  = Bio::SeqIO->new(-file => $inFasta, -format => 'Fasta');

my $counter = 0;
while ( my $seq = $in->next_seq() ) {
    print MAP "$counter\t" . $seq->primary_id . "\n";
    print OUT ">$counter\n" . $seq->seq . "\n";
    $counter += 1;
}
