enum BuildFlavor { dev, prod }

class AppConfig {
  AppConfig._();

  static late BuildFlavor flavor;

  static bool get isDev => flavor == BuildFlavor.dev;
}
