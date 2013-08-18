fs = require 'fs'
_path = require 'path'
moment = require 'moment'
compare = require 'operator-compare'

class Finder


	@ASTERISK_PATTERN = '<[0-9a-zA-Z/.-_ ]+>'

	@ESCAPE_PATTERN = ['.', '[', ']', '\\', '^', '$', '|', '?', '+', '(', ')', '{', '}']

	@TIME_FORMAT = 'YYYY-MM-DD HH:mm'


	directory: null

	recursive: false

	excludes: []

	filters: []

	systemFiles: false

	up: false


	constructor: (directory) ->
		directory = _path.resolve(directory)
		if !fs.statSync(directory).isDirectory()
			throw new Error "Path #{directory} is not directory"

		@directory = directory


	recursively: (@recursive = true) ->
		return @


	exclude: (excludes) ->
		if typeof excludes == 'string' then excludes = [excludes]

		result = []
		for exclude in excludes
			result.push(Finder.normalizePattern(exclude))

		@excludes = @excludes.concat(result)
		return @


	size: (operation, value) ->
		@filter( (stat) ->
			return compare(stat.size, operation, value)
		)

		return @


	date: (operation, value) ->
		@filter( (stat) ->
			switch Object.prototype.toString.call(value)
				when '[object String]' then date = moment(value, Finder.TIME_FORMAT)
				when '[object Object]' then date = moment().subtract(value)
				else throw new Error 'Date format is not valid.'

			return compare((new Date(stat.mtime)).getTime(), operation, date.valueOf())
		)

		return @


	showSystemFiles: (@systemFiles = true) ->
		return @


	lookUp: (@up = true) ->
		return @


	filter: (fn) ->
		@filters.push(fn)
		return @


	getPaths: (dir, type = 'all', mask = null) ->
		paths = []

		for path in fs.readdirSync(dir)
			path = dir + '/' + path

			ok = true
			for exclude in @excludes
				if (new RegExp(exclude)).test(path)
					ok = false
					break

			if ok == false then continue

			if @systemFiles == false
				if _path.basename(path)[0] == '.' then continue
				if path.match(/~$/) != null then continue

			stat = fs.statSync(path)

			if type == 'all' || (type == 'files' && stat.isFile()) || (type == 'directories' && stat.isDirectory())
				if mask == null || (mask != null && (new RegExp(mask, 'g')).test(path))
					ok = true
					for filter in @filters
						if !filter(stat, path)
							ok = false
							break

					if ok == false then continue

					paths.push(path)

			if stat.isDirectory() && @recursive == true
				paths = paths.concat(@getPaths(path, type, mask))

		return paths


	getPathsFromParents: (mask = null, type = 'all') ->
		directory = @directory
		depth = if @up == true then directory.match(/\//g).length else @up - 1
		paths = @getPaths(directory, type, mask)
		@exclude(directory)

		for i in [0..depth - 1]
			directory = _path.dirname(directory)
			paths = paths.concat(@getPaths(directory, type, mask))
			@exclude(directory)

		return paths


	find: (mask = null, type = 'all') ->
		mask = Finder.normalizePattern(mask)

		if @up is on or typeof @up == 'number'
			return @getPathsFromParents(mask, type)
		else
			return @getPaths(@directory, type, mask)


	findFiles: (mask = null) ->
		return @find(mask, 'files')


	findDirectories: (mask = null) ->
		return @find(mask, 'directories')


	@in: (path) ->
		return new Finder(path)


	@from: (path) ->
		return (new Finder(path)).recursively()


	@find: (path, type = 'all') ->
		path = @parseDirectory(path)
		return (new Finder(path.directory)).recursively().find(path.mask, type)


	@findFiles: (path) ->
		return Finder.find(path, 'files')


	@findDirectories: (path) ->
		return Finder.find(path, 'directories')


	@parseDirectory: (path) ->
		mask = null
		asterisk = path.indexOf('*')
		regexp = path.indexOf('<')

		if asterisk != -1 || regexp != -1
			if asterisk == -1 || (asterisk != -1 && regexp != -1 && asterisk > regexp)
				splitter = regexp
			else if regexp == -1 || (regexp != -1 && asterisk != -1 && asterisk <= regexp)
				splitter = asterisk

			mask = path.substr(splitter)
			path = path.substr(0, splitter)

		return {
			directory: path
			mask: mask
		}


	@normalizePattern: (pattern) ->
		if pattern == null
			return null

		if pattern == '*'
			return null

		pattern = pattern.replace(/\*/g, Finder.ASTERISK_PATTERN)
		parts = pattern.match(/<((?!(<|>)).)*>/g)
		if parts != null
			partsResult = {}
			for part, i in parts
				partsResult['::' + i + '::'] = part.replace(/^<(.*)>$/, '$1')
				pattern = pattern.replace(part, '::' + i + '::')

			pattern = Finder.escapeForRegex(pattern)

			for replacement, part of partsResult
				pattern = pattern.replace(replacement, part)
		else
			pattern = Finder.escapeForRegex(pattern)

		return pattern


	@escapeForRegex: (text) ->
		replace = []
		replace.push('\\' + char) for char in Finder.ESCAPE_PATTERN

		return text.replace(new RegExp('(' + replace.join('|') + ')', 'g'), '\\$1')


module.exports = Finder