fs = require 'fs'
_path = require 'path'
moment = require 'moment'

class Finder


	@ASTERISK_PATTERN = '[0-9a-zA-Z/.-_ ]+'

	@TIME_FORMAT = 'YYYY-MM-DD HH:mm'


	directory: null

	recursive: false

	excludes: []

	filters: []


	constructor: (directory) ->
		directory = _path.resolve(directory)
		@directory = directory


	recursively: (@recursive = true) ->
		return @


	exclude: (excludes) ->
		if typeof excludes == 'string' then excludes = [excludes]

		result = []
		for exclude in excludes
			result.push(exclude.replace(/\*/g, Finder.ASTERISK_PATTERN))

		@excludes = result
		return @


	size: (operation, value) ->
		@filter( (stat) ->
			return Finder.compare(stat.size, operation, value)
		)

		return @


	date: (operation, value) ->
		@filter( (stat) ->
			switch Object.prototype.toString.call(value)
				when '[object String]' then date = moment(value, Finder.TIME_FORMAT)
				when '[object Object]' then date = moment().subtract(value)
				else throw new Error 'Date format is not valid.'

			return Finder.compare((new Date(stat.mtime)).getTime(), operation, date.valueOf())
		)

		return @


	filter: (fn) ->
		@filters.push(fn)
		return @


	getPaths: (dir, type = 'all', mask = null) ->
		if mask != null then mask = mask.replace(/\*/g, Finder.ASTERISK_PATTERN)
		paths = []

		for path in fs.readdirSync(dir)
			path = dir + '/' + path

			ok = true
			for exclude in @excludes
				if (new RegExp(exclude)).test(path)
					ok = false
					break

			if ok == false then continue

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


	find: (mask = null, type = 'all') ->
		return @getPaths(@directory, type, mask)


	findFiles: (mask = null) ->
		return @find(mask, 'files')


	findDirectories: (mask = null) ->
		return @find(mask, 'directories')


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

			mask = mask.replace(/<|>/g, '')
			path = path.replace(/<|>/g, '')

		return {
			directory: path
			mask: mask
		}


	@compare: (l, operator, r) ->
		switch operator
			when '>' then return l > r
			when '>=' then return l >= r
			when '<' then return l < r
			when '<=' then return l <= r
			when '=', '==' then return l == r
			when '!', '!=', '<>' then return l != r
			else throw new Error 'Unknown operator ' + operator + '.'


module.exports = Finder