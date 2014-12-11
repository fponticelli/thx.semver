import utest.Assert;
import utest.Runner;
import utest.ui.Report;
import thx.semver.Version;
import thx.semver.VersionRule;

class TestAll {
	public static function main() {
		var runner = new Runner();
		Report.create(runner);
		runner.addCase(new TestAll());
		runner.run();
	}

	public function new() {}

  public function testStringPatterns() {
    Assert.equals('0.0.1', ('0.0.1' : Version).toString());
    Assert.equals('1.2.3', ('1.2.3' : Version).toString());
    Assert.equals('1.2.3-alpha', ('1.2.3-alpha' : Version).toString());
    Assert.equals('1.2.3+a.b.1.c', ('1.2.3+a.b.1.c' : Version).toString());
    Assert.equals('1.2.3-a.b.1.c+a.b.1.c', ('1.2.3-a.b.1.c+a.b.1.c' : Version).toString());
  }

  public function testEquality() {
    Assert.isTrue(('0.0.1' : Version) == ('0.0.1' : Version));
    Assert.isTrue(('0.0.1-alpha' : Version) == ('0.0.1-alpha' : Version));
    Assert.isTrue(('0.0.1-alpha+build' : Version) == ('0.0.1-alpha+build' : Version));
  }

  public function testGreater() {
    Assert.isTrue(('3.0.0' : Version) > ('2.3.100' : Version));
    Assert.isTrue(('1.0.0' : Version) > ('0.1.1' : Version));
    Assert.isTrue(('0.1.0' : Version) > ('0.0.1' : Version));
    Assert.isTrue(('0.0.2' : Version) > ('0.0.1' : Version));
    Assert.isTrue(('0.0.1' : Version) > ('0.0.1-alpha' : Version));
    Assert.isTrue(('0.0.1' : Version) > ('0.0.1-alpha+build' : Version));

    Assert.isTrue(('0.0.1-a.12' : Version) > ('0.0.1-a.1' : Version));
    Assert.isTrue(('0.0.1-b.1' : Version) > ('0.0.1-a.12' : Version));
    Assert.isTrue(('0.0.1-z+a.12' : Version) == ('0.0.1-z+a.1' : Version)); // builds do not make a difference
    Assert.isTrue(('0.0.1-z+b.1' : Version) == ('0.0.1-z+a.12' : Version)); // builds do not make a difference
  }

  public function testFromArray() {
    Assert.isTrue(('1.2.3' : Version) == ([1,2,3] : Version));
  }

