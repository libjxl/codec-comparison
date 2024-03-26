function n = zeros_like_sz(sz, m)

if is_octave()
    n = zeros( sz, class(m) );
else
    n = zeros( sz, 'like', m );
end

end