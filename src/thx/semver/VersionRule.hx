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

  @:to public function toString()
    return switch this {
      case EqualVersion(ver):
        ver;
      case GreaterThanVersion(ver):
        '>$ver';
      case GreaterThanOrEqualVersion(ver):
        '>=$ver';
      case LessThanVersion(ver):
        '<$ver';
      case LessThanOrEqualVersion(ver):
        '<=$ver';
      case AndRule(a, b):
        '$a $b';
      case OrRule(a, b):
        '$a || $b';
    };
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