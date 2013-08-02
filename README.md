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
var Finder = requrire('fs-finder');
var finder = new Finder('/var/data/base-path');

var files = finder.findFiles();		// returns array with file's names
```

## Searching directories

```
var directories = finder.findDirectories();		// returns array with directorie's names
```

## Searching for files and directories

```
var paths = finder.find();		// returns array with file's and directorie's names
```

## Recursive searching

```
var paths = finder.recursively().find();
```

## Path mask

```
var files = finder.recursively().findFiles('*.coffee');
```

In this example fs finder looks for all files in base directories recursively with '.coffee' in their name.
Asterisk is just shortcut for regexp '[0-9a-zA-Z/.-_ ]+' so you can also use regexp in mask.

Only thing what you have to do, is enclose your regex into <>.

```
var files = finder.recursively().findFiles('temp/<[0-9]+>.tmp');		// files in temp directories with numbers in name and .tmp extension
```

## Excluding

Same technique like path mask works also for excluding files or directories.

```
var files = finder.recursively().exclude(['/.git']).findFiles();
```

This code will return all files from base directory but not files beginning with .git or in .git directory.
Also there you can use regular expressions or asterisk.

## Filters

### Filtering by file size

```
var files = finder.recursively().size('>=', 450).size('<=' 500).findFiles();
```

Returns all files with size between 450B and 500B.

### Filtering by modification date

```
var files = finder.recursively().date('>', {minutes: 10}).date('<', {minutes: 1}).findFiles();
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

var files = finder.recursively().filter(filter).findFiles();
```

Returns all files if actual time is any hour with 42 minutes.
Custom filters are annonymous function with stat file object parameter ([documentation](http://nodejs.org/api/fs.html#fs_class_fs_stats))
and file name.

## System and temp files

In default, fs-finder ignoring temp and system files, which are created for example by gedit editor and which have got ~ character
in the end of file name or dot in the beginning.

```
var files = finder.showSystemFiles(true).findFiles()
var files = finder.showSystemFiles(false).findFiles()
```

## Shortcuts

If you want to look for files or directories recursively without any filters, you can use shorter way.

```
var Finder = require('fs-finder');

var files = Finder.findFiles('/var/data/base-path/*js');				// Returns files
var directories = Finder.findDirectories('/var/data/base-path');		// Returns directories
var paths = Finder.find('/var/data/base-path');							// Returns files and directories
```

```
var files = Finder.findFiles('/var/data/base-path/<(.git|.idea)*[0-9]>');		// Returns every file with .git or .idea and also with number in path
```

For more advanced options you can use in and from functions.

```
var files = Finder.in('/var/data/base-path').findFiles();		// Load files only from base-path directory
var files = Finder.from('/var/data/base-path').findFiles();		// Load files recursively
```

## Changelog

* 1.5.0
	+ Added changelog

* 1.4.3
	+ Added MIT license

* 1.4.2
	+ Renamed repository from fs-finder to node-fs-finder

* 1.4.1
	+ Type in readme

* 1.4.0
	+ Every regexp must be enclosed in <> (before this, dots meens everything, not dot)
	+ Every character, which does mean something in regexp and is not in <>, is escaped

* 1.3.0 (it seems that I skiped this version, sorry)

* 1.2.0
	+ Added in, from methods

* 1.1.0
	+ Added shortcuts "static" methods

* 1.0.1
	+ Some bug in combination with [simq](https://npmjs.org/package/simq)

* 1.0.0
	+ Initial commit