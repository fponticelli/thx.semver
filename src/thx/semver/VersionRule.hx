package thx.semver;

import thx.semver.Version;

abstract VersionRule(SemVerComparator) from SemVerComparator to SemVerComparator {
  @:from public static function stringToVersionRule(s : String) {
    // trim left/right
    // normalize whitespaces in between
    // parse one Comparator at the time
    return null; // TODO implement
  }

  public function isSatisfiedBy(version : Version) : Bool {
    return false; // TODO implement
  }
}

enum SemVerComparator {
  EqualVersion(ver : SemVer);
  GreaterThanVersion(ver : SemVer);
  GreaterOrEqualThanVersion(ver : SemVer);
  LessThanVersion(ver : SemVer);
  LessOrEqualThanVersion(ver : SemVer);
  AndMatch(a : SemVerComparator, b : SemVerComparator);
  OrMatch(a : SemVerComparator, b : SemVerComparator);
}