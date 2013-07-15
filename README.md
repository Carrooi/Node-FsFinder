# fs-finder
file system finder inspired by finder in [Nette framework](http://doc.nette.org/en/finder).

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

```
var files = finder.recursively().findFiles('temp/[0-9]+.tmp');		// files in temp directories with numbers in name and .tmp extension
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

## Shortcuts

If you want to look for files or directories recursively without any filters, you can use shorter way.

```
var Finder = require('fs-finder');

var files = Finder.findFiles('/var/data/base-path/*js');				// Returns files
var directories = Finder.findDirectories('/var/data/base-path');		// Returns directories
var paths = Finder.find('/var/data/base-path');							// Returns files and directories
```

Only different thing are regular expressions. They have to be enclosed in <>.

```
var files = Finder.findFiles('/var/data/base-path/<(.git|.idea)*[0-9]>');		// Returns every file with .git or .idea and also with number in path
```