<!-- dx-header -->
# mosdepth (DNAnexus Platform App)

## What does this app do?
Calculates coverage metrics for a given BAM file.

## What are typical use cases for this app?
This app may be executed as a standalone app.

## What data are required for this app to run?
This app requires a BAM and corresponding index file, and may also be passed optional arguments as described in the docs: https://github.com/brentp/mosdepth.

Usage of bed file requires passing the optional bed file argument, to do so please specify "--by" in the optional arguments, there is no need to specify the full bed file name as per the docs.

## What does this app output?
This app outputs:
- `{prefix}.mosdepth.global.dist.txt`
- `{prefix}.mosdepth.summary.txt`
- `{prefix}.mosdepth.region.dist.txt` (if --by is specified)
- `{prefix}.per-base.bed.gz` (unless -n/--no-per-base is specified)
- `{prefix}.regions.bed.gz` (if --by is specified)
- `{prefix}.quantized.bed.gz` (if --quantize is specified)
- `{prefix}.thresholds.bed.gz` (if --thresholds is specified)

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://documentation.dnanexus.com/.

#### This app was made by EMEE GLH