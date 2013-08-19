should = require 'should'
path = require 'path'
fs = require 'fs'

dir = path.resolve './data'

Finder = require '../lib/Finder'

describe 'Finder', ->

	describe 'base', ->

		it 'should throw an error if path is not directory', ->
			( -> new Finder("#{dir}/two") ).should.throw()

	describe '#findFiles()', ->

		it 'should return file names from root folder', ->
			Finder.in(dir).findFiles().should.eql([
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])

	describe '#findDirectories()', ->

		it 'should return directory names from root folder', ->
			Finder.in(dir).findDirectories().should.eql([
				"#{dir}/eight"
				"#{dir}/seven"
				"#{dir}/six"
			])

	describe '#find()', ->

		it 'should return file and directory names from root folder', ->
			Finder.in(dir).find().should.eql([
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

	describe '#findFirst()', ->

		it 'should return file path', ->
			Finder.in(dir).findFirst().findFiles().should.be.equal("#{dir}/0")

		it 'should return null', ->
			should.not.exists(Finder.in(dir).findFirst().findFiles('randomName'))

		it 'should return file path for first name with two numbers in name', ->
			Finder.from(dir).findFirst().findFiles('<[0-9]{2}>').should.be.equal("#{dir}/seven/13")

		it 'should return null for recursive searching', ->
			should.not.exists(Finder.from(dir).findFirst().findFiles('randomName'))

		it 'should return first path to directory', ->
			Finder.from(dir).findFirst().findDirectories('4').should.be.equal("#{dir}/eight/3/4")

		it 'should return null when looking into parents', ->
			should.not.exists(Finder.in("#{dir}/eight/3/4").lookUp(4).findFirst().findFiles('twelve'))

		it 'should return first file when looking into parents recursively', ->
			Finder.from("#{dir}/eight/3/4").lookUp(4).findFirst().findFiles('twelve').should.equal("#{dir}/seven/twelve")

	describe '#recursive()', ->

		it 'should return file names recursively from find* methods', ->
			Finder.from(dir).findFiles().should.eql([
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

	describe '#exclude()', ->

		it 'should return files which has not got numbers in name', ->
			Finder.in(dir).exclude(['<[0-9]>']).findFiles().should.eql([
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])

	describe '#showSystemFiles()', ->

		it 'should return also system, hide and temp files', ->
			Finder.in(dir).showSystemFiles().findFiles().should.eql([
				"#{dir}/.cache"
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/five"
				"#{dir}/five~"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])

	describe '#lookUp()', ->

		it 'should return path to file in parent directory', ->
			Finder.in("#{dir}/eight/3/4").lookUp(4).showSystemFiles().findFiles('._.js').should.be.eql([
				"#{dir}/eight/._.js"
			])

		it 'should return path to file in parent directory recursively', ->
			Finder.from("#{dir}/eight/3/4").lookUp(4).findFiles('twelve').should.be.eql([
				"#{dir}/seven/twelve"
			])

	describe 'filters', ->

		describe '#size()', ->

			it 'should return files with size between 2000B and 3000B', ->
				Finder.in(dir).size('>=', 2000).size('<=', 3000).findFiles().should.eql([
					"#{dir}/five"
				])

		describe '#date()', ->

			it 'should return files which were changed in less than 1 minute ago', ->
				fs.writeFileSync("#{dir}/two", 'just some changes')
				Finder.in(dir).date('>', minutes: 1).findFiles().should.eql([
					"#{dir}/two"
				])

		describe '#filter()', ->

			it 'should return files which names are 3 chars length', ->
				filter = (stat, file) ->
					name = path.basename file, path.extname(file)
					return name.length == 3
				Finder.in(dir).filter(filter).findFiles().should.eql([
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