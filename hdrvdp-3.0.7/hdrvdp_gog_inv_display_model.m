function V = hdrvdp_gog_inv_display_model( Y, Y_peak, contrast, gamma, E_ambient, k_refl )
% Gain-gamma-offset inverse display model to to convert linear color values
% into a values shown on a display
%
% V = hdrvdp_gog_inv_display_model( Y, Y_peak )
% V = hdrvdp_gog_inv_display_model( Y, Y_peak, contrast )
% V = hdrvdp_gog_inv_display_model( Y, Y_peak, contrast, gamma )
% V = hdrvdp_gog_inv_display_model( Y, Y_peak, contrast, gamma, E_ambient )
% V = hdrvdp_gog_inv_display_model( Y, Y_peak, contrast, gamma, E_ambient, k_refl )
%
% Transforms absolute linear colorimetric values emitted from a display into 
% gamma-correctec pixel values V, which are in the range 0-1.
% 
% Parameters (default value shown in []):  
% Y_peak - display peak luminance in cd/m^2 (nit), e.g. 200 for a typical
%          office monitor
% contrast - [1000] the contrast of the display. The value 1000 means
%          1000:1
% gamma - [2.2] gamma of the display. 
% E_ambient - [0] ambient light illuminance in lux, e.g. 600 for bright
%         office
% k_refl - [0.005] reflectivity of the display screen
% 
% For more details on the GOG display model, see:
% https://www.cl.cam.ac.uk/~rkm38/pdfs/mantiuk2016perceptual_display.pdf
%
% Copyright (c) 2010-2020, Rafal Mantiuk

% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are met:
%  * Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
%  * Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the  documentation
%    and/or other materials provided with the distribution.  
%  * Neither the name of the HDR-VDP nor the names of its contributors may be
%    used to endorse or promote products derived from this software without 
%    specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY 
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


if ~exist( 'contrast', 'var' ) || isempty( contrast )
    contrast = 1000;
end

if ~exist( 'gamma', 'var' ) || isempty( gamma )
    gamma = 2.2;
end

if ~exist( 'E_ambient', 'var' ) || isempty( E_ambient )
    E_ambient = 0;
end

if ~exist( 'k_refl', 'var' ) || isempty( k_refl )
    k_refl = 0.005;
end

Y_refl = E_ambient/pi*k_refl; % Reflected ambient light

Y_black = Y_refl + Y_peak/contrast;

V = max( 0, (Y - Y_black)/(Y_peak-Y_black) ).^(1/gamma);

end
