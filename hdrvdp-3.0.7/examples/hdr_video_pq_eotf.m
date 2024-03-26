% This example shows how to run HDR-VDP on HDR video, encoded with PQ
% EOTF. 
% 
% This particular example was tested on the content from LIVE HDR dataset:
%
% https://live.ece.utexas.edu/research/LIVEHDR/LIVEHDR_index.html
%
% You need to first manually decode video with ffmpeg, as explained in the
% comments below.
%
% The best is to run video quality assessment of a CUDA-enabled machine.
% This will reduce processing time substantially.

if ~exist( 'hdrvdp3', 'file' )
    addpath( fullfile( pwd, '..') );
end

colorspace = 'rgb-bt.2020';
E_ambient = 200; % Ambient illumination in lux ("bright" condition)
reflectivity_coeff = 0.005;
L_refl = reflectivity_coeff*E_ambient/pi;

resolution = [3840 2160];
diagonal_size_in = 64.5; % Samsung Q90T QLET 4K UHD HDR Smart TV
viewing_distance_m = 1.2960; % Display height * 1.5

ppd = hdrvdp_pix_per_deg(diagonal_size_in, resolution, viewing_distance_m);

% Matlab cannot decode h265-encoded HDR files. You can decode them to PNG
% images using ffmpeg:
% ffmpeg -i 4k_ref_golf2.mp4 tmp/ref_frame_%04d.png
% ffmpeg -i 1080p_6M_golf2.mp4 tmp/test_frame_%04d.png

% Update the path to where your decoded frames are located
frame_path = '/local/scratch-4/LIVEHDR/train/tmp';

N_frames = 571; % Different for each video clip
Q_JOD_sum = 0;
n = 0;
% Process every 30th frame (to reduce processing time)
for kk=1:30:N_frames
    fprintf( 1, "Processing frame %d out of %d\n", kk, N_frames );

    ref_path = fullfile( frame_path, "ref_frame_0001.png" );
    dis_path = fullfile( frame_path, "test_frame_0001.png" );

    dis_frame = im2single(imread(dis_path)) ;
    ref_frame = im2single(imread(ref_path)) ;

    % Distorted frames can have a lower resolution than the reference
    % frame. Note that the bicubic filter may result in values less than 0
    % or greater than 1, hence we added clamping.
    dis_frame = min(max(imresize(dis_frame, [size(ref_frame,1) size(ref_frame,2)], 'bicubic'),0),1);
    % Convert the frames to absolute units: use the inverse of PQ EOTF + add
    % reflected ambient light and clamp to the peak luminance
    L_max = 2000; % Peak luminance of the display
    dis_L = min( pq2lin(dis_frame) + L_refl, L_max + L_refl);
    ref_L = min( pq2lin(ref_frame) + L_refl, L_max + L_refl);

    res = hdrvdp3( 'quality', dis_L, ref_L, colorspace, ppd, { 'quiet', true } );
    Q_JOD_sum = Q_JOD_sum + res.Q_JOD;
    n = n+1;
end

Q_JOD = Q_JOD_sum/n;

fprintf( 1, "Video quaity: %g JODs\n", Q_JOD );

