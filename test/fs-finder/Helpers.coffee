expect = require('chai').expect

Helpers = require '../../lib/Helpers'

describe 'Helpers', ->

	describe '#parseDirectory()', ->

		it 'should return object with directory and mask from path to find* methods', ->
			expect(Helpers.parseDirectory("/one")).to.be.eql(
				directory: "/one"
				mask: null
			)

			expect(Helpers.parseDirectory("<(five|three)*>")).to.be.eql(
				directory: ''
				mask: '<(five|three)*>'
			)

			expect(Helpers.parseDirectory("*<e$>")).to.be.eql(
				directory: ''
				mask: '*<e$>'
			)