#!/usr/bin/perl

use strict;
use FileHandle;
use Getopt::Long;
use Bio::SeqIO;
use IO::String;

my($inFile,$outFile,$errFile,$trimDangling,$dangleMax,$paramFile);
&GetOptions('seqFile=s' => \$inFile,
            'errorFile=s' => \$errFile,
            'outFile=s' => \$outFile,
            'trimDangling!' => \$trimDangling,
            'dangleMax=i' => \$dangleMax);

my $errorFile = $errFile ? $errFile : "error.log";

open(ERR, ">$errorFile") || die "Could not open error file $errorFile";
  
open(OUT, ">$outFile") || die "Could not open outFile $outFile";

my $in  = Bio::SeqIO->new(-file => $inFile, -format => 'Fasta');
my $out = Bio::SeqIO->new(-file => ">$outFile", -format => 'Fasta');

while ( my $seq = $in->next_seq() ) {
    my $sequenceTrimmed = $trimDangling ? &trimDanglingNNN($seq->seq) : $seq->seq;
    my $tmpSeq = $sequenceTrimmed;
    $tmpSeq =~ s/N//g;  
    if (length($tmpSeq) > 50) {
        my $new = "";
        print OUT "\>" . $seq->id . "\n";
        for (my $i = 0;$i<length($sequenceTrimmed);$i+=80) {
            $new = substr($sequenceTrimmed,$i,80) . "\n";
            print OUT $new;
        }
    } else {
	print ERR $seq->id . "[TOO SHORT: length($tmpSeq)]\n";
    }
}

sub trimDanglingNNN {
    my ($seq) = @_;
    my $mightNeedTrimming = 1;
    while($mightNeedTrimming) {
	($seq, $mightNeedTrimming) = &trimDanglingNNN_sub($seq);
    }
    if ($seq =~ /N/) {
	my $rev = &reverseSequence($seq);
	$mightNeedTrimming = 1;
	while($mightNeedTrimming) {
	    ($rev, $mightNeedTrimming) = &trimDanglingNNN_sub($rev);
	}
	if (length($rev) != length($seq)) {
	    $seq = &reverseSequence($rev);
	}
    }
    return $seq;
}

sub trimDanglingNNN_sub {
    my($seq) = @_;
    my $trimmed; 
    if ($seq =~ /^(.*?)NNNNNNNNNN+(.*?)$/) {
	if (length($1) <= $dangleMax) {
	    $seq = $2;
	    $trimmed = 1;
	}
    }
    return ($seq, $trimmed);
}

sub reverseSequence{
    my($seq) = @_;
    $seq =~ s/\s//g;
    my $revseq = reverse $seq;
    my @revseq = split('', $revseq);
    return $revseq;
}
