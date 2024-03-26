#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename qw(fileparse);
use List::Util qw(uniq);

my @codecs = qw(jxl jpeg420 jpeg444 jpegli opj444 avif420 avif444);

my @plot_formats = qw(png svg);

sub extract_cvvdp {
	my ($name, $codec) = @_;
	print ": foreach {cvvdp_raw_${name}_$codec} |> ^o Extracting CVVDP score from %f^ perl -nE '/^cvvdp=(?<q>.*) \\[JOD\\]/ or next; say \$+{q};' %f > %o |> encoded/$codec/%B {cvvdp_$name}\n";
}

while (<images/*.png>) {
	my $name = fileparse $_, '.png';

	print ": $_ |> ^t^ convert %f %o |> encoded/$name.icc\n";
	print ": $_ |> ^t^ convert %f -depth 12 %o |> encoded/$name.ppm\n";

	# JPEG XL
	for my $d ((map {$_ / 100} 10 .. 69), (map {$_ / 20} 14 .. 220)) {
		print ": $_ |> ^o^ tools/cjxl -d $d %f %o |> encoded/jxl/jxl_${name}_d$d.jxl {enc_jxl_$name}\n";
	}
	print ": foreach {enc_jxl_$name} |> ./compute-bitrate.pl %f `identify -format '%%w %%h' $_` > %o |> encoded/jxl/%B.bpp.txt {bpp_$name}\n";
	print ": foreach {enc_jxl_$name} |> ^t^ tools/djxl %f %o |> decoded/jxl/%B.png {dec_jxl_$name}\n";
	print ": foreach {dec_jxl_$name} |> ^o^ tools/butteraugli_main $_ %f > %o |> encoded/jxl/%B.butteraugli.txt {butteraugli_$name}\n";
	print ": foreach {dec_jxl_$name} |> ^o^ cd hdr_metrics && ./pu2_psnr_main.m ../$_ ../%f > ../%o |> encoded/jxl/%B.pu2_psnr.txt {pu2_psnr_$name}\n";
	print ": foreach {dec_jxl_$name} |> ^o^ cd hdrvdp-3.0.7 && ./hdrvdp_main.m ../$_ ../%f > ../%o |> encoded/jxl/%B.hdrvdp3.txt {hdrvdp3_$name}\n";
	print ": foreach {enc_jxl_$name} |> ^o^ tools/ssimulacra2 $_ %f > %o |> encoded/jxl/%B.ssimulacra2.txt {ssimulacra2_$name}\n";
	print ": foreach {dec_jxl_$name} |> ^o^ poetry run cvvdp --ref $_ --test %f --display standard_hdr_pq > %o |> encoded/jxl/%B.cvvdp.txt.raw {cvvdp_raw_${name}_jxl}\n";
	extract_cvvdp $name, 'jxl';

	# OpenJPEG (JPEG 2000)
	for my $r (uniq map {int(3*12 / ($_ / 10))} 2 .. 30) {
		print ": encoded/$name.ppm | encoded/$name.icc |> ^o^ tools/opj_compress -r $r -i %f -o %o && exiftool -ICC_Profile'<='encoded/$name.icc -overwrite_original %o |> encoded/opj444/opj444_${name}_r$r.jp2 {enc_opj444_$name}\n";
	}

	for my $chroma (qw(444)) {
		print ": foreach {enc_opj${chroma}_$name} |> ./compute-bitrate.pl %f `identify -format '%%w %%h' $_` > %o |> encoded/opj$chroma/%B.bpp.txt {bpp_$name}\n";

		print ": foreach {enc_opj${chroma}_$name} |> ^t^ tools/opj_decompress -i %f -o %o |> decoded/opj$chroma/%B.ppm {ppm_opj${chroma}_$name}\n";
		print ": foreach {enc_opj${chroma}_$name} |> ^t^ exiftool %f -o %o |> decoded/opj$chroma/%B.icc\n";
		print ": foreach {ppm_opj${chroma}_$name} | decoded/opj$chroma/%B.icc |> ^t^ convert %f -profile decoded/opj$chroma/%B.icc %o |> decoded/opj$chroma/%B.png {dec_opj${chroma}_$name}\n";

		print ": foreach {dec_opj${chroma}_$name} |> ^o^ tools/butteraugli_main $_ %f > %o |> encoded/opj$chroma/%B.butteraugli.txt {butteraugli_$name}\n";
		print ": foreach {dec_opj${chroma}_$name} |> ^o^ cd hdr_metrics && ./pu2_psnr_main.m ../$_ ../%f > ../%o |> encoded/opj$chroma/%B.pu2_psnr.txt {pu2_psnr_$name}\n";
		print ": foreach {dec_opj${chroma}_$name} |> ^o^ cd hdrvdp-3.0.7 && ./hdrvdp_main.m ../$_ ../%f > ../%o |> encoded/opj$chroma/%B.hdrvdp3.txt {hdrvdp3_$name}\n";
		print ": foreach {dec_opj${chroma}_$name} |> ^o^ tools/ssimulacra2 $_ %f > %o |> encoded/opj$chroma/%B.ssimulacra2.txt {ssimulacra2_$name}\n";
		print ": foreach {dec_opj${chroma}_$name} |> ^o^ poetry run cvvdp --ref $_ --test %f --display standard_hdr_pq > %o |> encoded/opj$chroma/%B.cvvdp.txt.raw {cvvdp_raw_${name}_opj$chroma}\n";
		extract_cvvdp $name, "opj$chroma";
	}

	# 12-bit JPEG
	for my $q (1 .. 100) {
		print ": encoded/$name.ppm | encoded/$name.icc |> ^o^ tools/jpeg -qt 3 -h -oz -v -qv -q $q %f %o && exiftool -ICC_Profile'<='encoded/$name.icc -overwrite_original %o |> encoded/jpeg444/jpeg444_${name}_q$q.jpg {enc_jpeg444_$name}\n";
		print ": encoded/$name.ppm | encoded/$name.icc |> ^o^ tools/jpeg -qt 3 -h -oz -v -qv -s 1x1,2x2,2x2 -q $q %f %o && exiftool -ICC_Profile'<='encoded/$name.icc -overwrite_original %o |> encoded/jpeg420/jpeg420_${name}_q$q.jpg {enc_jpeg420_$name}\n";
	}

	for my $chroma (qw(420 444)) {
		print ": foreach {enc_jpeg${chroma}_$name} |> ./compute-bitrate.pl %f `identify -format '%%w %%h' $_` > %o |> encoded/jpeg$chroma/%B.bpp.txt {bpp_$name}\n";

		print ": foreach {enc_jpeg${chroma}_$name} |> ^t^ tools/jpeg %f %o |> decoded/jpeg$chroma/%B.ppm {ppm_jpeg${chroma}_$name}\n";
		print ": foreach {enc_jpeg${chroma}_$name} |> ^t^ exiftool %f -o %o |> decoded/jpeg$chroma/%B.icc\n";
		print ": foreach {ppm_jpeg${chroma}_$name} | decoded/jpeg$chroma/%B.icc |> ^t^ convert %f -profile decoded/jpeg$chroma/%B.icc %o |> decoded/jpeg$chroma/%B.png {dec_jpeg${chroma}_$name}\n";

		print ": foreach {dec_jpeg${chroma}_$name} |> ^o^ tools/butteraugli_main $_ %f > %o |> encoded/jpeg$chroma/%B.butteraugli.txt {butteraugli_$name}\n";
		print ": foreach {dec_jpeg${chroma}_$name} |> ^o^ cd hdr_metrics && ./pu2_psnr_main.m ../$_ ../%f > ../%o |> encoded/jpeg$chroma/%B.pu2_psnr.txt {pu2_psnr_$name}\n";
		print ": foreach {dec_jpeg${chroma}_$name} |> ^o^ cd hdrvdp-3.0.7 && ./hdrvdp_main.m ../$_ ../%f > ../%o |> encoded/jpeg$chroma/%B.hdrvdp3.txt {hdrvdp3_$name}\n";
		print ": foreach {dec_jpeg${chroma}_$name} |> ^o^ tools/ssimulacra2 $_ %f > %o |> encoded/jpeg$chroma/%B.ssimulacra2.txt {ssimulacra2_$name}\n";
		print ": foreach {dec_jpeg${chroma}_$name} |> ^o^ poetry run cvvdp --ref $_ --test %f --display standard_hdr_pq > %o |> encoded/jpeg$chroma/%B.cvvdp.txt.raw {cvvdp_raw_${name}_jpeg$chroma}\n";
		extract_cvvdp $name, "jpeg$chroma";
	}

	# jpegli
	for my $q (1 .. 100) {
		print ": $_ |> ^o^ tools/cjpegli -q $q %f %o |> encoded/jpegli/jpegli_${name}_q$q.jpg {enc_jpegli_$name}\n";
	}

	print ": foreach {enc_jpegli_$name} |> ./compute-bitrate.pl %f `identify -format '%%w %%h' $_` > %o |> encoded/jpegli/%B.bpp.txt {bpp_$name}\n";

	print ": foreach {enc_jpegli_$name} |> ^t^ tools/djpegli --bitdepth=16 %f %o |> decoded/jpegli/%B.png {dec_jpegli_$name}\n";

	print ": foreach {dec_jpegli_$name} |> ^o^ tools/butteraugli_main $_ %f > %o |> encoded/jpegli/%B.butteraugli.txt {butteraugli_$name}\n";
	print ": foreach {dec_jpegli_$name} |> ^o^ cd hdr_metrics && ./pu2_psnr_main.m ../$_ ../%f > ../%o |> encoded/jpegli/%B.pu2_psnr.txt {pu2_psnr_$name}\n";
	print ": foreach {dec_jpegli_$name} |> ^o^ cd hdrvdp-3.0.7 && ./hdrvdp_main.m ../$_ ../%f > ../%o |> encoded/jpegli/%B.hdrvdp3.txt {hdrvdp3_$name}\n";
	print ": foreach {dec_jpegli_$name} |> ^o^ tools/ssimulacra2 $_ %f > %o |> encoded/jpegli/%B.ssimulacra2.txt {ssimulacra2_$name}\n";
	print ": foreach {dec_jpegli_$name} |> ^o^ poetry run cvvdp --ref $_ --test %f --display standard_hdr_pq > %o |> encoded/jpegli/%B.cvvdp.txt.raw {cvvdp_raw_${name}_jpegli}\n";
	extract_cvvdp $name, "jpegli";

	# AVIF
	for my $q (1 .. 100) {
		print ": $_ |> ^o^ avifenc -y 420 --ignore-icc --cicp 9/16/9 -q $q %f %o |> encoded/avif420/avif420_${name}_q$q.avif {enc_avif420_$name}\n";
		print ": $_ |> ^o^ avifenc -y 444 --ignore-icc --cicp 9/16/9 -q $q %f %o |> encoded/avif444/avif444_${name}_q$q.avif {enc_avif444_$name}\n";
	}

	for my $chroma (qw(420 444)) {
		print ": foreach {enc_avif${chroma}_$name} |> ./compute-bitrate.pl %f `identify -format '%%w %%h' $_` > %o |> encoded/avif$chroma/%B.bpp.txt {bpp_$name}\n";
		print ": foreach {enc_avif${chroma}_$name} | encoded/$name.icc |> ^t^ avifdec %f %o |> decoded/avif$chroma/%B.png {dec_avif${chroma}_$name}\n";
		print ": foreach {dec_avif${chroma}_$name} |> ^o^ tools/butteraugli_main $_ %f > %o |> encoded/avif$chroma/%B.butteraugli.txt {butteraugli_$name}\n";
		print ": foreach {dec_avif${chroma}_$name} |> ^o^ cd hdr_metrics && ./pu2_psnr_main.m ../$_ ../%f > ../%o |> encoded/avif$chroma/%B.pu2_psnr.txt {pu2_psnr_$name}\n";
		print ": foreach {dec_avif${chroma}_$name} |> ^o^ cd hdrvdp-3.0.7 && ./hdrvdp_main.m ../$_ ../%f > ../%o |> encoded/avif$chroma/%B.hdrvdp3.txt {hdrvdp3_$name}\n";
		print ": foreach {dec_avif${chroma}_$name} |> ^o^ tools/ssimulacra2 $_ %f > %o |> encoded/avif$chroma/%B.ssimulacra2.txt {ssimulacra2_$name}\n";
		print ": foreach {dec_avif${chroma}_$name} |> ^o^ poetry run cvvdp --ref $_ --test %f --display standard_hdr_pq > %o |> encoded/avif${chroma}/%B.cvvdp.txt.raw {cvvdp_raw_${name}_avif$chroma}\n";
		extract_cvvdp $name, "avif$chroma";
	}

	for my $metric (qw(butteraugli pu2_psnr hdrvdp3 ssimulacra2 cvvdp)) {
		for my $format (@plot_formats) {
			print ": {bpp_$name} | {${metric}_$name} |> ^o Plotting %o^ poetry run python3 plot_metric.py %o $name $metric '@codecs' %f |> plots/${name}_$metric.$format {${format}_plots}\n";
		}

		for my $codec (@codecs) {
			print ": {bpp_$name} | {${metric}_$name} |> ^o Preparing CSV file %o^ python3 create_csv.py %o $name $metric $codec %f |> metrics/${name}_${metric}_$codec.csv {csv}\n";
		}
	}
}
