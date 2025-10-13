#!/usr/bin/perl

use strict;
use Getopt::Long;

my($outFile,$taxonId);
&GetOptions('outFile=s' => \$outFile,
            'taxonId=s' => \$taxonId);

system("famdb.py lineage -ad ${taxonId} | awk '{ if (match(\$0, /\\[([0-9]+)\\]/, a)) { if (a[1] > max) { max = a[1]; line = \$0 } } } END { if (match(line, /([0-9]+)/, b)) { print b[1] } }' > $outFile");
