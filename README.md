SD-EJ Tool
=====================

SD-EJ Tool is a classification tool of synthesis-dependent microhomology-mediated end joining for fusion sequence, for instance, human-virus breakpoint sequences. The SD-EJ Tool consists of tow scripts, including flanking_seq.pl and SDEJ_classification.pl.

Quick start
-----------

Download the `flanking_seq.pl` and `SDEJ_classification.pl` scripts, and view the detailed usage manual:

    curl -LO https://github.com/xuwei684/VIPA/archive/master.zip; unzip master.zip
    perl VIPA-master/SDEJ/flanking_seq.pl -h
    perl VIPA-master/SDEJ/SDEJ_classification.pl -h

Step 1: Get the flanking sequence around the breakpoint site.
--------------------------------------------------------

Run the `flanking_seq.pl` script using the breakpoint results as an input:

    perl flanking_seq.pl -b <breakpoint results> -g <genome> -f <flanking>  -o <output file>

**Inputs**

1). breakpoint results: the result of the pipeline for finding the breakpoints in cancer genome, and the breakpoint results should contains **at least 9 cloumns**，below is the example of human-virus breakpoint results：
                                            
    a. id
    b. virus_start ie.1
    c. virus_end    ie.113
    d. virus_map    ie.hpv16:1439-1551
    e. human_start  ie.114
    f. human_end    ie.180
    g. human_map    ie.chr3:93470597-93470663
    h. human_breakpoint ie.chr3:93470597
    i. breakpoint sequence

Notice: the human and virus genome mapping position should be identical with the genome you used to find the breakpoint identification.

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



Step 2: Find the repeats and classify the SD-EJ pathway
---------------------------------------------------------------

Run the `SDEJ_classification.pl` script using the output of the `flanking_seq.pl` as an input:

    perl SDEJ_classification.pl -s <flanking_seq.txt> -p <primer length> -m <mh length> -o <output file>

**Inputs**

flanking_seq.txt

The -p and -m can be omitted and will use the default value 2 and 1.

**Output**

SD-EJ.html

The html file contains 4 cloumns.

    a. the serial number of the sequences in the flanking_seq.txt
    b. ids
    c. SD-EJ Repair type
    d. The sequence of repair products with primer repeats underlined
