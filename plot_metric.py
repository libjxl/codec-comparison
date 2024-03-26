#!/usr/bin/env python3
import matplotlib.pyplot as plt
import matplotlib.ticker
import math
import os.path
import re
import sys

min_bpp, max_bpp = 0.3, 3

codec_name = {
    'jxl': 'JPEG XL',
    'jpeg420': '12-bit JPEG (4:2:0)',
    'jpeg444': '12-bit JPEG (4:4:4)',
    'opj444': 'OpenJPEG (JPEG 2000)',
    'avif420': 'AVIF (4:2:0)',
    'avif444': 'AVIF (4:4:4)',
}

metric_name = {
    'hdrvdp3': 'HDR-VDP 3',
    'butteraugli': 'Butteraugli 3-norm',
    'ssimulacra2': 'SSIMULACRA 2',
    'pu2_psnr': 'PU2 PSNR',
    'cvvdp': 'CVVDP (inverse logscale)',
}


color = {
    'jxl': (59/255,182/255,179/255),
    'jpeg420': (123/255,138/255,148/255),
    'jpeg444': (123/255,138/255,148/255),
    'avif420': (251/255,174/255,44/255),
    'avif444': (251/255,174/255,44/255),
    'opj444': (68/255, 198/255, 243/255),
    'jpegli': (220/255, 30/255, 30/255),
}
linestyle = {
    'jxl': 'solid',
    'jpeg420': 'dotted',
    'jpeg444': 'solid',
    'avif420': 'dotted',
    'avif444': 'solid',
    'opj444': 'solid',
    'jpegli': 'solid',
}
marker = {
    'jxl': '.',
    'jpeg420': 's',
    'jpeg444': '.',
    'avif420': 'v',
    'avif444': '^',
    'opj444': '.',
    'jpegli': '.',
}

_, output, image_name, metric, codecs, *bpp_files = sys.argv

codecs = codecs.split()

datapoints = {codec: {'bpp': [], 'metric': []} for codec in codecs}

for bpp_file in bpp_files:
    bpp_basename = os.path.basename(bpp_file)
    [codec] = (codec for codec in codecs if bpp_basename.startswith(codec))

    with open(bpp_file) as f:
        bpp = float(f.readline())
        if not (min_bpp <= bpp <= max_bpp + 1): continue
        datapoints[codec]['bpp'].append(bpp)

    metric_file = re.sub('\\.bpp\\.txt$', f'.{metric}.txt', bpp_file)
    with open(metric_file) as f:
        lastline = ''
        for line in f:
            lastline = line
        value = float(lastline.removeprefix('3-norm: '))
        try:
            if metric == 'cvvdp':
                value = -math.log10(10 - value)
            datapoints[codec]['metric'].append(value)
        except ValueError:
            print(f"Invalid CVVDP value {value} in {metric_file}", file=sys.stderr)
            del datapoints[codec]['bpp'][-1]

fig = plt.gcf()
fig.set_size_inches(*(2 * fig.get_size_inches()))

plt.xlim([min_bpp - .1, max_bpp + .1])
if metric == 'ssimulacra2':
    plt.ylim([40, 100])
elif metric == 'butteraugli':
    plt.ylim([0, 2])
plt.xlabel('Bits per pixel (bpp)')
plt.ylabel(metric_name[metric])
plt.title(image_name)

axes = fig.gca()

axes.xaxis.set_major_locator(matplotlib.ticker.MultipleLocator(0.5))
axes.xaxis.set_minor_locator(matplotlib.ticker.MultipleLocator(0.1))

if metric == 'cvvdp':
    axes.yaxis.set_major_locator(matplotlib.ticker.MultipleLocator(1))
    axes.yaxis.set_minor_locator(matplotlib.ticker.MultipleLocator(1, offset=-math.log10(0.5)))
    def format_ytick(y, pos):
        return f"{10 - 10**(-y)}"
    axes.yaxis.set_major_formatter(format_ytick)
    axes.yaxis.set_minor_formatter(format_ytick)
elif metric == 'hdrvdp3':
    axes.yaxis.set_minor_locator(matplotlib.ticker.MultipleLocator(0.1))
elif metric == 'pu2_psnr' or metric == 'ssimulacra2':
    axes.yaxis.set_major_locator(matplotlib.ticker.MultipleLocator(10))
    axes.yaxis.set_minor_locator(matplotlib.ticker.MultipleLocator(2))
elif metric == 'butteraugli':
    axes.yaxis.set_major_locator(matplotlib.ticker.MultipleLocator(0.5))
    axes.yaxis.set_minor_locator(matplotlib.ticker.MultipleLocator(0.1))

plt.grid(which='major')
plt.grid(which='minor', linestyle='--')

for codec, data in datapoints.items():
    options = {'label': codec_name.get(codec, codec)}
    if codec in marker:
        options['marker'] = marker[codec]
    if codec in color:
        options['color'] = color[codec]
    if codec in linestyle:
        options['linestyle'] = linestyle[codec]
    plt.plot(data['bpp'], data['metric'], alpha=0.6, **options)

plt.legend()

plt.savefig(output)
