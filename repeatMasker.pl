#!/usr/bin/perl

## takes in a library file, runs cross_match to block repeated sequences (Human)
## and writes back out a blocked library to STDOUT

## modified to also trim the ends that end in NNNN so will not dangle...

## Brian Brunk 8/12/98

use strict;
use FileHandle;
use Getopt::Long;

# print STDERR "Incoming cmdline: repeatMasker @ARGV\n";

my($inFile,$outFile,$errFile,$rmPath,$trimDangling,
  $dangleLength,$dangleMax,$paramFile);
&GetOptions('rmPath=s' => \$rmPath,
            'seqFile=s' => \$inFile,
            'errorFile=s' => \$errFile,
            'outFile=s' => \$outFile,
            'trimDangling!' => \$trimDangling,
            'rmParamsFile=s' => \$paramFile,
	    'dangleMax=i' => \$dangleMax);


##usage etc
if (!-e $inFile || !$outFile || !-e $paramFile ) {
	print STDERR "Usage: blockLibraryWithRM --inFile <inputSequenceFile> --outFile <outputSequenceFile> --errorFile <errorFilename> --mod <number of logical parts to split file into> --modValue <mod value for this run>  --trimDangling <boolean: trim bases from end if dangling off of masked seq> --dangleMax <this number or less of bases will be trimmed> --rmParamsFile <file with repeatmasker parameters>\n\n";
	system("$rmPath/RepeatMasker");
	exit 1;
}

if(!-e $paramFile){
  die "Note: repeatMasker requires a file containing the RepeatMasker commandline parameters\n";
}

my $rmOptions = &parseParams($paramFile);

#print STDERR "RMOptions: $rmOptions\n";

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

##command for RepeatMasker

my $RepMaskCmd = "RepeatMasker $rmOptions $inFile";
print STDERR "RepeatMasker command:\n  $RepMaskCmd\n";


my $tmpSeq = "";
my $miniLib = "";
my $countNumSeqs = 0;
my $ctLength = 0;
my $countPart = 0;



##subroutine that does the processing

#	print STDERR "Processing miniLib: length = $ctLength\n";

##run RepeatMasker##
my $cmd = "$rmPath/$RepMaskCmd >& rm.stdout";
print STDERR "Command:  $cmd\n";
my $status = system($cmd) >> 8;
die "repeatmasker returned status $status running $cmd" if $status;
#die "repeatmasker ($cmd) did not create $inFile.masked" unless -e "$inFile.masked";

##generate better sequence....
my @qmSeq = &readSeqFileToArray(-e "$inFile.masked" ? "$inFile.masked" : "$inFile");
foreach my $seq (@qmSeq) {
  $seq->[1] =~ s/\s+//g;			##gets rid of spaces and newlines
  
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

system ("rm $inFile.*");
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

sub readSeqFileToArray{					##read into array or arrays
  my($file) = @_;
  my @seq;
  my $c = 0-1;
	my $fh = FileHandle->new($file);
  open(TF, "$file");
  while (<TF>) {
    if (/^\>/) {
      $c++;
      $seq[$c]->[0] = $_;				##makes key the entire defline...
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

sub parseParams {
  my ($file) = @_;
  
  my @params;
  open(C, "$file") or &error("cannot open rmParams file $file");
  while(<C>){
    next if /^\s*#/;
    next if /^\s*$/;
    chomp;
    push(@params,$_);
  }
  close(C);
  return join(" ",@params);
}
