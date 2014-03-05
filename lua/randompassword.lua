#!/usr/bin/env lua

local M = M or {}

-- Module local words table list
local words = {}

local pad_chars = { '+', '*', '%', '$', '#', '@', '!', '-', '=', '~' }

-- Loads a file of words (one per line)
function M.loadfile(file)
	file = file or "dict"
	local f = assert(io.open(file))
	for line in f:lines() do
		words[#words+1] = line
	end
	f:close()
end

-- Load each word from the table into the wordlist
function M.loadlist(list)
	for _,value in ipairs(list) do
		words[#words+1] = value
	end
end

-- Gets a random word from the dictionary file
-- Provide a (capitalized) word from the loaded word list
-- Relies on math.random so math.randomseed should be called prior to this
function M.randomword(capitalize)
	if #words == 0 then M.loadfile() end
	local word = words[math.random(#words)]:lower()

	if capitalize then
		word = word:sub(1, 1):upper() .. word:sub(2)
	end

	return word
end

-- pads the password to the max
local function pad_password(password, max)
	local len = password:len()
	for i=1, math.floor((max - len)/2) do
		password = pad_chars[math.random(#pad_chars)] .. password
	end
	for i=1, math.ceil((max - len)/2) do
		password = password .. pad_chars[math.random(#pad_chars)]
	end
	return password
end

-- Get a random word password
-- Options include:
-- words number (required)
-- min number [optional default:15]
-- max number [optional default:32]
-- capitalize boolean [optional default:true]
-- Relies on math.random so math.randomseed should be called prior to this
function M.randomwordpassword(options)
	options = options or {}
	options.words = math.random(2, options.words) or math.random(2, 10)
	options.min = options.min or 15
	options.max = options.max or 32

	local password = ""

	for x=1, options.words do
		password = password .. M.randomword(options.capitalize)
	end

	if password:len() > options.max or password:len() < options.min then
		return M.randomwordpassword(options)
	end

	if options.padding then
		return pad_password(password, options.max)
	else
		return password
	end
end

-- Tries to provide a good random seed.  It does this in one of two ways:
-- * If the socket library is loaded, it uses the socket.gettime function
-- * Otherwise it uses Lua's os.time added to the address of an anonymous
--   table (converted to a number)
function M.randomseed()
	if package.loaded["socket"] and package.loaded["socket"].gettime then
		math.randomseed(package.loaded["socket"].gettime()*1000000)
	else
		math.randomseed(os.time()+assert(tonumber(tostring({}):sub(7))))
	end
end

-- Prints out a new random password on each call
-- Side effects: sets a new random seed
-- Options include:
-- words number [optional default:3]
-- min number [optional default:15]
-- max number [optional default:32]
-- capitalize boolean [optional default:true]
function M.print(options)
	options = options or {}

	M.randomseed()

	if options.words then
		M.loadfile()
		print(M.randomwordpassword(options))
	else
		print("No random ascii passwords yet")
	end
end

local function help(filename)
	print(string.format([[
usage: %s [-h] [-words] <number of words> [-min min_length] [-max max_length] [-pad bool] [-capitalize bool]
defaults:
	3 words
	15 character minimum
	32 character maximum
	padding false
	capitalize true]], filename))
end

if _VERSION == "Lua 5.1" then _G.randompassword = M end

if arg and arg[0]:find("randompassword.lua") then
	local function tobool(arg)
		local t = type(arg)
		if t == "boolean" then
			return arg
		elseif t == "string" then
			if arg:lower() == "false" or tonumber(arg) == 0 then
				return false
			else
				return true
			end
		elseif t == "number" then
			return arg ~= 0
		end
		return nil, "Unable to determine a basic type"
	end

	local words = 1
	local min_length = 2
	local max_length = 3
	local padding = 4
	local capitalize = 5

	local opts = {{o= "-words", value=3}, {o="-min", value=15, number=true}, {o="-max", value=32, number=true}, {o="-pad", bool=true}, {o="-capitalize", value=true, bool=true}}

	local function parse_arguments(args)
		for i,arg in ipairs(args) do
			if arg == "-h" or arg == "--help" then
				help(args[0])
				os.exit()
			end
			for oi, t in ipairs(opts) do
				if arg == t.o and #args <= i+1 then
					if t.number then
						t.value = tonumber(args[i+1])
					elseif t.bool then
						t.value = tobool(args[i+1])
					else
						t.value = args[i+1]
					end
				end
			end
		end
	end

	-- Command line helper
	if #arg >= 1 then
		parse_arguments(arg)
	end

	M.print{words=opts[words].value, min=opts[min_length].value, max=opts[max_length].value, capitalize=opts[capitalize].value, padding=opts[padding].value}
end

return M
