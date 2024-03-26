function var = hdrvdp_get_from_cache( name, key, func )
% Keep look-up tables in a cache for faster repeated execution
%
% var = hdrvdp_get_from_cache( name, key, func )
%
% name - string that identifies cache entry
% key - vector with numbers that concisely describe cache state. If the key
%       is different from the one stored, cache entry will be recomputed.
% func - a handle to a function that computes cache entry

persistent hdrvdp_cache;

if( ~isfield( hdrvdp_cache, name ) || any(hdrvdp_cache.(name).key ~= key) )
    % Cache does not exist or needs updating

    hdrvdp_cache.(name) = struct();
    hdrvdp_cache.(name).key = key;
    var = func();
    hdrvdp_cache.(name).var = var;    
else
    % Data can be fetched from the cache
    var = hdrvdp_cache.(name).var;
end

end
