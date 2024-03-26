classdef hdrvdp_lpyr < hdrvdp_multscale
% Laplacian pyramid
    
    properties
        P;
        
        ppd;
        base_ppd;
        img_sz;
        band_freqs;        
    end
    
    methods
        
%        function ms = hdrvdp_lpyr( )
%        end
        
        function ms = decompose( ms, I, ppd )
            
            ms.ppd = ppd;
            ms.img_sz = size(I);
            
            % We want the minimum frequency the band of 2cpd or higher
            height = max( ceil(log2(ppd))-2, 1 );
            
            % Frequency peaks of each band
            ms.band_freqs = [1 0.3228*2.^-(0:(height-1))] * ms.ppd/2;            
                        
            ms.P = laplacian_pyramid( I, height+1 );
        end
        
        function I = reconstruct( ms )
            I = zeros( size(ms.P{1}) );
            for kk=1:length(ms.P)
                I = I + ms.P{kk};
            end
        end
        
        function B = get_band( ms, band, o )
            B = ms.P{band};
        end
            
        function ms = set_band( ms, band, o, B )
            ms.P{band} = B;
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