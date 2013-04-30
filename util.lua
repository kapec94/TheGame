util = {}

util.imap = function (fn, t)
	for _, v in ipairs(t) do
		fn(v)
	end
end

util.select = function (fn, t)
	local ret = {}
	for _, v in ipairs(t) do
		if fn(v) then table.insert(ret, v) end
	end
	return ret
end

util.rep = function (elem, n)
	local ret = {}
	for i=1,n do table.insert(ret, table.deepcopy(elem)) end
	return ret
end

local function deepcopy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end

	local no
	if type(o) == 'table' then
		no = {}
		seen[o] = no

		for k, v in next, o, nil do
			no[deepcopy(k, seen)] = deepcopy(v, seen)
		end
		setmetatable(no, deepcopy(getmetatable(o), seen))
	else -- number, string, boolean, etc
		no = o
	end
	return no
end

function table.deepcopy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end


	local no = {}
	seen[o] = no
	setmetatable(no, deepcopy(getmetatable(o), seen))

	for k, v in next, o, nil do
		k = (type(k) == 'table') and k:deepcopy(seen) or k
		v = (type(v) == 'table') and v:deepcopy(seen) or v
		no[k] = v
	end
	return no
end
