package thx.semver;

using thx.semver.Version;
using StringTools;

abstract VersionRule(VersionComparator) from VersionComparator to VersionComparator {
  static var VERSION = ~/^(v|=|>|>=|<|<=|~|^)?(\d+|[x*])\.(\d+|[x*])?\.(\d+|[x*])?(?:[-]([a-z0-9.-]+))?(?:[+]([a-z0-9.-]+))?$/i;
  @:from public static function stringToVersionRule(s : String) : VersionRule {
    var ors = s.split("||").map(function(comp) {
      comp = comp.trim();
      var p = comp.split(" - ");
      return if(p.length == 1) {
        comp = comp.trim();
        p = (~/\s+/).split(comp);
        if(p.length == 1) {
          if(!VERSION.match(comp)) {
            throw 'invalid pattern $comp';
          } else {
            // one term pattern
            var v  = versionArray(VERSION),
                vf = v.concat([0, 0, 0]).slice(0, 3);
            switch [VERSION.matched(1), v.length] {
              case ["v", 0], ["=", 0], ["", 0], [null, 0]:
                GreaterThanOrEqualVersion(Version.arrayToVersion(vf).withPre(VERSION.matched(5), VERSION.matched(6)));
              case ["v", 3], ["=", 3], ["", 3], [null, 3]:
                EqualVersion(Version.arrayToVersion(v).withPre(VERSION.matched(5), VERSION.matched(6)));
              case ["v", _], ["=", _], ["", _], [null, _]:
                var version = Version.arrayToVersion(vf).withPre(VERSION.matched(5), VERSION.matched(6));
                AndRule(
                  GreaterThanOrEqualVersion(version),
                  LessThanVersion(version.nextMajor())
                );
              case [">", _]:
                GreaterThanVersion(Version.arrayToVersion(vf).withPre(VERSION.matched(5), VERSION.matched(6)));
              case [">=", _]:
                GreaterThanOrEqualVersion(Version.arrayToVersion(vf).withPre(VERSION.matched(5), VERSION.matched(6)));
              case ["<", _]:
                LessThanVersion(Version.arrayToVersion(vf).withPre(VERSION.matched(5), VERSION.matched(6)));
              case ["<=", _]:
                LessThanOrEqualVersion(Version.arrayToVersion(vf).withPre(VERSION.matched(5), VERSION.matched(6)));
              case ["~", _]:
                // TODO
                EqualVersion(Version.arrayToVersion([901, 999, 9999]));
              case ["^", _]:
                // TODO
                EqualVersion(Version.arrayToVersion([456, 999, 9999]));
              case [p, _]: throw 'invalid prefix "$p" for rule $comp';
            };
          }
        } else if(p.length == 2) {
          // range, requires >||>= && <||<=
          // TODO
          EqualVersion(Version.arrayToVersion([9999, 999, 9999]));
        } else {
          throw 'invalid pattern $comp';
        }
      } else if(p.length == 2) {
        AndRule(
          GreaterThanOrEqualVersion(p[0].trim().stringToVersion()),
          LessThanOrEqualVersion(p[1].trim().stringToVersion())
        );
      } else {
        throw 'invalid pattern $comp';
      }
    });

    var rule = null;
    while(ors.length > 0) {
      var r = ors.pop();
      if(null == rule)
        rule = r;
      else
        rule = OrRule(r, rule);
    }
    return rule;

    // trim left/right
    // normalize whitespaces in between
    // parse one Comparator at the time
    //return EqualVersion(Version.arrayToVersion([9999, 999, 9999])); // TODO implement
  }

  static var IS_DIGITS = ~/^\d+$/;
  static function versionArray(re : EReg) {
    var arr = [],
        t;
    for(i in 2...5) {
      t = re.matched(i);
      if(null != t && IS_DIGITS.match(t))
        arr.push(Std.parseInt(t));
      else
        break;
    }
    return arr;
  }

  public static function versionRuleIsValid(rule : String)
    return try stringToVersionRule(rule) != null catch(e : Dynamic) false;

  public function isSatisfiedBy(version : Version) : Bool {
    return switch this {
      case EqualVersion(ver):
        version == ver;
      case GreaterThanVersion(ver):
        version > ver;
      case GreaterThanOrEqualVersion(ver):
        version >= ver;
      case LessThanVersion(ver):
        version < ver;
      case LessThanOrEqualVersion(ver):
        version <= ver;
      case AndRule(a, b):
        (a : VersionRule).isSatisfiedBy(version) && (b : VersionRule).isSatisfiedBy(version);
      case OrRule(a, b):
        (a : VersionRule).isSatisfiedBy(version) || (b : VersionRule).isSatisfiedBy(version);
    };
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