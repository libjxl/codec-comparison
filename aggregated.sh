#!/bin/bash

mkdir -p plots


    for m in cvvdp ssimulacra2 butteraugli pu2_psnr hdrvdp3
    do
        outfile="plots/gains_avg_${i}_${m}.png"
        python3 plot_aggregated.py $outfile 'Starting Market HancockKitchenInside BloomingGorse2 sintel_2 ClassE_507 ClassE_LasVegasStore ClassE_MtRushmore2 ClassE_WillyDesk ClassE_LabTypewriter ClassE_McKeesPub ClassE_Sunrise' $m 'jpeg420 jpeg444 jpegli avif420 avif444 jxl' metrics/ avg
        outfile="plots/gains_min_${i}_${m}.png"
        python3 plot_aggregated.py $outfile 'Starting Market HancockKitchenInside BloomingGorse2 sintel_2 ClassE_507 ClassE_LasVegasStore ClassE_MtRushmore2 ClassE_WillyDesk ClassE_LabTypewriter ClassE_McKeesPub ClassE_Sunrise' $m 'jpeg420 jpeg444 jpegli avif420 avif444 jxl' metrics/ min
        outfile="plots/gains_both_${i}_${m}.png"
        python3 plot_aggregated.py $outfile 'Starting Market HancockKitchenInside BloomingGorse2 sintel_2 ClassE_507 ClassE_LasVegasStore ClassE_MtRushmore2 ClassE_WillyDesk ClassE_LabTypewriter ClassE_McKeesPub ClassE_Sunrise' $m 'jpeg420 jpeg444 jpegli avif420 avif444 jxl' metrics/ both
    done
