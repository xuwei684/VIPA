#!/usr/bin/perl -w 

use strict;
#use Bio::DB::Fasta;

if(scalar(@ARGV) == 0){
	print help_text();
	exit(0);
}

## mandatory arguments

my $break_result = "";
my $genome = "";
my $flank = "";
my $output_fname = "";

## parse command line arguments

while (scalar(@ARGV) > 0){
	my $this_arg = shift @ARGV;
	if ($this_arg eq '-h') {print help_text; exit; }
	
	elsif ($this_arg eq '-b') {$break_result = shift @ARGV;}
	elsif ($this_arg eq '-g') {$genome = shift @ARGV;}
	elsif ($this_arg eq '-f') {$flank = shift @ARGV;}
	elsif ($this_arg eq '-o') {$output_fname = shift @ARGV}
	elsif ($this_arg =~ m/^-/) {print "unknown flag: $this_arg\n";}
}

if($break_result eq ""){
	die "you should specify the break result file\n";
}
if($genome eq ""){
	die "you should specify the genome file identical with the break result\n";
}
if($flank eq ""){
	die "you should specify the length of upstream/downstream of break site\n";
}
if($output_fname eq ""){
	die "you should specify output filename\n";
}

#my $human_db = Bio::DB::Fasta->new("$genome");

#################################
#read break result file provided#
#################################

open FILE, "<$break_result" || die "$!\n";
open OUT, ">$output_fname" || die "$!\n";

`touch $break_result.tmp.bed`;
`touch $break_result.tmp.fa`;

