SD-EJ Tool
=====================



Introduction
-----------

SD-EJ Tool is a classification tool of synthesis-dependent microhomology-mediated end joining for fusion sequence, for instance, human-virus breakpoint sequences. 
The SD-EJ Tool consists of tow scripts, including flanking_seq.pl and SDEJ_classification.pl.


System requirements
-----------

SD-EJ Tool does not rely on any software and can run in any Linux and MacOS system. For Windows users, it requires perl programming languages, which can be installed by Strawberry Perl.


Installation guide
-----------

Download the `flanking_seq.pl` and `SDEJ_classification.pl` script and unzip:

    curl -LO https://github.com/xuwei684/VIPA/archive/master.zip; 
    unzip master.zip
    
Two scripts could be used directly and there is no need to compile, to view the detailed usage manual:

    perl VIPA-master/SDEJ/flanking_seq.pl -h
    perl VIPA-master/SDEJ/SDEJ_classification.pl -h

Time:

    time  curl -LO https://github.com/xuwei684/VIPA/archive/master.zip;
     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
    100   118    0   118    0     0    132      0 --:--:-- --:--:-- --:--:--   132
    100  7936    0  7936    0     0   4458      0 --:--:--  0:00:01 --:--:-- 14146

    real	0m1.848s
    user	0m0.054s
    sys	0m0.031s

Demo
-----------

We provide test example includes three files:

    test/breakpoints_results    the initial input dataset includes one HBV-human breakpoint
    test/flanking_seq.txt       the output of first script, flanking_seq.pl
    test/SDEJ.html              the final output of second script, SDEJ_classification.pl 


Instruction for use
-----------

There are two steps to use the SD-EJ tool, below is the instruction based on demo dataset.

Step 1: Get the flanking sequence around the breakpoint site.
--------------------------------------------------------

Run the `flanking_seq.pl` script using the breakpoint results as an input:

    perl  VIPA-master/SDEJ/flanking_seq.pl -b <breakpoint results> -g <genome> -f <flanking>  -o <output file>

**Input**

1). breakpoint results: the result of the pipeline for finding the breakpoints in cancer genome, and the breakpoint results should contains **at least 9 cloumns**，below is the example of human-virus breakpoint results：
                                            
    a. id
    b. virus_start 
    c. virus_end    
    d. virus_map   
    e. human_start  
    f. human_end    
    g. human_map    
    h. human_breakpoint
    i. breakpoint sequence

Notice: the human and virus genome mapping position should be identical with the genome you used to find the breakpoints, and human genome reference could be downloaded from UCSC, NCBI or ENSEMBL database.

2). genome: human genome
    the human genome should be identical with the genome you used to find the breakpoints

3). flanking: the length that you want to detect the SD-EJ around the breakpoints


**Output**

flanking_seq.txt

The result file contains 5 cloumns.

    a. ids
    b. breakpoint positions
    c. insert sequence lengths
    d. flags indicating the form of the SD-EJ repair products
    e. the sequences of the repair products of given flanking regions

**Run time on MacBook Pro**

Command:

    perl VIPA-master/SDEJ/flanking_seq.pl -b VIPA-master/test/breakpoint_results.txt -g hg38.fa -f 30 -o VIPA-master/test/flanking_seq.txt

Time:

    real	0m0.026s
    user	0m0.010s
    sys	0m0.012s


Step 2: Find the repeats and classify the SD-EJ pathway
---------------------------------------------------------------

Run the `SDEJ_classification.pl` script using the output of the `flanking_seq.pl` as an input:

    perl VIPA-master/SDEJ/SDEJ_classification.pl -s <flanking_seq.txt> -p <primer length> -m <mh length> -o <output file>

**Input**

flanking_seq.txt

The -p and -m can be omitted and will use the default value 2 and 1.

**Output**

SDEJ.html

The html file contains 4 cloumns.

    a. the serial number of the sequences in the flanking_seq.txt
    b. ids
    c. SD-EJ Repair type
    d. The sequence of repair products with primer repeats underlined

**Run time on MacBook Pro**

Command:

    perl VIPA-master/SDEJ/SDEJ_classification.pl -s VIPA-master/test/flanking_seq.txt  -p 2 -m 1 -o VIPA-master/test/SDEJ.html

Time:

    real	0m0.050s
    user	0m0.010s
    sys	0m0.032s

