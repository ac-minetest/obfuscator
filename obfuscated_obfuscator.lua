local a = { ["for"] = true, ["else"] =true, ["if"] = true, ["then"] = true, ["not"] = true, ["end"] = true, ["in"] = true, ["return"] = true, ["or"] = true, ["and"] = true, ["local"] = true,["function"] = true,["string"] = true, ["break"]=true, ["elseif"] = true, ["false"] = true, ["nil"] = true, ["repeat"] = true, ["while"] = true, ["true"]=true, } local b = function(C) return C:gsub("%-%-%[%[.*%-%-%]%]",""):gsub("%-%-[^\n]*\n","\n") end local c = function(E) local d = 0; local e; local f; local g = string.len(E); local h = 0; local i = { {"'","'"}, {"\"","\""}, {"%[=*%[","%]=*%]"}, } local j = {} while d < g do d=d+1 local k = g+1; if h == 0 then for k=1,#i do e = string.find(E,i[k][1],d); if e and e<k then k = e h = k end end if h ~= 0 then e=k j[#j+1] = {k} end if not e then break end else f,e = string.find(E,i[h][2],d); if not e then break end if (h~=2 or (string.sub(E,e-1,e-1) ~= "\\") or string.sub(E,e-2,e-1) == "\\\\") then j[#j][2] = e h = 0 end end d=e end if h~= 0 then j[#j][2] = g end return j end local l = function(s,F) local m = 1; local n = #s; if n == 0 then return false end local o = n; while n>m+1 do o = math.floor((m+n)/2) if F<s[o][1] then n = o else m = o end end if F>s[m][2] then o = n else o = m end return s[o][1]<=F and F<=s[o][2] end local p = function(C, D, F, s) local g = string.len(C) local q = true; local d1 = F; while q do q = false local d2 = string.find(C,D,d1); if d2 then if not l(s,d2) then return d2 end q = true; d1 = d2+1; end end return nil end local r = function(C,A, B) local s = c(C); local d = 1; local g = string.len(C); local t = 0 while(d<=g) do local e1 = p(C,"[%a_]+",d, s) if e1 then local e2 = string.find(C,"[^%a_]",e1+1) or (g+1) local u = string.sub(C,e1,e2-1) d=e2+1 if not a[u] then if not A[u] and string.sub(C,e1-6,e1-2) == "local" then t=t+1;A[u] = t end end else break end end d=1 while(d<=g) do local e1 = p(C,"[%a_]+",d, s) if e1 then local e2 = string.find(C,"[^%a_]",e1+1) or (g+1) local u = string.sub(C,e1,e2-1) d=e2+1 if A[u] then B[#B+1] = {e1,e2,A[u]} end else break end end end local v = function(C,A,B) local d = 1; local z = {}; local w = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","z","w","x","y","z", "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","Z","W","X","Y","Z"} local x = {}; local e = 0 local y = #w; for f,__ in pairs(A) do e=e+1 if e<=y then x[e] = w[e] elseif e<=y^2 then x[e] = w[math.floor(e/y)] .. w[(e-1)%y+1] else print("error! count exceeded " .. y^2) end end for e = 1,#B do z[#z+1] = string.sub(C,d,B[e][1]-1)..x[B[e][3]] d=B[e][2] end z[#z+1] = string.sub(C,d,string.len(C)) return table.concat(z,"") end local z = function(C) C = b(C); C = string.gsub(C,"[\n\t ]+"," ") local A = {}; local B = {};r(C,A, B) return v(C,A,B) end

print(z([=[
local i; local n
local factors = function( n ) 
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

]=]))