  function v(?major : Int, ?minor : Int, ?patch : Int, ?pre : Array<Identifier>, ?build : Array<Identifier>) {
    var version = [];
    if(null != major)
      version.push(major);
    if(null != minor)
      version.push(minor);
    if(null != patch)
      version.push(patch);
    pre = null != pre ? pre : [];
    build = null != build ? build : [];

    return {
      version : version,
      pre : pre,
      build : build
    }
  }
  public function testParseVersionRule() {
    var assertions = [
      // basic operators
      { test : "1.2.3",   expected : EqualVersion(v(1,2,3)) },
      { test : "   =1.2.3"  , expected : EqualVersion(v(1,2,3)) },
      { test : "v1.2.3",  expected : EqualVersion(v(1,2,3)) },
      { test : ">1.2.3",  expected : GreaterThanVersion(v(1,2,3)) },
      { test : ">=1.2.3", expected : GreaterThanOrEqualVersion(v(1,2,3)) },
      { test : "<1.2.3",  expected : LessThanVersion(v(1,2,3)) },
      { test : "<=1.2.3", expected : LessThanOrEqualVersion(v(1,2,3)) },

      { test : ">=1.2.7 <1.3.0",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,2,7)),
          LessThanVersion(v(1,3,0))
        )
      },

      { test : "1.x || >=2.5.0 || 5.0.0 - 7.2.3",
        expected : OrRule(
          AndRule(
            GreaterThanOrEqualVersion(v(1,0,0)),
            LessThanVersion(v(2,0,0))
          ),
          OrRule(
            GreaterThanOrEqualVersion(v(2,5,0)),
            AndRule(
              GreaterThanOrEqualVersion(v(5,0,0)),
              LessThanOrEqualVersion(v(7,2,3))
            )
          )
        )
      },

      { test : "1.2.3 - 2.3.4",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,2,3)),
          LessThanOrEqualVersion(v(2,3,4))
        )
      },

      { test : "*",
        expected : GreaterThanOrEqualVersion(v(0,0,0))
      },

      { test : "",
        expected : GreaterThanOrEqualVersion(v(0,0,0))
      },

      { test : "1.x",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,0,0)),
          LessThanVersion(v(2,0,0))
        )
      },

      { test : "1",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,0,0)),
          LessThanVersion(v(2,0,0))
        )
      },

      { test : "1.2.x",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,2,0)),
          LessThanVersion(v(1,3,0))
        )
      },

      { test : "1.2",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,2,0)),
          LessThanVersion(v(1,3,0))
        )
      },

      { test : "~1.2.3",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,2,3)),
          LessThanVersion(v(1,3,0))
        )
      },

      { test : "~1.2",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,2,0)),
          LessThanVersion(v(1,3,0))
        )
      },

      { test : "~1",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,0,0)),
          LessThanVersion(v(2,0,0))
        )
      },

      { test : "~0.2.3",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,2,3)),
          LessThanVersion(v(0,3,0))
        )
      },

      { test : "~0.2",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,2,0)),
          LessThanVersion(v(0,3,0))
        )
      },

      { test : "~0",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,0,0)),
          LessThanVersion(v(1,0,0))
        )
      },

      { test : "^1.2.3",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,2,3)),
          LessThanVersion(v(2,0,0))
        )
      },

      { test : "^0.2.3",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,2,3)),
          LessThanVersion(v(0,3,0))
        )
      },

      { test : "^0.0.3",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,0,3)),
          LessThanVersion(v(0,0,4))
        )
      },

      { test : "^0.0.x",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,0,0)),
          LessThanVersion(v(0,1,0))
        )
      },

      { test : "^0.0",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,0,0)),
          LessThanVersion(v(0,1,0))
        )
      },

      { test : "^1.x",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(1,0,0)),
          LessThanVersion(v(2,0,0))
        )
      },

      { test : "^0.x",
        expected : AndRule(
          GreaterThanOrEqualVersion(v(0,0,0)),
          LessThanVersion(v(1,0,0))
        )
      }
    ];
    for(assertion in assertions) {
      var rule : VersionRule = assertion.test;
      Assert.same((rule : VersionComparator), assertion.expected, 'test "${assertion.test}"" should be equivalent to ${assertion.expected} but it is ${(rule : VersionComparator)}"');
    }
  }

  public function testVersionRule() {
    var assertions = [
      { rule : ">=1.2.7",
        satisfies : ["1.2.7", "1.2.8", "2.5.3", "1.3.9"],
        unsatisfies : ["1.2.6","1.1.0"] },
      { rule : ">=1.2.7 <1.3.0",
        satisfies : ["1.2.7", "1.2.8", "1.2.99"],
        unsatisfies : ["1.2.6", "1.3.0", "1.1.0"] },
      { rule : "1.2.7 || >=1.2.9 <2.0.0",
        satisfies : ["1.2.7", "1.2.9", "1.4.6"],
        unsatisfies : ["1.2.8", "2.0.0"] },
      { rule : ">1.2.3-alpha.3",
        satisfies : ["1.2.3-alpha.7", "3.4.5"],
        unsatisfies : ["3.4.5-alpha.9"] },

      // hyphen
      { rule : "1.2.3 - 2.3.4",
        satisfies : ["1.2.3", "2.3.4"],
        unsatisfies : ["1.2.2", "2.3.5"] },

      { rule : "1.2 - 2.3.4",
        satisfies : ["1.2.0", "2.3.4"],
        unsatisfies : ["1.1.9", "2.3.5"] },

      { rule : "1.2.3 - 2.3",
        satisfies : ["1.2.3", "2.3.9"],
        unsatisfies : ["1.2.2", "2.4.0"] },

      { rule : "1.2.3 - 2",
        satisfies : ["1.2.3", "2.99.0"],
        unsatisfies : ["1.2.2", "3.0.0"] },

      // X-ranges *,x,X,""
      { rule : "*", satisfies : ["0.0.0", "1.0.0"], unsatisfies : [] },
      { rule : "",  satisfies : ["0.0.0", "1.0.0"], unsatisfies : [] },
      { rule : "x", satisfies : ["0.0.0", "1.0.0"], unsatisfies : [] },
      { rule : "X", satisfies : ["0.0.0", "1.0.0"], unsatisfies : [] },

      { rule : "1.x", satisfies : ["1.0.0", "1.99.0"], unsatisfies : ["0.0.0", "2.0.0"] },
      { rule : "1", satisfies : ["1.0.0", "1.99.0"], unsatisfies : ["0.0.0", "2.0.0"] },

      { rule : "1.2.x", satisfies : ["1.2.0", "1.2.99"], unsatisfies : ["1.3.0"] },
      { rule : "1.2", satisfies : ["1.2.0", "1.2.99"], unsatisfies : ["1.3.0"] },

      // Tilde Ranges ~1.2.3 ~1.2 ~1
      // Allows patch-level changes if a minor version is specified on the comparator.
      // Allows minor-level changes if not.
      { rule : "~1.2.3", satisfies : ["1.2.3"], unsatisfies : ["1.3.0"] },
      { rule : "~1.2", satisfies : ["1.2.0", "1.2.99"], unsatisfies : ["1.3.0"] },
      { rule : "~1", satisfies : ["1.0.0", "1.99.0"], unsatisfies : ["0.0.0", "2.0.0"] },
      { rule : "~0.2.3", satisfies : ["0.2.3"], unsatisfies : ["0.3.0"] },
      { rule : "~0.2", satisfies : ["0.2.0"], unsatisfies : ["0.3.0"] },
      { rule : "~0", satisfies : ["0.0.0"], unsatisfies : ["1.0.0"] },
      { rule : "~1.2.3-beta.2", satisfies : ["1.2.3-beta.4"], unsatisfies : ["1.2.4-beta.2"] },

      // Caret Ranges ^1.2.3 ^0.2.5 ^0.0.4
      { rule : "^1.2.3", satisfies : ["1.2.3", "1.3.0"], unsatisfies : ["2.0.0"] },
      { rule : "^0.2.3", satisfies : ["0.2.3"], unsatisfies : ["0.3.0"] },
      { rule : "^0.0.3", satisfies : ["0.0.3"], unsatisfies : ["0.0.4"] },

      { rule : "^1.2.3-beta.2", satisfies : ["1.2.3-beta.2", "1.2.3-beta.4"], unsatisfies : ["1.2.4-beta.2", "2.0.0"] },
      { rule : "^0.0.3-beta", satisfies : ["0.0.3-pr.2"], unsatisfies : ["0.0.4"] },

      { rule : "^1.2.x", satisfies : ["1.2.0"], unsatisfies : ["2.0.0"] },
      { rule : "^0.0.x", satisfies : ["0.0.0"], unsatisfies : ["0.1.0"] },
      { rule : "^0.0", satisfies : ["0.0.0"], unsatisfies : ["0.1.0"] },

      { rule : "^1.x", satisfies : ["1.0.0"], unsatisfies : ["2.0.0"] },
      { rule : "^0.x", satisfies : ["0.0.0"], unsatisfies : ["1.0.0"] }
    ];

    for(assertion in assertions) {
      for(satisfy in assertion.satisfies)
        Assert.isTrue((assertion.rule : VersionRule).isSatisfiedBy(satisfy), 'version "${satisfy}" should satisfy rule "${assertion.rule}"');
      for(unsatisfy in assertion.unsatisfies)
        Assert.isFalse((assertion.rule : VersionRule).isSatisfiedBy(unsatisfy), 'version "${unsatisfy}" should NOT satisfy rule "${assertion.rule}"');
    }
  }
}
