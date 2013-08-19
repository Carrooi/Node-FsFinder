# fs-finder
file system finder inspired by finder in [Nette framework](http://doc.nette.org/en/finder).

## Changelog

Changelog is in the bottom of this readme.

## Installing

```
$ npm install fs-finder
```

## Searching files in directory

```
var Finder = require('fs-finder');

var files = Finder.in('/var/data/base-path').findFiles();		// returns array with file's names
```

## Searching directories

```
var directories = Finder.in(baseDir).findDirectories();		// returns array with directories's names
```

## Searching for files and directories

```
var paths = Finder.in(baseDir).find();		// returns array with file's and directories's names
```

## Recursive searching

```
var paths = Finder.from(baseDir).find();
```

## Path mask

```
var files = Finder.from(baseDir).findFiles('*.coffee');
```

In this example fs finder looks for all files in base directories recursively with '.coffee' in their name.
Asterisk is just shortcut for regexp '[0-9a-zA-Z/.-_ ]+' so you can also use regexp in mask.

Only thing what you have to do, is enclose your regex into <>.

```
var files = Finder.from(baseDir).findFiles('temp/<[0-9]+>.tmp');		// files in temp directories with numbers in name and .tmp extension
```

## Excluding

Same technique like path mask works also for excluding files or directories.

```
var files = Finder.from(baseDir).exclude(['/.git']).findFiles();
```

This code will return all files from base directory but not files beginning with .git or in .git directory.
Also there you can use regular expressions or asterisk.

## Filters

### Filtering by file size

```
var files = Finder.from(baseDir).size('>=', 450).size('<=' 500).findFiles();
```

Returns all files with size between 450B and 500B.

### Filtering by modification date

```
var files = Finder.from(baseDir).date('>', {minutes: 10}).date('<', {minutes: 1}).findFiles();
```

Returns all files which were modified between two and nine minutes ago.
Date filter expecting literal object (you can see documentation in moment.js [documentation](http://momentjs.com/docs/#/manipulating/add/))
or string date representation in YYYY-MM-DD HH:mm format.

### Custom filters

```
var filter = function(stat, path) {
	if ((new Date).getMinutes() === 42) {
		return true;
	} else {
		return false;
	}
});

var files = Finder.from(baseDir).filter(filter).findFiles();
```

Returns all files if actual time is any hour with 42 minutes.
Custom filters are anonymous function with stat file object parameter ([documentation](http://nodejs.org/api/fs.html#fs_class_fs_stats))
and file name.

## System and temp files

In default, fs-finder ignoring temp and system files, which are created for example by gedit editor and which have got ~ character
in the end of file name or dot in the beginning.

```
var files = Finder.in(dir).showSystemFiles().findFiles()
```

## Look in parent directories

Finder can also look for files in parent directories. There is used `exclude` method, so directories in which were your
files already searched, will not be opened for searching again in their next parent directory if you are using `from` method.

Keep in mind that one of parent directories is also your disk root directory, so you can get list of all of your files or
 directories on disk which are accessible from your user account. To avoid this, you can set depth.

```
var files = Finder.in(dir).lookUp().findFiles('5.log');

// or set depth
var files = Finder.in(dir).lookUp(3).findFiles('5.log');

## Find first

When you want to find first occur of some file or directory, you can use option `findFirst`. fs-finder will not look into
all directories (for recursive searching) but stop when it will find first matching path.

If there is no matching path, null will be returned.

```
var file = Finder.from(dir).findFirst().findFiles('<[0-9]{2}>');
```

## Changelog

* 1.7.1
	+ Catch errors when accessing secured paths (via `lookUp` option)

* 1.7.0
	+ Mistake in test
	+ Bug in Finder (filters were shared across all instances)
	+ Preferred way is to use 'static' methods
	+ Tests uses 'static' methods
	+ Added `findFirst` option

* 1.6.0
	+ New reporter for tests
	+ Tests rewritten to coffeescript
	+ Added `lookUp` option
	+ Typos in readme

* 1.5.1
	+ Compare function replaced with [operation-compare](https://npmjs.org/package/operator-compare)

* 1.5.0
	+ Added changelog
	+ Created tests (npm test)
	+ Repaired bugs with hiding system and temp files

* 1.4.3
	+ Added MIT license

* 1.4.2
	+ Renamed repository from fs-finder to node-fs-finder

* 1.4.1
	+ Type in readme

* 1.4.0
	+ Every regexp must be enclosed in <> (before this, dots means everything, not dot)
	+ Every character, which does mean something in regexp and is not in <>, is escaped

* 1.3.0 (it seems that I skipped this version, sorry)

* 1.2.0
	+ Added in, from methods

* 1.1.0
	+ Added shortcuts "static" methods

* 1.0.1
	+ Some bug in combination with [simq](https://npmjs.org/package/simq)

* 1.0.0
	+ Initial commit