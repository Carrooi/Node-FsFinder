should = require 'should'
path = require 'path'
fs = require 'fs'

dir = path.resolve './data'

Finder = require '../lib/Finder'
finder = new Finder(dir)

describe 'Finder', ->

	describe '#findFiles()', ->

		it 'should return file names from root folder', ->
			finder.findFiles().should.eql([
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])

	describe '#findDirectories()', ->

		it 'should return directory names from root folder', ->
			finder.findDirectories().should.eql([
				"#{dir}/eight"
				"#{dir}/seven"
				"#{dir}/six"
			])

	describe '#find()', ->

		it 'should return file and directory names from root folder', ->
			finder.find().should.eql([
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/eight"
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/seven"
				"#{dir}/six"
				"#{dir}/three"
				"#{dir}/two"
			])

	describe '#recursive()', ->

		it 'should return file names recursively from find* methods', ->
			finder.recursively true
			finder.findFiles().should.eql([
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/eight/3/4/file.json"
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/seven/13"
				"#{dir}/seven/14"
				"#{dir}/seven/twelve"
				"#{dir}/six/eleven"
				"#{dir}/six/nine"
				"#{dir}/six/ten"
				"#{dir}/three"
				"#{dir}/two"
			])
			finder.recursively false

	describe '#exclude()', ->

		it 'should return files which has not got numbers in name', ->
			finder.exclude ['<[0-9]>']
			finder.findFiles().should.eql([
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])
			finder.excludes = []

	describe '#showSystemFiles()', ->

		it 'should return also system, hide and temp files', ->
			finder.showSystemFiles true
			finder.findFiles().should.eql([
				"#{dir}/.cache"
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/five"
				"#{dir}/five~"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])
			finder.showSystemFiles false

	describe 'filters', ->

		afterEach ->
			finder.filters = []

		describe '#size()', ->

			it 'should return files with size between 2000B and 3000B', ->
				finder.size('>=', 2000).size('<=', 3000)
				finder.findFiles().should.eql([
					"#{dir}/five"
				])

		describe '#date()', ->

			it 'should return files which were changed in less than 1 minute ago', ->
				fs.writeFileSync("#{dir}/two", 'just some changes')
				finder.date '>', minutes: 1
				finder.findFiles().should.eql([
					"#{dir}/two"
				])

		describe '#filter()', ->

			it 'should return files which names are 3 chars length', ->
				finder.filter (stat, file) ->
					name = path.basename file, path.extname(file)
					return name.length == 3
				finder.findFiles().should.eql([
					"#{dir}/one"
					"#{dir}/two"
				])

	describe 'utils', ->

		describe '#parseDirectory()', ->

			it 'should return object with directory and mask from path to find* methods', ->
				Finder.parseDirectory("#{dir}/one").should.eql(
					directory: "#{dir}/one"
					mask: null
				)

				Finder.parseDirectory("#{dir}<(five|three)*>").should.eql(
					directory: dir
					mask: '<(five|three)*>'
				)

				Finder.parseDirectory("#{dir}*<e$>").should.eql(
					directory: dir
					mask: '*<e$>'
				)

		describe '#escapeForRegex()', ->

			it 'should return escaped string for using it in regexp', ->
				Finder.escapeForRegex('.h[]e()l+|l?^o$').should.be.equal '\\.h\\[\\]e\\(\\)l\\+\\|l\\?\\^o\\$'

		describe '#normalizePattern()', ->

			it 'should return proper regular expression from path parameter', ->
				Finder.normalizePattern("#{dir}/.temp/<(one|two)>*<$>").should.be.equal "#{dir}/\\.temp/(one|two)[0-9a-zA-Z/.-_ ]+$"