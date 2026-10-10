enum BuildFlavor { dev, prod, wear }

class AppConfig {
  AppConfig._();

  static late BuildFlavor flavor;

  static bool get isDev => flavor == BuildFlavor.dev;

  static bool get isWear => flavor == BuildFlavor.wear;
}
