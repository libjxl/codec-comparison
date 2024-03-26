% This example is meant to be run from Octave instead of Matlab. It shows
% how to load the required libraries. 
% 
% The example is based on impairment_detection_sdr.m

pkg load statistics
pkg load image

if ~exist( 'hdrvdp3', 'file' )
    addpath( fullfile( pwd, '..') );
    addpath( fullfile( pwd, '../utils') );
end

% Display parameters
Y_peak = 200;     % Peak luminance in cd/m^2 (the same as nit)
contrast = 1000;  % Display contrast 1000:1
gamma = 2.2;      % Standard gamma-encoding
E_ambient = 100;  % Ambient light = 100 lux


% The input SDR images must have its peak value at 1.
% Note that this is a 16-bit image. Divide by 255 for 8-bit images.
I_ref = double(imread( 'wavy_facade.png' )) / (2^16-1);

% Find the angular resolution in pixels per visual degree:
% 30" 4K monitor seen from 0.5 meters
ppd = hdrvdp_pix_per_deg( 30, [3840 2160], 0.5 );

% Noise

% Create test image with added noise
noise = randn(size(I_ref,1),size(I_ref,2)) * 0.02;
I_test_noise = clamp( I_ref + repmat( noise, [1 1 3] ), 0, 1 );

% Converting gamma-encoded images to absolute linear values (using a GOG
% display model).
% Note that we use I_ to denote gamma-encoded images and L_ to denote
% linear images.
L_ref = hdrvdp_gog_display_model( I_ref, Y_peak, contrast, gamma, E_ambient );
L_test_noise = hdrvdp_gog_display_model( I_test_noise, Y_peak, contrast, gamma, E_ambient );

% Note that the color encoding is set to 'rgb-native' since SDR images have
% been converted to absolute linear RGB color space. 
res_noise_sbs = hdrvdp3( 'side-by-side', L_test_noise, L_ref, 'rgb-native', ppd, { 'use_gpu', false } );
res_noise_flicker = hdrvdp3( 'flicker', L_test_noise, L_ref, 'rgb-native', ppd, { 'use_gpu', false } );

I_context = L_ref;

display( res_noise_sbs.Q_JOD )
display( res_noise_flicker.Q_JOD )


% Visualize images
% The image size is not going to be correct because we are using subplot
clf
subplot( 1, 3, 1 );
imshow( I_test_noise );
title( 'Noisy image' );

subplot( 1, 3, 2 );
imshow( hdrvdp_visualize( res_noise_sbs.P_map, I_context ) );
title( 'Noise, task: side-by-side' );

subplot( 1, 3, 3 );
imshow( hdrvdp_visualize( res_noise_flicker.P_map, I_context ) );
title( 'Noise, task: flicker' );

waitforbuttonpress();

