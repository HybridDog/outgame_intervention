local load_time_start = minetest.get_us_time()


-- path of the file
local path = minetest.get_worldpath().."/tmp.lua"

-- the file becomes checked every <step> seconds
local step = 4


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

local function run_stuff()
-- search file
	local file = io.open(path, "r")
	if not file then
		return
	end

-- test if it contains something
	if file:seek("end") == 0 then
		file:close()
		return
	end

-- get the text
	file:seek("set")
	local text = file:read("*all")
	file:close()

-- reset it
	file = io.open(path, "w")
	file:write("")
	file:close()

-- run it
	local err = run_lua_text(text)
	if err then
		minetest.log("action", "[outgame_intervention] error executing file: "..err)
		return
	end

-- inform that it worked
	minetest.log("info", "[outgame_intervention] file successfully executed.")
	return true
end

local function do_step()
	run_stuff()
	minetest.after(step, do_step)
end
minetest.after(step, do_step)


local time = (minetest.get_us_time() - load_time_start) / 1000000
local msg = "[outgame_intervention] loaded after ca. " .. time .. " seconds."
if time > 0.01 then
	print(msg)
else
	minetest.log("info", msg)
end
