-- LUA OBFUSCATOR by rnd
-- removes all newlines, tabs and unneded spaces
-- renames all local variables to short form

local reserved_words = {
  ["for"] = true, ["else"] =true, ["if"] = true, ["then"] = true, ["not"] = true, ["end"] = true, ["in"] = true,
  ["return"] = true, ["or"] = true, ["and"] = true, ["local"] = true,["function"] = true,["string"] = true,
  ["break"]=true, ["elseif"] = true, ["false"] = true, ["nil"] = true, ["repeat"] = true, ["while"] = true,
  ["true"]=true,
  }

local remove_comments = function(text)
    return text:gsub("%-%-%[%[.*%-%-%]%]",""):gsub("%-%-[^\n]*\n","\n")
end

local identify_strings = function(code) -- returns list of positions {start,end} of literal strings in lua code

	local i = 0; local j; local _; local length = string.len(code);
	local mode = 0; -- 0: not in string, 1: in '...' string, 2: in "..." string, 3. in [==[ ... ]==] string
	local modes = {
		{"'","'"}, -- inside ' '
		{"\"","\""}, -- inside " "
		{"%[=*%[","%]=*%]"}, -- inside [=[ ]=]
	}
	local ret = {}
	while i < length do
		i=i+1
	
		local jmin = length+1;
		if mode == 0 then -- not yet inside string
			for k=1,#modes do
				j = string.find(code,modes[k][1],i);
				if j and j<jmin then  -- pick closest one
					jmin = j
					mode = k
				end
			end
			if mode ~= 0 then -- found something
				j=jmin
				ret[#ret+1] = {jmin}
			end
			if not j then break end -- found nothing
		else
			_,j = string.find(code,modes[mode][2],i); -- search for closing pair
			if not j then break end
			if (mode~=2 or (string.sub(code,j-1,j-1) ~= "\\") or string.sub(code,j-2,j-1) == "\\\\") then -- not (" and not \" - but "\\" is allowed)
				ret[#ret][2] = j
				mode = 0
			end
		end
		i=j -- move to next position
	end
	if mode~= 0 then ret[#ret][2] = length end
	return ret
end

local is_inside_string = function(strings,pos) -- is position inside one of the strings?
	local low = 1; local high = #strings;
	if high == 0 then return false end
	local mid = high;
	while high>low+1 do
		mid = math.floor((low+high)/2)
		if pos<strings[mid][1] then high = mid else low = mid end
	end
	if pos>strings[low][2] then mid = high else mid = low end
	return strings[mid][1]<=pos and pos<=strings[mid][2]
end

local find_outside_string = function(text, pattern, pos, strings)
	local length = string.len(text)
	local found = true;
	local i1 = pos;
	while found do
		found = false
		local i2 = string.find(text,pattern,i1);
		if i2 then
			if not is_inside_string(strings,i2) then return i2 end
			found = true;
			i1 = i2+1;
		end
	end
	return nil
end

local extract_locals = function(text,locals, positions) 
  local strings = identify_strings(text);  
  local i = 1;
  local length = string.len(text);
  local idx = 0
  while(i<=length) do
    
    local j1 = find_outside_string(text,"[%a_]+",i, strings)
    
    if j1 then -- find locals (local variables)
        local j2 = string.find(text,"[^%a_]",j1+1) or (length+1)
        local word = string.sub(text,j1,j2-1)
        i=j2+1
        if not reserved_words[word] then
            if not locals[word] and string.sub(text,j1-6,j1-2) == "local" then -- not yet found as local and "local variable_name"
              idx=idx+1;locals[word] = idx -- found new local
            end
        end
    else
      break
    end
  end
  
  i=1
  while(i<=length) do -- find locals positions (all of them!)
    local j1 = find_outside_string(text,"[%a_]+",i, strings)
    
    if j1 then -- find locals (local variables)
        local j2 = string.find(text,"[^%a_]",j1+1) or (length+1)
        local word = string.sub(text,j1,j2-1)
        i=j2+1
        if locals[word] then
          positions[#positions+1] = {j1,j2,locals[word]} -- remember positions and local
        end
    else
      break
    end
  end
  
end

local rename_locals = function(text,locals,positions)
  local i = 1;
  local out = {};
  
  local chars = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","z","w","x","y","z",
                 "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","Z","W","X","Y","Z"}
  local names = {};
  local j = 0
  local n = #chars;
  for _,__ in pairs(locals) do  -- generate new local names
    j=j+1
    if j<=n then 
      names[j] = chars[j]
    elseif j<=n^2 then
      names[j] = chars[math.floor(j/n)] .. chars[(j-1)%n+1]
    else
      print("error! count exceeded " .. n^2) -- default 54^2=2916
    end
  end
  
  for j = 1,#positions do
    out[#out+1] = string.sub(text,i,positions[j][1]-1)..names[positions[j][3]]
    i=positions[j][2]
  end
  out[#out+1] = string.sub(text,i,string.len(text))
  return table.concat(out,"")
end

local obfuscate = function(text)
  text = remove_comments(text);
  text = string.gsub(text,"[\n\t ]+"," ") -- replace newlines, tabs and multiple spaces with space
  local locals = {}; local positions = {};extract_locals(text,locals, positions)
  --print(serialize(locals));print(serialize(positions))
  return rename_locals(text,locals,positions) -- this is final output
end

local text; local pattern; local code; local pos; local tab -- just so it gets obfuscated too when applied to itself

-- DEMO EXAMPLE

-- only variables that are local somewhere are obfuscated, like 'local variable_name'
-- possible issues: table = {x=1}; local x; res["x"]
--    here x will get renamed, but x in res["x"] not producing possible error, however res.x will be renamed correctly

text = [=[
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
]=]

--[[ 
  obfuscated version is:
  local a; local b local c = function( b ) local d = {} for a = 1, b/2 do if b % a == 0 then d[#d+1] = a end end d[#d+1] = b print("factors of " .. b .. " are : " .. table.concat(d,",")) end c(25) 
--]]

print(obfuscate(text)) -- print obfuscated version