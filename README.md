<!-- dx-header -->
# mosdepth (DNAnexus Platform App)

## What does this app do?
Calculates coverage metrics for a given BAM file.
<br></br>

## What are typical use cases for this app?
This app may be executed as a standalone app.
<br></br>

## What data are required for this app to run?
Required input files:
1. A BAM file (`.bam`), 
2. A corresponding index file (`.bai`), 
3. Quality Flag (`boolean; default:true`) - *When calculating coverage to get a more accurate calculation it is required to discount multi mapped reads (those with a MAPQ of 0), and duplicate reads.  This is done by default with the Quality Flags input parameter, but may be included by setting to False.*
4. Mosdepth Docker image (`tar.gz`)<br>
Optional input:<br>
5. Optional arguments (`string`) - *as described in the docs: https://github.com/brentp/mosdepth.*
6. A bed file, *optional* (`.bed`) - *Usage of bed file does not require passing any additional flags as per the docs, it just requires that the bed file is passed as the bed input.*
7. Quantize label (`string`) - 

Usage of the "--quantize" option also has optional labels as an input. By default if none are given and 4 bins are passed, the default labels from the docs are used. For &ne; 4 bins or custom labels, this should be passed as a comma seperated list in "quantize_labels".

e.g. For the following 6 bins: 
    `--quantize 0:1:4:50:100:200:` <br/>
    The following label option would be passed: 
    `"label1, label2, label3, label4, label5, label6"`
<br></br>

## What does this app output?
This app outputs:
- `{prefix}.mosdepth.global.dist.txt`
- `{prefix}.mosdepth.summary.txt`
- `{prefix}.mosdepth.region.dist.txt` (if --by is specified)
- `{prefix}.per-base.bed.gz` (unless -n/--no-per-base is specified)
- `{prefix}.regions.bed.gz` (if --by is specified)
- `{prefix}.quantized.bed.gz` (if --quantize is specified)
- `{prefix}.thresholds.bed.gz` (if --thresholds is specified)
- `reference_build.txt`

## How to run this app from command line?
```
dx run eggd_mosdepth \
-ibam=file-xxxx \
-iindex=file-xxxx  \
-imosdepth_docker=file-xxxx \
```

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://documentation.dnanexus.com/.

#### This app was made by EMEE GLH