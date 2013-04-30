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

