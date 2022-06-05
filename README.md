# labchip
![image](http://resources.perkinelmer.com/lab-solutions/resources/images_for_resize/LabChip_GX_GXII_Touch_Product.jpg)

# Overview

This repository contains a simple script for converting [LabChip GX Touch](https://www.perkinelmer.com/uk/product/labchip-gx-touch-24-cls138162) oligonucleotide data into an easily interpretable .csv file for downstream analysis.

### How To

1) Export sample data from Labchip reviewer software and place all resulting files in the `input` directory

2) Open the `Config.R` and set the `min_size` and `max_size` in bp for the fragments of interest

3) Run `labchip.R` 
  - Output file will have the suffix 
