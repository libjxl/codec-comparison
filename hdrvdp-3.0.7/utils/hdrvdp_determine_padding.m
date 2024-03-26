function pad_value = hdrvdp_determine_padding( reference, metric_par )

if ischar( metric_par.surround )
    switch metric_par.surround
        case 'none'
            pad_value = 'symmetric';
        case 'mean'
            pad_value = geomean( reshape( reference, [size(reference,1)*size(reference,2) size(reference,3)] ) );
        otherwise
            error( 'Unrecognized "surround" setting' );
    end
else
    if( length(metric_par.surround) == 1 )
        pad_value = repmat( metric_par.surround, [1 size(reference,3)] );
    elseif( length(metric_par.surround) == size(reference,3) )
        metric_par.pad_value = metric_par.surround;
    else
        error( 'The length of the "surround" vector should be 1 or equal to the number of channels' );
    end
end

end