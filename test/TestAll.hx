import utest.Assert;
import utest.Runner;
import utest.ui.Report;
import thx.semver.Version;

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
}
