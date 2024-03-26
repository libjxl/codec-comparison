# Codec comparison

This repository contains a set of scripts to compare lossy image codecs
according to various automated image quality metrics.

## Usage

To produce the plots, make sure the following packages (or their non-Debian
equivalents) are installed:

    imagemagick libavif-bin libimage-exiftool-perl octave-image octave-statistics python3-poetry tup

And that the following binaries are placed in `tools/`:

- from libjxl: `butteraugli_main` `cjpegli` `djpegli` `cjxl` `djxl`
  `ssimulacra2`

- from https://github.com/thorfdbg/libjpeg: `jpeg`

Then, place the images to be assessed in `images/` as Rec. 2020 / PQ 16-bit
PNGs, and run:

    poetry install --no-root
    tup

After a while, the plots should be in `plots/` in PNG and SVG formats. (The
output formats can be changed by modifying `@plot_formats` in `commands.pl` and
rerunning `tup`. For example, `pdf` can be added if desired, e.g. for inclusion
in a LaTeX document.)
