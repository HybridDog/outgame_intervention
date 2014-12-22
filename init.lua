local load_time_start = os.clock()

-- path of the file
local path = minetest.get_worldpath().."/tmp.lua"

-- the file becomes checked every <step> seconds
local step = 1

local function run_stuff()
-- search file
	local file = io.open(path, "r")
	if not file then
		return
	end

-- test if it contains something
	local text = file:read("*all")
	io.close(file)
	if text == "" then
		return
	end

-- run it
	dofile(path)

-- reset it
	file = io.open(path, "w")
	file:write("")
	io.close(file)

-- inform that it worked
	minetest.log("info", "[outgame_intervention] file executed.")
	return true
end

local timer = 0
local step = 1
minetest.register_globalstep(function(dtime)
	timer = timer+dtime
	if timer < step then
		return
	end
	timer = 0
	run_stuff()
end)

minetest.log("info", string.format("[outgame_intervention] loaded after ca. %.2fs", os.clock() - load_time_start))
