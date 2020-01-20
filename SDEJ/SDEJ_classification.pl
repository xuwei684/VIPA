#!/usr/bin/perl -w 

use strict;

if(scalar(@ARGV) == 0){
	print help_text;
	exit(0);
}

## mandatory arguments

my $break_seq = "";
my $pl = 2;
my $mhl = 1;
my $output = "";

## parse command line arguments

while (scalar(@ARGV) > 0){
	my $this_arg = shift @ARGV;
	if( $this_arg eq '-h') {print help_text(); exit; }
	
	elsif ($this_arg eq '-s') {$break_seq = shift @ARGV;}
	elsif ($this_arg eq '-p') {$pl = shift @ARGV;}
	elsif ($this_arg eq '-m') {$mhl = shift @ARGV;}
	elsif ($this_arg eq '-o') {$output = shift @ARGV;}
	elsif ($this_arg =~ m/^-/) {print "unknown flag: $this_arg\n";}
}

if($break_seq eq ""){
	die "you should specify the break file\n";
}
if($output eq ""){
	die "you should specify the output filename\n";
}

##########################
#read break file provided#
##########################

open FILE, "<$break_seq" || die "$!\n";
open OUT, ">$output" ||die "$!\n";

print OUT '<HTML>
<BODY BGCOLOR="#FFEEE0">
<PRE>
';