while(<FILE>){
	chomp;
	next if(/id/);
	my ($id,$hpvS,$hpvE,$hpvmap,$hgS,$hgE,$hgmap,$break_pos,$sanger) = split(/\s+/,$_);
	
	my ($chr1,$hpvS1,$hpvE1) = split(/:|-/,$hpvmap);
	my ($chr2,$hgS1,$hgE1) = split(/:|-/,$hgmap);
	#my @maps = split(/:|-/,$hgmap);
	my $insert_len = 0;
	my $insert = "";
	my $hpv_seq = "";
	my $hpv_seq1 = "";
	my $hpv_seq2 = "";
	my $hg_seq = "";
	my $hg_seq1 = "";
	my $hg_seq2 = "";
	my $total_seq = "";
	
	# calculate the insert length and get the insert sequence
	$insert_len = $hgS -$hpvE - 1; 
	
	if($insert_len<0){ #junctional microhomologies
		$insert = uc(substr($sanger, ($hgS - 1), ($hpvE - $hgS + 1)));
		$insert = ".".$insert.".";
	}elsif($insert_len==0){ #apparent blunt joins
		$insert = "-";
	}else{ #short insertion
		$insert = lc(substr($sanger, $hpvE, $insert_len)); 
	}
	
	if($insert_len<0){
		if($hgS-$hpvS>=$flank){
			$hpv_seq = substr($sanger, ($hgS-$flank-1), $flank);
		}else{
			$hpv_seq2 = substr($sanger, $hpvS-1, ($hgS - $hpvS));
			#$hpv_seq1 = uc($human_db->seq($chr1, $hpvS1+$hgS-$hpvS-$flank, $hpvS1-1));
			if($hpvS1 < $hpvE1){
				my $start = $hpvS1+$hgS-$hpvS-$flank-1;
				my $end = $hpvS1-1;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr1\t$start\t$end\tNA\t0\t+\n";
				close BED;
				`bedtools getfasta -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hpv_seq1 = uc($seq);
			}elsif($hpvS1 > $hpvE1){
				my $start = $hpvS1;
				my $end = $hpvS1+$hpvS-$hgS+$flank;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr1\t$start\t$end\tNA\t0\t-\n";
				close BED;
				`bedtools getfasta -s -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hpv_seq1 = uc($seq);
			}
			
			$hpv_seq = $hpv_seq1.$hpv_seq2;
		}
		
		if($hgE - ($hpvE+1) + 1 >= $flank){ 
			$hg_seq = uc(substr($sanger, $hpvE, $flank)); 
		}else{ 
			$hg_seq1 = uc(substr($sanger, $hpvE, ($hgE-$hpvE))); 
			#$hg_seq2 = uc($human_db->seq($chr2, $hgE1+1, $flank+$hgE1+$hpvE-$hgE));
			if($hgS1 < $hgE1){
				my $start = $hgE1;
				my $end = $hgE1+$hpvE-$hgE+$flank;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr2\t$start\t$end\tNA\t0\t+\n";
				close BED;
				`bedtools getfasta -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hg_seq2 = uc($seq);
			}elsif($hgS1 > $hgE1){
				my $start = $hgE1 + $hgE - $hpvE -$flank-1;
				my $end = $hgE1 - 1;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr2\t$start\t$end\tNA\t0\t-\n";
				close BED;
				`bedtools getfasta -s -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hg_seq2 = uc($seq);
			}
			
			$hg_seq = $hg_seq1.$hg_seq2;
		}
	}else{
		if($hpvE-$hpvS+1>=$flank){
			$hpv_seq = substr($sanger, $hpvE-$flank,$flank);
		}else{
			$hpv_seq2 = substr($sanger, $hpvS-1, $hpvE-$hpvS+1);
			#$hpv_seq1 = uc($human_db->seq($chr1, $hpvS1-$flank+$hpvE-$hpvS+1, $hpvS1-1));
			if($hpvS1 < $hpvE1){
				my $start = $hpvS1+$hpvE-$hpvS-$flank;
				my $end = $hpvS1-1;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr1\t$start\t$end\tNA\t0\t+\n";
				close BED;
				`bedtools getfasta -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hpv_seq1 = uc($seq);
			}elsif($hpvS1 > $hpvE1){
				my $start = $hpvS1;
				my $end = $hpvS1+$hpvS-$hpvE+$flank-1;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr1\t$start\t$end\tNA\t0\t-\n";
				close BED;
				`bedtools getfasta -s -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hpv_seq1 = uc($seq);
			}
			$hpv_seq = $hpv_seq1.$hpv_seq2;
		}
		
		if($hgE-$hgS+1>=$flank){
			$hg_seq = substr($sanger,$hgS-1,$flank);
		}else{
			$hg_seq1 = substr($sanger,$hgS-1,$hgE-$hgS+1);
			if($hgS1 < $hgE1){
				my $start = $hgE1;
				my $end = $hgE1+$hgS-$hgE+$flank-1;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr2\t$start\t$end\tNA\t0\t+\n";
				close BED;
				`bedtools getfasta -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hg_seq2 = uc($seq);
			}elsif($hgS1 > $hgE1){
				my $start = $hgE1+$hgE-$hgS - $flank;
				my $end = $hgE1 - 1;
				open BED, ">$break_result.tmp.bed";
				print BED "$chr2\t$start\t$end\tNA\t0\t-\n";
				close BED;
				`bedtools getfasta -s -fi $genome -bed $break_result.tmp.bed -fo $break_result.tmp.fa`;
				open FA, "$break_result.tmp.fa";
				my $seq;
				while(my $line = <FA>){
					next if($line =~ /^>/);
					chomp($line);
					$seq = $line;
				}
				close FA;
				$hg_seq2 = uc($seq);
			}
			$hg_seq = $hg_seq1.$hg_seq2;
		}
	}
	
	$total_seq = $hpv_seq.$insert.$hg_seq;
	my $break = length($hpv_seq);

	print OUT "$id\t",$break,"\t",$insert_len,"\tHG-HG\t$total_seq\n";
}

close FILE;
close OUT;

`rm $break_result.tmp.bed`;
`rm $break_result.tmp.fa`;

## help_text - Returns usage syntax and documentation ##

sub help_text {
	return <<HELP;

flanking_seq.pl - Script to get the flanking sequence around the break site

SYNOPSIS
perl flanking_seq.pl -b <breakresult> -g <fa> -f <flank> -o <output file>

OPTIONS
-b Break result with assembled sequence
-g Human genome
-f The length of flanking sequence around the break site
-o Output file name
-h Show this message

DESCRIPTION
This is a command-line interface to flanking_seq.pl

AUTHOURS
Hu Zheng <lt>email<gt>

HELP
}
