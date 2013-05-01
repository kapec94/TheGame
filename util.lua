util = {}

local function iterate(fn, it)
	assert (fn)
	if it == nil then return end

	if type(it) == 'table' then
		for _,v in ipairs(it) do fn(v) end
	else
		for v in it do fn(v) end
	end
end

util.mmap = function (fn, t)
	iterate(fn, t)
end

util.select = function (fn, t)
	local ret = {}
	iterate(function (v)
		if fn(v) then table.insert(ret, v) end
	end, t)
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
