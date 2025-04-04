enum Flavor {
  org,
  user,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.org:
        return 'SOBA Org';
      case Flavor.user:
        return 'SOBA User';
    }
  }

}
