#!/usr/bin/perl -w

##
# args.pl
#
# Basic tests to ensure that bad combinations of arguments are rejected
# and good ones are accepted.
#

my $bowtie = "./bowtie";
my $bowtie_d = "./bowtie-debug";
if(system("$bowtie --version") != 0) {
	$bowtie = `which bowtie`;
	chomp($bowtie);
	if(system("$bowtie --version") != 0) {
		die "Could not find bowtie in current directory or in PATH\n";
	}
}
if(system("$bowtie_d --version") != 0) {
	$bowtie_d = `which bowtie-debug`;
	chomp($bowtie_d);
	if(system("$bowtie_d --version") != 0) {
		die "Could not find bowtie-debug in current directory or in PATH\n";
	}
}

if(! -f "e_coli_c.1.ebwt") {
	print STDERR "Making colorspace e_coli index\n";
	system("make bowtie-build") && die;
	system("bowtie-build -C genomes/NC_008253.fna e_coli_c") && die;
} else {
	print STDERR "Colorspace e_coli index already present...\n";
}

open TMP, ">.args.pl.1.fa" || die;
print TMP ">\nT0120012002012030303023\n";
close(TMP);
open TMP, ">.args.pl.1.qv" || die;
print TMP ">\n10 11 12 10 10 11 12 10 10 12 10 22 33 23 13 10 12 23 24 25 26 27\n";
close(TMP);
open TMP, ">.args.pl.2.qv" || die;
print TMP ">\n9 10 11 12 10 10 11 12 10 10 12 10 22 33 23 13 10 12 23 24 25 26 27\n";
close(TMP);

my @bad = (
	"-n 6".
	"-v 6",
	"-n 4",
	"-v 4",
	"-v 2 -n 4",
	"-v -1",
	"-n -10",
	"-3 -3",
	"-5 -1",
	"-e -1",
	"-l 4",
	"-l 0"
);

my @badEx = (
	"e_coli -f .args.pl.1.fa -Q .args.pl.1.qv",
	"e_coli_c -f .args.pl.1.fa -Q .args.pl.1.qv"
);

my @good = (
	"-n 0",
	"-n 1",
	"-n 2",
	"-n 3",
	"-v 0",
	"-v 1",
	"-v 2",
	"-v 3",
	"-v 3 -n 3"
);

my @goodEx = (
	"-C e_coli_c -f .args.pl.1.fa -Q .args.pl.1.qv",
	"-C e_coli_c -f .args.pl.1.fa -Q .args.pl.2.qv"
);

sub run($) {
	my $cmd = shift;
	print "$cmd\n";
	return system($cmd);
}

print "Bad:\n";
for my $a (@bad) {
	run("$bowtie $a e_coli reads/e_coli_1000.fq /dev/null") != 0 || die "bowtie should have rejected: \"$a\"\n";
	run("$bowtie_d $a e_coli reads/e_coli_1000.fq /dev/null") != 0 || die "bowtie-debug should have rejected: \"$a\"\n";
	print "PASSED: bad args \"$a\"\n";
}
print "\nBadEx:\n";
for my $a (@badEx) {
	run("$bowtie $a  /dev/null") != 0 || die "bowtie should have rejected: \"$a\"\n";
	run("$bowtie_d $a  /dev/null") != 0 || die "bowtie-debug should have rejected: \"$a\"\n";
	print "PASSED: bad args \"$a\"\n";
}
print "\nGood:\n";
for my $a (@good) {
	run("$bowtie $a e_coli reads/e_coli_1000.fq /dev/null") == 0 || die "bowtie should have accepted: \"$a\"\n";
	run("$bowtie_d $a e_coli reads/e_coli_1000.fq /dev/null") == 0 || die "bowtie-debug should have accepted: \"$a\"\n";
	print "PASSED: good args \"$a\"\n";
}
print "\nGoodEx:\n";
for my $a (@goodEx) {
	run("$bowtie $a /dev/null") == 0 || die "bowtie should have accepted: \"$a\"\n";
	run("$bowtie_d $a /dev/null") == 0 || die "bowtie-debug should have accepted: \"$a\"\n";
	print "PASSED: good args \"$a\"\n";
}
