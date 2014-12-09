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

      { rule : "1.2.x", satisfies : ["1.2.0", "1.99.0"], unsatisfies : ["1.3.0"] },
      { rule : "1.2", satisfies : ["1.2.0", "1.99.0"], unsatisfies : ["1.3.0"] },

      // Tilde Ranges ~1.2.3 ~1.2 ~1
      // Allows patch-level changes if a minor version is specified on the comparator.
      // Allows minor-level changes if not.
      // ~1.2.3 := >=1.2.3 <1.(2+1).0 := >=1.2.3 <1.3.0
      // ~1.2 := >=1.2.0 <1.(2+1).0 := >=1.2.0 <1.3.0 (Same as 1.2.x)
      // ~1 := >=1.0.0 <(1+1).0.0 := >=1.0.0 <2.0.0 (Same as 1.x)
      // ~0.2.3 := >=0.2.3 <0.(2+1).0 := >=0.2.3 <0.3.0
      // ~0.2 := >=0.2.0 <0.(2+1).0 := >=0.2.0 <0.3.0 (Same as 0.2.x)
      // ~0 := >=0.0.0 <(0+1).0.0 := >=0.0.0 <1.0.0 (Same as 0.x)
      // ~1.2.3-beta.2 := >=1.2.3-beta.2 <1.3.0 Note that prereleases in the 1.2.3 version will be allowed, if they are greater than or equal to beta.2. So, 1.2.3-beta.4 would be allowed, but 1.2.4-beta.2 would not, because it is a prerelease of a different [major, minor, patch] tuple.

      // Caret Ranges ^1.2.3 ^0.2.5 ^0.0.4
      // ^1.2.3 := >=1.2.3 <2.0.0
      // ^0.2.3 := >=0.2.3 <0.3.0
      // ^0.0.3 := >=0.0.3 <0.0.4
      // ^1.2.3-beta.2 := >=1.2.3-beta.2 <2.0.0 Note that prereleases in the 1.2.3 version will be allowed, if they are greater than or equal to beta.2. So, 1.2.3-beta.4 would be allowed, but 1.2.4-beta.2 would not, because it is a prerelease of a different [major, minor, patch] tuple.
      // ^0.0.3-beta := >=0.0.3-beta <0.0.4 Note that prereleases in the 0.0.3 version only will be allowed, if they are greater than or equal to beta. So, 0.0.3-pr.2 would be allowed.

      // ^1.2.x := >=1.2.0 <2.0.0
      // ^0.0.x := >=0.0.0 <0.1.0
      // ^0.0 := >=0.0.0 <0.1.0

      // ^1.x := >=1.0.0 <2.0.0
      // ^0.x := >=0.0.0 <1.0.0
    ];

    for(assertion in assertions) {
      for(satisfy in assertion.satisfies)
        Assert.isTrue((assertion.rule : VersionRule).isSatisfiedBy(satisfy), 'version "${satisfy}" should satisfy rule "${assertion.rule}"');
      for(unsatisfy in assertion.unsatisfies)
        Assert.isFalse((assertion.rule : VersionRule).isSatisfiedBy(unsatisfy), 'version "${unsatisfy}" should NOT satisfy rule "${assertion.rule}"');
    }
  }
}
