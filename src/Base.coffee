Helpers = require './Helpers'

path = require 'path'
fs = require 'fs'

class Base


	directory: null

	recursive: false

	excludes: null

	filters: null

	systemFiles: false

	up: false

	findFirst: false

	sync: false


	constructor: (directory) ->
		directory = path.resolve(directory)
		if !fs.statSync(directory).isDirectory()
			throw new Error "Path #{directory} is not directory"

		@directory = directory
		@excludes = []
		@filters = []


	#*******************************************************************************************************************
	#										TESTING
	#*******************************************************************************************************************


	@mock: (tree = {}, info = {}) ->
		FS = require 'fs-mock'
		fs = new FS(tree, info)
		return fs


	@restore: ->
		fs = require 'fs'


	#*******************************************************************************************************************
	#										SETUP
	#*******************************************************************************************************************


	sync: ->
		@sync = true


	async: ->
		@sync = false


	recursively: (@recursive = true) ->
		return @


	exclude: (excludes) ->
		if typeof excludes == 'string' then excludes = [excludes]

		result = []
		for exclude in excludes
			result.push(Helpers.normalizePattern(exclude))

		@excludes = @excludes.concat(result)
		return @


	showSystemFiles: (@systemFiles = true) ->
		return @


	lookUp: (@up = true) ->
		return @


	findFirst: (@findFirst = true) ->
		return @


	filter: (fn) ->
		@filters.push(fn)
		return @


	#*******************************************************************************************************************
	#										SEARCHING
	#*******************************************************************************************************************


	getPathsSync: (type = 'all', mask = null, dir = @directory) ->
		paths = []

		try
			read = fs.readdirSync(dir)
		catch err
			throw err
			return if @findFirst is on then null else paths

		for _path in read
			_path = path.join(dir, _path)

			ok = true
			for exclude in @excludes
				if (new RegExp(exclude)).test(_path)
					ok = false
					break

			if ok == false then continue

			if @systemFiles == false
				if path.basename(_path)[0] == '.' then continue
				if _path.match(/~$/) != null then continue

			try
				stat = fs.statSync(_path)
			catch err
				continue

			if type == 'all' || (type == 'files' && stat.isFile()) || (type == 'directories' && stat.isDirectory())
				if mask == null || (mask != null && (new RegExp(mask, 'g')).test(_path))
					ok = true
					for filter in @filters
						if !filter(stat, _path)
							ok = false
							break

					if ok == false then continue

					return _path if @findFirst is on
					paths.push(_path)

			if stat.isDirectory() && @recursive == true
				result = @getPathsSync(type, mask, _path)
				if @findFirst is on && typeof result == 'string'
					return result
				else if @findFirst is on && result == null
					continue
				else
					paths = paths.concat(result)

		return if @findFirst is on then null else paths


	#*******************************************************************************************************************
	#										PARENTS
	#*******************************************************************************************************************


	getPathsFromParentsSync: (mask = null, type = 'all') ->
		directory = @directory
		paths = @getPathsSync(type, mask, directory)

		if @findFirst is on && typeof paths == 'string'
			return paths

		@exclude(directory)

		if @up == true
			depth = directory.match(/\//g).length
		else if typeof @up == 'string'
			if @up == directory
				return if @findFirst is on then null else paths

			match = path.relative(@up, directory).match(/\//g)
			depth = if match == null then 2 else match.length + 2
		else
			depth = @up - 1

		for i in [0..depth - 1]
			directory = path.dirname(directory)
			result = @getPathsSync(type, mask, directory)

			if @findFirst is on && typeof result == 'string'
				return result
			else if @findFirst is on && result == null
				# continue
			else
				paths = paths.concat(result)

			@exclude(directory)

		return if @findFirst is on then null else paths


module.exports = Base