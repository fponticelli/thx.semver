#!/bin/sh
rm thx.semver.zip
zip -r thx.semver.zip hxml src test doc/ImportSemver.hx extraParams.hxml haxelib.json LICENSE README.md -x "*/\.*"
haxelib submit thx.semver.zip
