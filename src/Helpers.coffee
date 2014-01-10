escape = require 'escape-regexp'

class Helpers


	@ASTERISK_PATTERN = '<[0-9a-zA-Z/.-_ ]+>'


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

		pattern = pattern.replace(/\*/g, Helpers.ASTERISK_PATTERN)
		parts = pattern.match(/<((?!(<|>)).)*>/g)
		if parts != null
			partsResult = {}
			for part, i in parts
				partsResult['__<<' + i + '>>__'] = part.replace(/^<(.*)>$/, '$1')
				pattern = pattern.replace(part, '__<<' + i + '>>__')

			pattern = escape(pattern)

			for replacement, part of partsResult
				pattern = pattern.replace(replacement, part)
		else
			pattern = escape(pattern)

		return pattern


module.exports = Helpers