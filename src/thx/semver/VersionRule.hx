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

enum VersionComparator {
  EqualVersion(ver : Version);
  GreaterThanVersion(ver : Version);
  GreaterThanOrEqualVersion(ver : Version);
  LessThanVersion(ver : Version);
  LessThanOrEqualVersion(ver : Version);
  AndRule(a : VersionComparator, b : VersionComparator);
  OrRule(a : VersionComparator, b : VersionComparator);
}