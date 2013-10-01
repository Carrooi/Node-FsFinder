expect = require('chai').expect
path = require 'path'
fs = require 'fs'

Finder = require '../../lib/Finder'

dir = path.resolve(__dirname + '/../data')

describe 'Finder', ->

	describe 'base', ->

		it 'should throw an error if path is not directory', ->
			expect( -> new Finder("#{dir}/two") ).to.throw(Error)

	describe '#findFiles()', ->

		it 'should return file names from root folder', ->
			expect(Finder.in(dir).findFiles()).to.be.eql([
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])

	describe '#findDirectories()', ->

		it 'should return directory names from root folder', ->
			expect(Finder.in(dir).findDirectories()).to.be.eql([
				"#{dir}/eight"
				"#{dir}/seven"
				"#{dir}/six"
			])

	describe '#find()', ->

		it 'should return file and directory names from root folder', ->
			expect(Finder.in(dir).find()).to.be.eql([
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
			expect(Finder.in(dir).findFirst().findFiles()).to.be.equal("#{dir}/0")

		it 'should return null', ->
			expect(Finder.in(dir).findFirst().findFiles('randomName')).to.be.null

		it 'should return file path for first name with two numbers in name', ->
			expect(Finder.from(dir).findFirst().findFiles('<[0-9]{2}>')).to.be.equal("#{dir}/seven/13")

		it 'should return null for recursive searching', ->
			expect(Finder.from(dir).findFirst().findFiles('randomName')).to.be.null

		it 'should return first path to directory', ->
			expect(Finder.from(dir).findFirst().findDirectories('4')).to.be.equal("#{dir}/eight/3/4")

		it 'should return null when looking into parents', ->
			expect(Finder.in("#{dir}/eight/3/4").lookUp(4).findFirst().findFiles('twelve')).to.be.null

		it 'should return first file when looking into parents recursively', ->
			expect(Finder.from("#{dir}/eight/3/4").lookUp(4).findFirst().findFiles('twelve')).to.equal("#{dir}/seven/twelve")

	describe '#recursive()', ->

		it 'should return file names recursively from find* methods', ->
			expect(Finder.from(dir).findFiles()).to.be.eql([
				"#{dir}/0"
				"#{dir}/1"
				"#{dir}/eight/3/4/file.json"
				"#{dir}/eight/other.js"
				"#{dir}/eight/package.json"
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
			expect(Finder.in(dir).exclude(['<[0-9]>']).findFiles()).to.be.eql([
				"#{dir}/five"
				"#{dir}/one"
				"#{dir}/three"
				"#{dir}/two"
			])

	describe '#showSystemFiles()', ->

		it 'should return also system, hide and temp files', ->
			expect(Finder.in(dir).showSystemFiles().findFiles()).to.be.eql([
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
			expect(Finder.in("#{dir}/eight/3/4").lookUp(4).showSystemFiles().findFiles('._.js')).to.be.eql([
				"#{dir}/eight/._.js"
			])

		it 'should return first file in parent directorz with depth set by string', ->
			expect(Finder.in("#{dir}/eight").lookUp(dir).findFiles('package.json')).to.be.eql([
				"#{dir}/eight/package.json"
			])

		it 'should return null when limit parent is the same like searched directory and file is not there', ->
			expect(Finder.in(dir).lookUp(dir).findFiles('package.json')).to.be.eql([])

		it 'should return path to file in parent directory recursively', ->
			expect(Finder.from("#{dir}/eight/3/4").lookUp(4).findFiles('twelve')).to.be.eql([
				"#{dir}/seven/twelve"
			])

		it 'should return first file in parent directories with depth set by string', ->
			expect(Finder.from("#{dir}/eight/3/4").lookUp(dir).findFiles('twelve')).to.be.eql([
				"#{dir}/seven/twelve"
			])

	describe 'filters', ->

		describe '#size()', ->

			it 'should return files with size between 2000B and 3000B', ->
				expect(Finder.in(dir).size('>=', 2000).size('<=', 3000).findFiles()).to.be.eql([
					"#{dir}/five"
				])

		describe '#date()', ->

			it 'should return files which were changed in less than 1 minute ago', ->
				fs.writeFileSync("#{dir}/two", 'just some changes')
				expect(Finder.in(dir).date('>', minutes: 1).findFiles()).to.be.eql([
					"#{dir}/two"
				])

		describe '#filter()', ->

			it 'should return files which names are 3 chars length', ->
				filter = (stat, file) ->
					name = path.basename file, path.extname(file)
					return name.length == 3
				expect(Finder.in(dir).filter(filter).findFiles()).to.be.eql([
					"#{dir}/one"
					"#{dir}/two"
				])

	describe 'utils', ->

		describe '#parseDirectory()', ->

			it 'should return object with directory and mask from path to find* methods', ->
				expect(Finder.parseDirectory("#{dir}/one")).to.be.eql(
					directory: "#{dir}/one"
					mask: null
				)

				expect(Finder.parseDirectory("#{dir}<(five|three)*>")).to.be.eql(
					directory: dir
					mask: '<(five|three)*>'
				)

				expect(Finder.parseDirectory("#{dir}*<e$>")).to.be.eql(
					directory: dir
					mask: '*<e$>'
				)

		describe '#escapeForRegex()', ->

			it 'should return escaped string for using it in regexp', ->
				expect(Finder.escapeForRegex('.h[]e()l+|l?^o$')).to.be.equal '\\.h\\[\\]e\\(\\)l\\+\\|l\\?\\^o\\$'

		describe '#normalizePattern()', ->

			it 'should return proper regular expression from path parameter', ->
				expect(Finder.normalizePattern("#{dir}/.temp/<(one|two)>*<$>")).to.be.equal "#{dir}/\\.temp/(one|two)[0-9a-zA-Z/.-_ ]+$"