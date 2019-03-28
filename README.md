SDMMEJ-classification
=====================

A classification tool of synthesis-dependent microhomology-mediated end joining

Quick start
-----------

Download the `flanking_seq.pl` and `sdmmej_classification.pl` script, and view the detailed usage manual:

    curl -LO https://github.com/xuwei684/SDMMEJ/archive/master.zip; unzip master.zip
    perl SDMMEJ-classification-master/flanking_seq.pl -h
    perl SDMMEJ-classification-master/sdmmej_classification.pl -h

Step 1: Get the flanking sequence around the break site.
--------------------------------------------------------

Run the `flanking_seq.pl` script using the break result file as an input:

    perl flanking_seq.pl -b <break result> -g <genome> -f <flank> -s <fqdir or fafile> -o <output file>

Inputs

1). break result: the result of the pipeline for finding the break point in cancer, the breakresult should contains at least 8 cloumns

    a. id
    b. hpv_start
    c. hpv_end
    d. hpv_map
    e. human_start
    f. human_end
    g. human_map
    h. human_break

Notice: the human genome position should be identical with the genome you used to find the break point, and the name of the chromosome should be identical with the genome

2). genome: human genome
    the human genome should be identical with the genome you used to find the break point

3). flank: the length that you want to get around the break point

4). fqdir or fafile: a directory contains the sanger sequences or the assembled sequences, the sequence file name should be identical
 with the id in break result; a fasta file contains the sanger sequences or the assembled sequences, the sequence id in the file should be
 identical with the id in break result.

Output

flanking_seq.txt
The result file contains 5 cloumns.

    a. id
    b. break position
    c. insert_len
    d. flag indicates the form of the repair products
    e. the sequence of the repair products



Step 2: Find the repeats and classify the SDMMEJ-classification
---------------------------------------------------------------

Run the `sdmmej_classification.pl` script using the output of the `flanking_seq.pl` as an input:

    perl sdmmej_classification.pl -s <flanking_seq.txt> -p <primer length> -m <mh length> -o <output file>

Inputs
flanking_seq.txt

The -p and -m can be omitted and will use the default value 3 and 1.

Output

sdmmej.html
The html file contains 4 cloumns.

    a. the serial number of the sequence in the flanking_seq.txt
    b. id
    c. type
    d. the sequence of repair products with primer repeats underlined