$| = 1; #clear cache
my $SDmmej = "";
my $flag = "";
while(<FILE>){
	chomp;
	my @tmp = split;
	my $id = $tmp[0];
	my $break = $tmp[1] - 1;
	my $insert_len = $tmp[2];
	$flag = $tmp[3];
	
	my $insert = 0;
	
	#sdmmej type according to insert length
	if($insert_len == 0 ){
		$SDmmej = "apparent_blunt_join";
		$insert = 0;
	}elsif($insert_len < 0){
		$SDmmej = "junctional_mh";
		$insert = 0;
	}else{
		$SDmmej = "short_insert";
		$insert = $insert_len;
	}
	
	my $seq = $tmp[4];
	my $pure_seq = $seq;
	$pure_seq =~ s/\.|-//g;
	my @primer = &get_repeat($pure_seq,$break,$insert);
	my $new_break = 0;
	if($SDmmej eq "junctional_mh" && !(@primer)){
		for(my $i=1;$i<=abs($insert_len);$i++){
			$new_break = $break + $i;
			@primer = &get_repeat($pure_seq,$new_break,$insert);
			if(@primer){
				last;
			}
		}
	}
	
	my $lineno = sprintf("%04d",$.);
	unless( @primer ){
		my $lineno = sprintf("%04d",$.);
		printf OUT ("%-8s",$lineno);
		printf OUT ("%-50s",$id);
		printf OUT ("%-50s","NA");
		print OUT "$seq\n";
		next;
	}
	
	my $primer_len = 0;
	for( my $i=0;$i<$#primer; $i+=4 ){
		last if( $primer[$i+2] < $primer_len );
		my $class;
		my $real_break = $break;
		if($new_break != 0){
			$real_break = $new_break;
		}
		if($primer[$i] <= $real_break && $primer[$i+1] <= $real_break){
			$class = (split(/_/,$flag))[0];
			$class .= "_Left";
		}elsif($primer[$i]+$primer[$i+2] >= $real_break && $primer[$i+1]+$primer[$i+2] >= $real_break){
			$class = (split(/_/,$flag))[1];
			$class .= "_Right";
		 }else{
			print "WRONG:$id:@primer[$i..$i+3]\n";
		}
		#$class .= "_$SDmmej"."_$primer[$i+3]";
		$class = "$SDmmej"."_$primer[$i+3]";
		printf OUT ("%-8s",$lineno);
		printf OUT ("%-50s",$id);
		printf OUT ("%-50s",$class);
		
		my $mh = 0;
		my $p = 0;
		if($primer[$i+1]>$primer[$i]){
			$mh = $real_break-$primer[$i]+1;
			$p = $primer[$i+2] - $mh - $insert;
		}else{
			$p = $real_break-$primer[$i]+1;
			$mh = $primer[$i+2] - $p - $insert;
		}
		
		my $count1 = 0;
		my $count2 = 0;
		my $count3 = 0;
		my $count4 = 0;
		my $count5 = 0;
		my $count6 = 0;
		if($insert_len == 0){
			if($primer[$i+1]>$primer[$i]){
				$count3 = 1;
				$count2 = 1;
			}else{
				$count5 = 1;
			}
		}elsif($insert_len < 0){
			if($primer[$i] <= $break){
				if($primer[$i]+$primer[$i+2] - 1 <= $break - $insert_len){
					if($primer[$i+1]>$primer[$i]){
						$count3 = 1;
						if($primer[$i+1] <= $break - $insert_len){
							$count2 = 1;
							if($primer[$i+1]+$primer[$i+2] - 1 > $break - $insert_len){
								if($primer[$i+3] eq "Loop-out"){
									if($primer[$i+1]+$mh-1>=$break - $insert_len){
										$count4 = 1;
									}else{
										$count6 = 1;
									}
								}elsif($primer[$i+3] eq "Snap-back"){
									if($primer[$i+1]+$p-1>$break - $insert_len){
										$count4 = 1;
									}else{
										$count6 = 1;
									}
								}
							}
						}else{
							$count2 = 2;
						}
					}else{
						if($primer[$i]+$p-1>$break){
							$count3 = 1;
						}else{
							$count5 = 1;
						}
					}
				}else{
					if($primer[$i+1]>$primer[$i]){
						if($primer[$i]+$mh-1<$break-$insert_len){ 
							$count3 = 1;
							$count5 = 1;
						}else{
							$count3 = 2;
						}
						$count2 = 2;
					}else{
						if($primer[$i]+$p-1<=$break){
							$count5 = 2;
						}else{
							$count3 = 1;
							$count5 = 1;
						}
					}
				}
			}else{
				$count1 = 1;
				if($primer[$i]+$primer[$i+2] - 1 <= $break - $insert_len){
					if($primer[$i+1]>$primer[$i]){
						if($primer[$i+1] <= $break - $insert_len){
							$count2 = 1;
							if($primer[$i+1]+$primer[$i+2] - 1 > $break - $insert_len){
								if($primer[$i+3] eq "Loop-out"){
									if($primer[$i+1]+$mh-1>=$break - $insert_len){
										$count4 = 1;
									}else{
										$count6 = 1;
									}
								}elsif($primer[$i+3] eq "Snap-back"){
									if($primer[$i+1]+$p-1>$break - $insert_len){
										$count4 = 1;
									}else{
										$count6 = 1;
									}
								}
							}
						}else{
							$count2 = 2;
						}
					}
				}else{
					if($primer[$i+1]>$primer[$i]){
						if($primer[$i]+$mh-1<$break-$insert_len){
							$count5 = 1;
						}else{
							$count3 = 1;
						}
						$count2 = 2;
					}else{
						if($primer[$i]+$p-1<=$break-$insert_len){
							$count5 = 1;
						}else{
							$count3 = 1;
						}
					}
				}
			}
		}else{
			if($primer[$i+1]>$primer[$i]){
				$count3 = $insert;
				if($primer[$i+3] eq "Loop-out"){
					$count4 = $insert;
				}elsif($primer[$i+3] eq "Snap-back"){
					$count6 = $insert;
				}
			}else{
				$count5 = $insert;
				if($primer[$i+3] eq "Loop-out"){
					$count6 = $insert;
				}elsif($primer[$i+3] eq "Snap-back"){
					$count4 = $insert;
				}
			}
		}
		
		my $print = &format($seq,$primer[$i],$primer[$i+1],$count1,$count2,$count3,$count4,$count5,$count6,$mh,$p,$primer[$i+3]);
		print OUT "$print\n";
		$primer_len = $primer[$i+2];
	}
}

print OUT '</SPAN></PRE>
</BODY>
</HTML>',"\n";

## get_repeat - Find the repeat ##

sub get_repeat{
	my $seq = shift;
	my $break = shift;
	my $insert= shift;
	$seq = uc($seq);
	my $len = length($seq);
	my @flag = ();
	foreach my $j( reverse(2 .. int($len/2)) ){
		foreach my $i(0 .. $break){
			next unless ($i+$j-1 > $break);
			my $pr1 = substr($seq,$i,$j);
			foreach my $k(0..$i-1,$i+$j .. $len-$j ){
				next if ($i>$k && $i < $k+$j);
				next unless( $k < $i && $break-$i+1 >=$pl && $j-($break-$i+1)-$insert>=$mhl || #primer on left
							 $k > $i && $break-$i+1>=$mhl && $j-($break-$i+1)-$insert>= $pl);  #primer on right
				my $pr2 = substr($seq,$k,$j);
				my $pr3 = reverse($pr2);
				$pr3 =~ tr/ATCG/TAGC/;
				my $p_flag ;
				if($pr1 eq $pr2){
					$p_flag = "Loop-out";
				}elsif($pr1 eq $pr3){
					$p_flag = "Snap-back";
				}else{
					next;
				}
				push @flag,($i,$k,$j,$p_flag);
			}
		}
	}
	return @flag;
}

