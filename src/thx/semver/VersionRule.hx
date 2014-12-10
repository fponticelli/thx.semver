package thx.semver;

import thx.semver.Version;

abstract VersionRule(VersionComparator) from VersionComparator to VersionComparator {
  @:from public static function stringToVersionRule(s : String) : VersionRule {
    // trim left/right
    // normalize whitespaces in between
    // parse one Comparator at the time
    return EqualVersion(Version.arrayToVersion([9999, 999, 9999])); // TODO implement
  }

  public function isSatisfiedBy(version : Version) : Bool {
    return false; // TODO implement
  }
}

enum SemVerComparator {
  EqualVersion(ver : SemVer);
  GreaterThanVersion(ver : SemVer);
  GreaterThanOrEqualVersion(ver : SemVer);
  LessThanVersion(ver : SemVer);
  LessThanOrEqualVersion(ver : SemVer);
  AndRule(a : SemVerComparator, b : SemVerComparator);
  OrRule(a : SemVerComparator, b : SemVerComparator);
}