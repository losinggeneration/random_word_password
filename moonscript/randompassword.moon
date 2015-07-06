#!/usr/bin/env moon

export ^

class RandomPassword
	new: (options = {dict: "dict", words: 3, min: 15, max: 32, capitalize: true, pad: false}) =>
		@word_list = {}
		@dict = options.dict or "dict"
		@words = options.words or 3
		@min = options.min or 15
		@max = options.max or 25
		@capitalize = options.capitalize or true
		@pad = options.pad or false
		@numeric = options.numeric or false
		@alpha = options.alpha or false
		@alpha_num = options.alpha_num or false
		@pad_chars = { '+', '*', '%', '$', '#', '@', '!', '-', '=', '~' }

	-- Loads a file of words (one per line)
	load_file: => for line in io.lines(@dict) do @word_list[#@word_list+1] = line
	-- Load each word from the table into the wordlist
	load_list: (list) => @word_list = {item for item in *list}

	-- Gets a random word from the dictionary file
	-- Provide a (capitalized) word from the loaded word list
	-- Relies on math.random so math.randomseed should be called prior to this
	random_word: =>
		@load_file! if #@word_list == 0
		word = @word_list[math.random #@word_list]\lower!

		if @capitalize then
			word = word\sub(1, 1)\upper! .. word\sub 2

		word

	-- Get a random word password
	-- Relies on math.random so math.randomseed should be called prior to this
	random_word_password: =>
		words = math.random(2, @words) or math.random 2, 10

		password = ""
		for x=1, words do password ..= @random_word!

		if password\len! > @max or password\len! < @min then
			return @random_word_password!

		@pad_password password


	number: =>
		string.char math.random(48, 57)

	cap_letter: =>
		string.char math.random(65, 90)

	letter: =>
		math.random(0, 1) == 1 and @cap_letter! or string.lower(@cap_letter!)

	alpha_numeric: =>
		math.random(0, 1) == 1 and @letter! or @number!

	random_char: =>
		if @numeric
			@number!
		elseif @alpha
			@letter!
		elseif @alpha_num
			@alpha_numeric!
		else
			string.char math.random(33, 126)

	random_password: =>
		p = ""
		p ..= @random_char! for i=1, @max
		p

	-- Tries to provide a good random seed.  It does this in one of two ways:
	-- * If the socket library is loaded, it uses the socket.gettime function
	-- * Otherwise it uses Lua's os.time added to the address of an anonymous
	--   table (converted to a number)
	random_seed: =>
		if package.loaded["socket"] and package.loaded["socket"].gettime then
			math.randomseed package.loaded["socket"].gettime()*1000000
		else
			math.randomseed os.time()+assert tonumber tostring({})\sub 7

	-- pads the password to the @max
	pad_password: (password) =>
		return password if @pad == false
		len = password\len!
		for i=1, math.floor (@max - len)/2 do
			password = @pad_chars[math.random #@pad_chars] .. password
		for i=1, math.ceil (@max - len)/2 do
			password = password .. @pad_chars[math.random #@pad_chars]
		password

	-- Prints out a new random password on each call
	-- Side effects: sets a new random seed
	print: =>
		@random_seed!

		if @words > 0 then
			@load_file!
			print @random_word_password!
		else
			print @random_password!

-- Everything after this is related to command line arguments handling
-- this allows the script to be run as-is
if arg and arg[0]\find "randompassword" then
	help = (filename) ->
		r = RandomPassword!
		print string.format [[
usage: %s [-help|-h] [-words] <number of words> [-min min_length] [-max max_length] [-pad bool] [-capitalize bool]
defaults:
        %d words
        %d character minimum
        %d character maximum
]], filename, r.words, r.min, r.max

	tobool = (o) ->
		t = type(o)
		if t == "boolean" then
			return o
		elseif t == "string" then
			if o\lower! == "false" or tonumber(o) == 0 then
				return false
			else
				return true
		elseif t == "number" then
			return o != 0

		nil, "Unable to determine a basic type"

	rp = RandomPassword!
	parse_args = (args) ->
		for i, arg in ipairs arg do
			a = arg\gsub "-+", "" -- remove begining dashes from the argument
			if a == "h" or a == "help" then
				help args[0]
				os.exit!

			if #args >= i+1 then
				switch a
					when "words"
						rp.words = tonumber(args[i+1])
					when "dict"
						rp.dict = tostring(args[i+1])
					when "min"
						rp.min = tonumber(args[i+1])
					when "max"
						rp.max = tonumber(args[i+1])
					when "pad"
						rp.pad = tobool(args[i+1])
					when "capitalize"
						rp.capitalize = tobool(args[i+1])
					when "numeric"
						rp.numeric = true
						rp.words = 0
					when "alpha_numeric", "alpha_num"
						rp.alpha_num = true
						rp.words = 0
					when "alpha"
						rp.alpha = true
						rp.words = 0
			else
				switch a
					when "pad"
						rp.pad = true
					when "capitalize"
						rp.capitalize = true
					when "numeric"
						rp.numeric = true
						rp.words = 0
					when "alpha_numeric", "alpha_num"
						rp.alpha_num = true
						rp.words = 0
					when "alpha"
						rp.alpha = true
						rp.words = 0

	parse_args arg if #arg >= 1

	rp\print!
