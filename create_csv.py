#!/usr/bin/env python3
import csv
import os.path
import re
import sys

_, output, image_name, metric, codec, *bpp_files = sys.argv

with open(output, 'w') as out:
    writer = csv.writer(out, delimiter=',')
    writer.writerow(['bpp','metric'])

    for bpp_file in bpp_files:
        bpp_basename = os.path.basename(bpp_file)
        if not bpp_basename.startswith(codec): continue

        with open(bpp_file) as f:
            bpp = float(f.readline())

        metric_file = re.sub('\\.bpp\\.txt$', f'.{metric}.txt', bpp_file)
        with open(metric_file) as f:
            lastline = ''
            for line in f:
                lastline = line
            value = float(lastline.removeprefix('3-norm: '))

        writer.writerow([bpp, value])
