local load_time_start = os.clock()

-- copied from worldedit/worldedit/code.lua
--- Executes `code` as a Lua chunk in the global namespace.
-- @return An error message if the code fails, or nil on success.
local function run_lua_text(code)
	local func, err = loadstring(code)
	if not func then  -- Syntax error
		return err
	end
	local good, err = pcall(func)
	if not good then  -- Runtime error
		return err
	end
end

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
	local err = run_lua_text(text)
	if err then
		--[[ todo: put an eof to make it not become loaded again
		file = io.open(path, "w")
		file:write(""..text)
		io.close(file)--]]

		minetest.log("action", "[outgame_intervention] error executing file: "..err)
		return
	end

-- reset it
	file = io.open(path, "w")
	file:write("")
	io.close(file)

-- inform that it worked
	minetest.log("info", "[outgame_intervention] file successfully executed.")
	return true
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer+dtime
	if timer < step then
		return
	end
	timer = 0
	run_stuff()
end)

minetest.log("info", string.format("[outgame_intervention] loaded after ca. %.2fs", os.clock() - load_time_start))
