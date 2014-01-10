Base = require './Base'
Helpers = require './Helpers'

moment = require 'moment'
compare = require 'operator-compare'

class Finder extends Base


	@TIME_FORMAT = 'YYYY-MM-DD HH:mm'


	#*******************************************************************************************************************
	#										CREATING INSTANCE
	#*******************************************************************************************************************


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


	#*******************************************************************************************************************
	#										FIND METHODS
	#*******************************************************************************************************************


	find: (mask = null, type = 'all') ->
		mask = Helpers.normalizePattern(mask)

		if @up is on or typeof @up in ['number', 'string']
			return @getPathsFromParentsSync(mask, type)
		else
			return @getPathsSync(type, mask)


	findFiles: (mask = null) ->
		return @find(mask, 'files')


	findDirectories: (mask = null) ->
		return @find(mask, 'directories')


	#*******************************************************************************************************************
	#										FILTERS
	#*******************************************************************************************************************


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


module.exports = Finder