#!/usr/bin/env octave

warning('off', 'Octave:shadowed-function');

pkg load statistics;
pkg load image;

addpath(fileparts(mfilename('fullpath')));

args = argv();

original_filename = args{1};
decoded_filename = args{2};

original = imread(original_filename);
decoded = imread(decoded_filename);

function L = PQToLinear(pq)
	pq_float = single(pq) / 65535;

	kPQM1 = 2610 / 16384;
	kPQM2 = 128 * 2523 / 4096;
	kPQC1 = 3424 / 4096;
	kPQC2 = 32 * 2413 / 4096;
	kPQC3 = 32 * 2392 / 4096;

	pq_pow_inv_m2 = pq_float .^ (1 / kPQM2);
	L = 10000 * (max(0, pq_pow_inv_m2 - kPQC1) ./ (kPQC2 - kPQC3 .* pq_pow_inv_m2)) .^ (1 / kPQM1);
end

original = PQToLinear(original);
decoded = PQToLinear(decoded);

printf("%f\n", hdrvdp3('quality', decoded, original, 'rgb-bt.2020', 30, {'use_gpu', false}).Q);
