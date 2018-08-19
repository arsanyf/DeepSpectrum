#!/usr/bin/perl

use strict;

# please set
my $site_name = "UAU_baseline";

my $lab_index = pop(@ARGV);
my $out = pop(@ARGV);
my @arffs = grep { /\.arff$/ } @ARGV;
my @preds = grep { /\.pred$/ } @ARGV;
#my ($arff, $pred, $out, $lab_index) = @ARGV;

if ($#arffs < 0 || $#preds < 0 || $#arffs != $#preds || !$out || !$lab_index) {
    print "Take instance names from arff files and predictions from Weka output, \n";
    print "and create prediction ARFF\n\n";
    print "Usage: $0 <arff1> <pred1> [ <arff2> <pred2> ... ] <pred_arff> <lab-index>\n";
    exit 1;
}

my $include_frame_index = 0;

my $ai = 0;
my $class_list = "";
open(ARFF, $arffs[0]) or die "$arffs[0]: $!";
while (<ARFF>) {
    if (/\@attribute\s+(\S+)\s+([\S\s]+)/) {
        ++$ai;
        if ($ai == $lab_index) {
            $class_list = $2;
        }
    }
    if (/\@data/) { last; }
}
close(ARFF);
if (!$class_list) {
    die "Class attribute #$lab_index not found in $arffs[0]!";
}
$class_list =~ s/^\s*\{\s*//;
$class_list =~ s/\s*\}\s*$//;
my @classes = split(",", $class_list);
map { s/^\s+//; s/\s+$//; } @classes;

open(OUT, '>', $out) or die "$out: $!";
print OUT "\@relation mani_Predictions_$site_name\n";
print OUT "\@attribute instance_name string\n";
print OUT "\@attribute prediction { ", join(", ", @classes), " }\n";

# Create a hash that maps Weka's class name abbreviations in the pred. file
# to the nominal values in the class list
my %pred2class;
my $ci = 1;
for my $class (@classes) {
    print OUT "\@attribute score_$class numeric\n";
    $pred2class{substr($class, 0, 8 - int($ci / 10))} = $class;
    ++$ci;
}
print OUT "\@data\n";

for (my $i = 0; $i <= $#arffs; ++$i) {

    my $arff = $arffs[$i];
    my $pred = $preds[$i];

open(ARFF, $arff) or die "$arff: $!";
open(PRED, $pred) or die "$pred: $!";

my $data = 0;
my $npred = 0;
while (<ARFF>) {
    if (/\@data/) {
        $data = 1;
    }
    elsif ($data && !/^\s*$/ && !/^%\s*$/) {
        my @els = split(/,/);
        my $inst = $els[0];
        if (eof(PRED)) {
            print "ERROR: Wrong number of lines in $pred!\n";
            exit -1;
        }
        my $ok = 0;
        while (!eof(PRED)) {
            my $line = <PRED>;
            chomp($line);
            $line =~ s/^\s+//;
            my @els = split(/\s+/, $line);
            if ($els[0] =~ /^\d+/) {
                my @scores = split(/,/, $els[$#els]);
                map { s/\*// } @scores;
                my (undef, $pred) = split(':', $els[2]);
                if (defined $pred2class{$pred}) {
                    $pred = $pred2class{$pred};
                }
                else {
                    die "Cannot map $pred to class!\n";
                }
                print OUT $inst;
                print OUT ",$pred,", join(",", @scores), "\n";
                $ok = 1;
                ++$npred;
                last;
            }
        }
        #last if ($npred == 100);
        if (!$ok) {
            print "ERROR: No prediction found for $inst in $pred!\n";
            exit -1;
        }
    }
}

}
#print "npred = $npred\n";

close(ARFF);
close(PRED);
close(OUT);

