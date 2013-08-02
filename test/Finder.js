(function () {

	var should = require('should');
	var path = require('path');
	var fs = require('fs');

	var dir = path.resolve('./data');

	var Finder = require('../lib/Finder');
	var finder = new Finder(dir);

	describe('Finder', function() {

		describe('#findFiles()', function() {
			it('should return file names from root folder', function() {
				finder.findFiles().should.eql([
					dir + '/0',
					dir + '/1',
					dir + '/five',
					dir + '/one',
					dir + '/three',
					dir + '/two'
				]);
			});
		});

		describe('#findDirectories()', function() {
			it('should return directory names from root folder', function() {
				finder.findDirectories().should.eql([
					dir + '/eight',
					dir + '/seven',
					dir + '/six'
				]);
			});
		});

		describe('#find()', function() {
			it('should return file and directory names from root folder', function() {
				finder.find().should.eql([
					dir + '/0',
					dir + '/1',
					dir + '/eight',
					dir + '/five',
					dir + '/one',
					dir + '/seven',
					dir + '/six',
					dir + '/three',
					dir + '/two'
				]);
			});
		});

		describe('#recursive()', function() {
			it('should return file names recursively from find* methods', function() {
				finder.recursively(true);
				finder.findFiles().should.eql([
					dir + '/0',
					dir + '/1',
					dir + '/eight/3/4/file.json',
					dir + '/five',
					dir + '/one',
					dir + '/seven/13',
					dir + '/seven/14',
					dir + '/seven/twelve',
					dir + '/six/eleven',
					dir + '/six/nine',
					dir + '/six/ten',
					dir + '/three',
					dir + '/two'
				]);
				finder.recursively(false);
			});
		});

		describe('#exclude()', function() {
			it('should return files which has not got numbers in name', function() {
				finder.exclude(['<[0-9]>']);
				finder.findFiles().should.eql([
					dir + '/five',
					dir + '/one',
					dir + '/three',
					dir + '/two'
				]);
				finder.excludes = [];
			});
		});

		describe('#size()', function() {
			it('should return files with size between 2000B and 3000B', function() {
				finder.size('>=', 2000).size('<=', 3000);
				finder.findFiles().should.eql([
					dir + '/five'
				]);
				finder.filters = [];
			});
		});

		describe('#date()', function() {
			it('should return files which were changed in less than 1 minute ago', function() {
				fs.writeFileSync(dir + '/two', 'just some change');
				finder.date('>', {minutes: 1});
				finder.findFiles().should.eql([
					dir + '/two'
				]);
				finder.filters = [];
			});
		});

		describe('#showSystemFiles()', function() {
			it('should return also system, hide and temp files', function() {
				finder.showSystemFiles(true);
				finder.findFiles().should.eql([
					dir + '/.cache',
					dir + '/0',
					dir + '/1',
					dir + '/five',
					dir + '/five~',
					dir + '/one',
					dir + '/three',
					dir + '/two'
				]);
				finder.showSystemFiles(false);
			});
		});

		describe('#filter()', function() {
			it('should return files which names are 3 chars length', function() {
				finder.filter(function(stat, file) {
					var name = path.basename(file, path.extname(file));
					return name.length === 3;
				});
				finder.findFiles().should.eql([
					dir + '/one',
					dir + '/two'
				]);
				finder.filters = [];
			});
		});

		describe('#parseDirectory()', function() {
			it('should return object with directory and mask from path to find* methods', function() {
				Finder.parseDirectory(dir + '/one').should.eql({
					directory: dir + '/one',
					mask: null
				});
				Finder.parseDirectory(dir + '<(five|three)*>').should.eql({
					directory: dir,
					mask: '<(five|three)*>'
				});
				Finder.parseDirectory(dir + '*<e$>').should.eql({
					directory: dir,
					mask: '*<e$>'
				});
			});
		});

		describe('#escapeForRegex()', function() {
			it('should return escaped string for using it in regexp', function() {
				Finder.escapeForRegex('.h[]e()l+|l?^o$').should.be.equal('\\.h\\[\\]e\\(\\)l\\+\\|l\\?\\^o\\$');
			});
		});

		describe('#normalizePattern()', function() {
			it('should return proper regular expression from path parameter', function() {
				Finder.normalizePattern(dir + '/.temp/<(one|two)>*<$>').should.be.equal(dir + '/\\.temp/(one|two)[0-9a-zA-Z/.-_ ]+$');
			});
		});

	});

})();