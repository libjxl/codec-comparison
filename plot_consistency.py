#!/usr/bin/env python3
import matplotlib.pyplot as plt
import os.path
import re
import sys
import math

min_bpp, max_bpp = 0.3, 3

metric_name = {
    'hdrvdp3': 'HDR-VDP 3',
    'butteraugli': 'Butteraugli 3-norm',
    'ssimulacra2': 'SSIMULACRA 2',
    'pu2_psnr': 'PU2 PSNR',
    'cvvdp': 'CVVDP',
}


codec_name = {
    'jxl': 'JPEG XL',
    'jpeg420': '12-bit JPEG, 4:2:0',
    'jpeg444': '12-bit JPEG, 4:4:4',
    'avif420': 'AVIF, 4:2:0',
    'avif444': 'AVIF, 4:4:4',
    'opj444': 'OpenJPEG (JPEG 2000)',
    'jpegli': 'jpegli'
}
color = {
    'jxl': (59/255,182/255,179/255),
    'jpegli': (0.8,0,0),
    'opj444': (0.3,0.5,1),
    'jpeg420': (123/255,138/255,148/255),
    'jpeg444': (123/255,138/255,148/255),
    'avif420': (251/255,174/255,44/255),
    'avif444': (251/255,174/255,44/255),
}
linestyle = {
    'jxl': 'solid',
    'opj444': 'solid',
    'jpegli': 'solid',
    'jpeg420': 'dotted',
    'jpeg444': 'solid',
    'avif420': 'dotted',
    'avif444': 'solid',
}
marker = {
    'jxl': '.',
    'opj444': '.',
    'jpegli': '.',
    'jpeg420': 's',
    'jpeg444': '.',
    'avif420': 'v',
    'avif444': '^',
}

_, output, images, metric, codecs, csv_prefix = sys.argv

codecs = codecs.split()
images = images.split()

datapoints = {codec: {'setting': [], 'metric': [], 'bpp': []} for codec in codecs}


for codec in codecs:
  for image in images:
    bpp_file = csv_prefix + image + '_' + metric + '_' + codec + ".csv"
    setting = 0
    with open(bpp_file) as f:
      for line in f:
        l = line.split(",")
        if l[0] == 'bpp': continue
        bpp = float(l[0])
        val = float(l[1])
        setting += 1
        if metric == 'cvvdp':
            if val > 9.999: val=9.999

#        if not (min_bpp <= bpp <= max_bpp): continue
        datapoints[codec]['setting'].append(setting)
        datapoints[codec]['metric'].append(val)
        datapoints[codec]['bpp'].append(bpp)


plt.figure(figsize=(15,10))
plt.xlabel('Average ' + metric_name[metric] + ' for a given encoder setting')
plt.ylabel('Worst - average ' + metric_name[metric] + ' score for that encoder setting')
plt.title('Encoder consistency according to ' + metric_name[metric])

if metric == 'cvvdp':
    labels = [9,9.5,9.9,9.95,9.99,9.999]
    ticks = [-(math.log10(10-val)) for val in labels]
    plt.xticks(ticks=ticks,labels=labels)
else:
    plt.xticks()

plt.yticks()

plt.grid()


for codec, data in datapoints.items():
    pairs = list(zip(data['setting'], data['metric'], data['bpp']))
    settings = list(set(data['setting']))
    avgs = []
    vals = []
    for s in settings:
        bppvalues = [x[2] for x in pairs if x[0] == s]
        if sum(bppvalues)/len(bppvalues) < min_bpp: continue
        if sum(bppvalues)/len(bppvalues) > max_bpp: continue
        values = [x[1] for x in pairs if x[0] == s]
        avg = sum(values)/len(values)
        worst = min(values)
        if metric == 'ssimulacra2':
            if avg < 50: continue
        if metric == 'butteraugli':
            worst = max(values)
        vals.append(worst - avg)
        if metric == 'cvvdp':
            print(codec,s,avg,sum(bppvalues)/len(bppvalues))
            avg = -(math.log10(10-avg))
        avgs.append(avg)
    plt.plot(avgs, vals, alpha=0.6, label=codec_name[codec], marker=marker[codec], color=color[codec], linestyle=linestyle[codec])

plt.legend()

plt.savefig(output)
