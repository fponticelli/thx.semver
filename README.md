# thx.semver

[![Build Status](https://travis-ci.org/fponticelli/thx.semver.svg)](https://travis-ci.org/fponticelli/thx.semver)

Semantic Version library for Haxe. The library provides an abstract type `thx.semver.Version` that represents a release version as described in the [Semantic Versioning Specification 2.0.0](http://semver.org/).

To create a version you can use a string:
```haxe
var v : Version = '1.2.3';
```

Or an array:

```haxe
var v : Version= [1,2,3];
```


In this case you will not be able to specify a pre-release (`pre`) or a `build` value. But you can integrate using one of the transformation methods:

```haxe
var v = ([1,2,3] : Version).withBuild('abc');
```

Versions can be easily compared:

```haxe
('1.0.0' : Version) > ('1.0.0-alpha' : Version) // yields true
```

A version with pre-release and build looks like:

```haxe
var v : Version = '1.0.0-alpha+build.12'
```

Also generating new versions is very easy:

```haxe
var v : Version = '0.9.17';
trace(v.nextMinor()); // echoes '0.10.0'
```