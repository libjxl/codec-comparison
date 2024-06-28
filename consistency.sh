#!/bin/bash

mkdir -p plots


    for m in ssimulacra2 butteraugli cvvdp pu2_psnr hdrvdp3
    do
        outfile="plots/consistency_${i}_${m}.png"
        python3 plot_consistency.py $outfile 'Starting Market HancockKitchenInside BloomingGorse2 sintel_2 ClassE_507 ClassE_LasVegasStore ClassE_MtRushmore2 ClassE_WillyDesk ClassE_LabTypewriter ClassE_McKeesPub ClassE_Sunrise' $m 'jpeg420 jpeg444 jpegli avif420 avif444 jxl' metrics/
    done
