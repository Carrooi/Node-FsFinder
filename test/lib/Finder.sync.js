// Generated by CoffeeScript 1.6.3
(function() {
  var Finder, expect, fs, path, tree;

  expect = require('chai').expect;

  path = require('path');

  Finder = require('../../lib/Finder');

  fs = null;

  tree = {
    eight: {
      3: {
        4: {
          'file.json': ''
        }
      },
      '._.js': '',
      'other.js': '',
      'package.json': ''
    },
    seven: {
      13: '',
      14: '',
      twelve: ''
    },
    six: {
      eleven: '',
      nine: '',
      ten: ''
    },
    '.cache': '',
    0: '',
    1: '',
    five: 'hello word',
    'five~': '',
    one: '',
    three: '',
    two: ''
  };

  describe('Finder.sync', function() {
    beforeEach(function() {
      return fs = Finder.mock(tree);
    });
    afterEach(function() {
      return Finder.restore();
    });
    describe('#constructor()', function() {
      return it('should throw an error if path is not directory', function() {
        return expect(function() {
          return new Finder("/two");
        }).to["throw"](Error, "Path /two is not directory");
      });
    });
    describe('#findFiles()', function() {
      return it('should return file names from root folder', function() {
        return expect(Finder["in"]('/').findFiles()).to.have.members(["/0", "/1", "/five", "/one", "/three", "/two"]);
      });
    });
    describe('#findDirectories()', function() {
      return it('should return directory names from root folder', function() {
        return expect(Finder["in"]('/').findDirectories()).to.have.members(["/eight", "/seven", "/six"]);
      });
    });
    describe('#find()', function() {
      return it('should return file and directory names from root folder', function() {
        return expect(Finder["in"]('/').find()).to.have.members(["/0", "/1", "/eight", "/seven", "/six", "/five", "/one", "/three", "/two"]);
      });
    });
    describe('#recursive()', function() {
      return it('should return file names recursively from find* methods', function() {
        return expect(Finder.from('/').findFiles()).to.have.members(["/0", "/1", "/eight/3/4/file.json", "/eight/other.js", "/eight/package.json", "/seven/13", "/seven/14", "/seven/twelve", "/six/eleven", "/six/nine", "/six/ten", "/five", "/one", "/three", "/two"]);
      });
    });
    describe('#findFirst()', function() {
      it('should return file path', function() {
        return expect(Finder["in"]('/').findFirst().findFiles()).to.be.equal("/0");
      });
      it('should return null', function() {
        return expect(Finder["in"]('/').findFirst().findFiles('randomName')).to.be["null"];
      });
      it('should return file path for first name with two numbers in name', function() {
        return expect(Finder.from('/').findFirst().findFiles('<[0-9]{2}>')).to.be.equal("/seven/13");
      });
      it('should return null for recursive searching', function() {
        return expect(Finder.from('/').findFirst().findFiles('randomName')).to.be["null"];
      });
      it('should return first path to directory', function() {
        return expect(Finder.from('/').findFirst().findDirectories('4')).to.be.equal("/eight/3/4");
      });
      it('should return null when looking into parents', function() {
        return expect(Finder["in"]("/eight/3/4").lookUp(4).findFirst().findFiles('twelve')).to.be["null"];
      });
      return it('should return first file when looking into parents recursively', function() {
        return expect(Finder.from("/eight/3/4").lookUp(4).findFirst().findFiles('twelve')).to.equal("/seven/twelve");
      });
    });
    describe('#exclude()', function() {
      return it('should return files which has not got numbers in name', function() {
        return expect(Finder["in"]('/').exclude(['<[0-9]>']).findFiles()).to.have.members(["/five", "/one", "/three", "/two"]);
      });
    });
    describe('#showSystemFiles()', function() {
      return it('should return also system, hide and temp files', function() {
        return expect(Finder["in"]('/').showSystemFiles().findFiles()).to.have.members(["/0", "/1", "/.cache", "/five", "/five~", "/one", "/three", "/two"]);
      });
    });
    describe('#lookUp()', function() {
      it('should return path to file in parent directory', function() {
        return expect(Finder["in"]("/eight/3/4").lookUp(4).showSystemFiles().findFiles('._.js')).to.have.members(["/eight/._.js"]);
      });
      it('should return first file in parent directory with depth set by string', function() {
        return expect(Finder["in"]("/eight").lookUp('/').findFiles('package.json')).to.have.members(["/eight/package.json"]);
      });
      it('should return null when limit parent is the same like searched directory and file is not there', function() {
        return expect(Finder["in"]('/').lookUp('/').findFiles('package.json')).to.be.eql([]);
      });
      it('should return path to file in parent directory recursively', function() {
        return expect(Finder.from("/eight/3/4").lookUp(4).findFiles('twelve')).to.have.members(["/seven/twelve"]);
      });
      return it('should return first file in parent directories with depth set by string', function() {
        return expect(Finder.from("/eight/3/4").lookUp('/').findFiles('twelve')).to.have.members(["/seven/twelve"]);
      });
    });
    describe('#size()', function() {
      return it('should return files with size between 2000B and 3000B', function() {
        return expect(Finder["in"]('/').size('>=', 9).size('<=', 11).findFiles()).to.have.members(["/five"]);
      });
    });
    describe('#date()', function() {
      return it('should return files which were changed in less than 1 second ago', function(done) {
        return setTimeout(function() {
          fs.writeFileSync("/two", 'just some changes');
          expect(Finder["in"]('/').date('>', {
            milliseconds: 100
          }).findFiles()).to.have.members(["/two"]);
          return done();
        }, 200);
      });
    });
    return describe('#filter()', function() {
      return it('should return files which names are 3 chars length', function() {
        var filter;
        filter = function(stat, file) {
          var name;
          name = path.basename(file, path.extname(file));
          return name.length === 3;
        };
        return expect(Finder["in"]('/').filter(filter).findFiles()).to.have.members(["/one", "/two"]);
      });
    });
  });

}).call(this);