## format - Print the result formatly in html type ##

sub format{
	my $seq = shift;
	my $i = shift;
	my $k = shift;
	my $count1 = shift;
	my $count2 = shift;
	my $count3 = shift;
	my $count4 = shift;
	my $count5 = shift;
	my $count6 = shift;
	my $mh = shift;
	my $p = shift;
	my $p_flag = shift;
	my $underline = '<span style="text-decoration:underline">';
	my $flag_end = '</span>';
	my $color;
	if($p_flag eq "Loop-out"){
		$color = '<span style="color: red">';
	}elsif($p_flag eq "Snap-back"){
		$color = '<span style="color: blue">';
	}
	my $subseq;
	if($k > $i){
		if($p_flag eq "Loop-out"){
			$subseq = substr($seq,$k+$count2+$mh+$count4,$p+$count6);
			substr($seq,$k+$count2+$mh+$count4,$p+$count6) = $underline.$color.$subseq.$flag_end.$flag_end;
			$subseq = substr($seq,$k+$count2,$mh+$count4);
			substr($seq,$k+$count2,$mh+$count4) = $underline.$subseq.$flag_end;
		}elsif($p_flag eq "Snap-back"){
			$subseq = substr($seq,$k+$count2+$p+$count4,$mh+$count6);
			substr($seq,$k+$count2+$p+$count4,$mh+$count6) = $underline.$subseq.$flag_end;
			$subseq = substr($seq,$k+$count2,$p+$count4);
			substr($seq,$k+$count2,$p+$count4) = $underline.$color.$subseq.$flag_end.$flag_end;
		}
		$subseq = substr($seq,$i+$count1+$mh+$count3,$p+$count5);
		substr($seq,$i+$count1+$mh+$count3,$p+$count5) = $underline.$color.$subseq.$flag_end.$flag_end;
		$subseq = substr($seq,$i+$count1,$mh+$count3);
		substr($seq,$i+$count1,$mh+$count3) = $underline.$subseq.$flag_end;
	}else{
		$subseq = substr($seq,$i+$count1+$p+$count3,$mh+$count5);
		substr($seq,$i+$count1+$p+$count3,$mh+$count5) = $underline.$subseq.$flag_end;
		$subseq = substr($seq,$i+$count1,$p+$count3);
		substr($seq,$i+$count1,$p+$count3) = $underline.$color.$subseq.$flag_end.$flag_end;
		
		if($p_flag eq "Loop-out"){
			$subseq = substr($seq,$k+$count2+$p+$count4,$mh+$count6);
			substr($seq,$k+$count2+$p+$count4,$mh+$count6) = $underline.$subseq.$flag_end;
			$subseq = substr($seq,$k+$count2,$p+$count4);
			substr($seq,$k+$count2,$p+$count4) = $underline.$color.$subseq.$flag_end.$flag_end;
		}elsif($p_flag eq "Snap-back"){
			$subseq = substr($seq,$k+$count2+$mh+$count4,$p+$count6);
			substr($seq,$k+$count2+$mh+$count4,$p+$count6) = $underline.$color.$subseq.$flag_end.$flag_end;
			$subseq = substr($seq,$k+$count2,$mh+$count4);
			substr($seq,$k+$count2,$mh+$count4) = $underline.$subseq.$flag_end;
		}
	}
	return $seq;
}

## help_text - Returns usage syntax and documentation ##

sub help_text {
	return <<HELP;

SDEJ_classification.pl - Script to find primer repeat around the break site and classify

SYNOPSIS
perl SDEJ_classification.pl -s <break seq> -p <primer length> -m <mh length> -o <output file>

OPTIONS
-s The output of flanking_seq.pl, it contains flanking sequence of break site
-p Length of primer. Default: 2
-m Length of microhomology. Default: 1
-o Output file name with a html extension

DESCRIPTION
This is a command-line interface to SDEJ_classification.pl

AUTHOURS
Hu Zheng <lt>email huzheng1998\@163.com<lt>

HELP
}
