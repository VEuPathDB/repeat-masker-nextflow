#!/usr/bin/perl

use strict;
use FileHandle;
use Getopt::Long;

my($inFile,$outFile,$errFile,$trimDangling,$dangleMax,$paramFile);
&GetOptions('seqFile=s' => \$inFile,
            'errorFile=s' => \$errFile,
            'outFile=s' => \$outFile,
            'trimDangling!' => \$trimDangling,
            'dangleMax=i' => \$dangleMax);

my $errorFile = $errFile ? $errFile : ">blockLib_error.log";

open(ERR, ">$errorFile");
select ERR; $| = 1;
select STDOUT;
$| = 1;

my %fin;
if(-e "$outFile"){  #3restarting...
    open(R, "$outFile");
    while(<R>){
	if(/^\>(\S+)/){
	    $fin{$1} = 1;
	}
    }
    close R;
}
  
open(OUT, ">$outFile");

my $tmpSeq = "";
my $miniLib = "";
my $countNumSeqs = 0;
my $ctLength = 0;
my $countPart = 0;

##generate better sequence....
my @qmSeq = &readSeqFileToArray($inFile);
foreach my $seq (@qmSeq) {
    $seq->[1] =~ s/\s+//g;##gets rid of spaces and newlines
  
    my $sequence = $trimDangling ? &trimDanglingNNN($seq->[1]) : $seq->[1];
  
    my $tmpSeq = $sequence;
    $tmpSeq =~ s/N//g;
  
    if (length($tmpSeq) > 50) {
	print OUT "$seq->[0]", &breakSequence($sequence);
    } else {
	my $l = length($tmpSeq);
	my $def = $seq->[0];
	chomp $def;
	print ERR "$def [TOO SHORT: $l]\n";
    }
}

close ERR;
close OUT;

sub breakSequence {
    my($seq) = @_;
  ##just in case there are returns...
    $seq =~ s/\s//g;
    my $new = "";
    for (my $i = 0;$i<length($seq);$i+=80) {
	$new .= substr($seq,$i,80) . "\n";
    }
    return $new;
}

sub readSeqFileToArray{##read into array or arrays
    my($file) = @_;
    my @seq;
    my $c = 0-1;
    my $fh = FileHandle->new($file);
    open(TF, "$file");
    while (<TF>) {
	if (/^\>/) {
	    $c++;
	    $seq[$c]->[0] = $_;##makes key the entire defline...
	} else {
	    $seq[$c]->[1] .= $_; 
	}
    }
    close TF;
    return @seq;
}

sub trimDanglingNNN {
    my ($seq) = @_;


  # forward strand
    my $mightNeedTrimming = 1;
    while($mightNeedTrimming) {
	($seq, $mightNeedTrimming) = &trimDanglingNNN_sub($seq);
    }

  # reverse strand (only bother if there are and NNNs left)
    if ($seq =~ /N/) {
	my $rev = &reverseComplementSequence($seq);
	$mightNeedTrimming = 1;
	while($mightNeedTrimming) {
	    ($rev, $mightNeedTrimming) = &trimDanglingNNN_sub($rev);
	}
    # don't bother unreversing if not changed
	if (length($rev) != length($seq)) {
	    $seq = &reverseComplementSequence($rev);
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

sub reverseComplementSequence{ ##for reverseComplementing sequences
    my($seq) = @_;
    $seq =~ s/\s//g;
    my $revcompseq = "";
    my $revseq = reverse $seq;
    my @revseq = split('', $revseq);
    foreach my $nuc (@revseq) {
	$revcompseq .= &compNuc($nuc);
    }
    return $revcompseq;
}

sub compNuc{
    my($nuc) = @_;
    if ($nuc =~ /A/i) {
	return "T";
    } elsif ($nuc =~ /T/i) {
	return "A";
    } elsif ($nuc =~ /C/i) {
	return "G";
    } elsif ($nuc =~ /G/i) {
	return "C";
    }
    return $nuc;
}
