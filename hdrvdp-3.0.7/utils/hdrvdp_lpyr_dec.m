classdef hdrvdp_lpyr_dec < hdrvdp_multscale
    % Decimated laplacian pyramid
    
    properties
        P;
        P_gauss;
        
        ppd;
        base_ppd;
        img_sz;
        band_freqs;
        height;
        do_gauss = false;
        min_freq = 0.5;
    end
    
    methods
        
        function ms = decompose( ms, I, ppd )
            
            ms.ppd = ppd;
            ms.img_sz = size(I);
            
            % The maximum number of levels we can have
            max_levels = floor(log2(min(size(I,1),size(I,2))))-1;
            
            % We want the minimum frequency the band to be min_freq
            max_band = find( [1 0.3228*2.^-(0:14)] * ms.ppd/2 <= ms.min_freq, 1 );
            if isempty(max_band)
                max_band=max_levels;
            end
            
            ms.height = clamp( max_band, 1, max_levels );
            
            % Frequency peaks of each band
            ms.band_freqs = [1 0.3228*2.^-(0:(ms.height-1))] * ms.ppd/2;
                            
            if ms.do_gauss
                [ms.P, ms.P_gauss] = laplacian_pyramid_dec( I, ms.height+1 );
            else
                ms.P = laplacian_pyramid_dec( I, ms.height+1 );
            end
        end
        
        function I = reconstruct( ms )
            
            I = ms.P{end};
            for i=(length(ms.P)-1):-1:1
                I = gausspyr_expand( I, [size(ms.P{i},1) size(ms.P{i},2)] );
                I = I + ms.P{i};
            end
            
        end
        
        function B = get_band( ms, band, o )
            
            if band == 1 || band == length(ms.P)
                band_mult = 1;
            else
                band_mult = 2;
            end
            
            B = ms.P{band} * band_mult;
        end

        function B = get_gauss_band( ms, band, o )
            
            if ~ms.do_gauss
                error( 'do_gauss property needs to be set to true' );
            end
                        
            B = ms.P_gauss{band};
        end
        
        function ms = set_band( ms, band, o, B )
            
            if band == 1 || band == length(ms.P)
                band_mult = 1;
            else
                band_mult = 2;
            end
            
            ms.P{band} = B/band_mult;
        end
        
        function bc = band_count( ms )
            bc = length(ms.P);
        end
        
        function oc = orient_count( ms, band )
            oc = 1;
        end
        
        function sz = band_size( ms, band, o )
            sz = size( ms.P{band} );
        end
        
        function bf = get_freqs( ms )
            bf = ms.band_freqs;
        end
        
    end
    
end