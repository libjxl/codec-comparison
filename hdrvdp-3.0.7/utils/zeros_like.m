function n = zeros_like(m)

if is_octave()
    n = zeros( size(m), class(m) );
else
    n = zeros( size(m), 'like', m );
end

end