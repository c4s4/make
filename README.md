# Parent Makefiles

These are parent makefiles for my projects. To use them, clone this project in your home directory with:

```
$ git clone https://github.com/c4s4/make.git ~/.make
```

Note that running this command clones on branch *master*, you can freeze a given version with:

```
$ git rev-parse HEAD
c8d8b9893ec3465f83813b8a8b6ce9c2cfe81124
$ git checkout c8d8b9893ec3465f83813b8a8b6ce9c2cfe81124
```

Then you can use these parent makefiles in your own with lines such as:

```
include ~/.make/python.mk
```

Some makefiles (such as *help.mk*) use [Make Tools](https://github.com/c4s4/make-tools).

These makefiles are released under Apache 2.0 license.

*Enjoy!*
