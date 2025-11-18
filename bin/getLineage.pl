#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my ($inputFile, $outFile);

GetOptions(
    "inputFile=s" => \$inputFile,
    "outFile=s"   => \$outFile,
) or die "Usage: $0 --inputFile file --outFile file\n";

open(my $IN, "<", $inputFile) or die "Cannot open $inputFile: $!";

my @lines = <$IN>;
close $IN;

# If famdb did not return any lneage (input is blank), create an empty output file and exit.
if (!@lines) {
    open(my $OUT, ">", $outFile) or die "Cannot write $outFile: $!";
    close $OUT;
    exit 0;
}

my %level_to_entries;

foreach my $line (@lines) {
    chomp($line);
    next if $line =~ /^\s*$/;

    # Count indentation level via leading spaces
    my ($spaces) = ($line =~ /^(\s*)/);
    my $level = length($spaces);

    # Extract taxonID and number of repeat families
    # Plasmodium falciparum 3D7(16) [71]
    if ($line =~ /^\s*(\S+)\s+.+\(\d+\)\s+\[(\d+)\]/) {
        my ($taxid, $bracket_num) = ($1, $2);
        push @{ $level_to_entries{$level} }, {
            taxid       => $taxid,
            bracket_num => $bracket_num,
        };
    }
}

# No entries found → output empty file
if (!keys %level_to_entries) {
    open(my $OUT, ">", $outFile) or die "Cannot write $outFile: $!";
    close $OUT;
    exit 0;
}

# Deepest indentation = lowest taxon level
my $deepest = (sort { $b <=> $a } keys %level_to_entries)[0];

# Choose entry with largest [bracket_num]
my @deepest_entries = @{ $level_to_entries{$deepest} };
my $best = (sort { $b->{bracket_num} <=> $a->{bracket_num} } @deepest_entries)[0];

open(my $OUT, ">", $outFile) or die "Cannot write $outFile: $!";
my $lowestId = $best->{taxid};
$lowestId =~ s/^\D*//g;
print $OUT "$lowestId\n";
close $OUT;

exit 0;
