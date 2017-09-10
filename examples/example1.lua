--  BEFORE: ---

local i,n
factors = function( n ) 
    local f = {}
	
    for i = 1, n/2 do -- here we try all the possible factors of n
        if n % i == 0 then -- here we check if n is divisible by i
            f[#f+1] = i -- we found factor, add it to the list
        end
    end
    f[#f+1] = n

    print("factors of " .. n .. " are : " .. table.concat(f,","))

end

factors(25)


-- AFTER : ---


v____ = function( v___ ) local v__ = {}  for v_ = 1, v___/2 do if v___ % v_ == 0 then v__[#v__+1] = v_ end end v__[#v__+1] = v___ print("factors of " .. v___ .. " are : " .. table.concat(v__,",")) end v____(25)