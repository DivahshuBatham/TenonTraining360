enum Environment { dev, staging, production }

class AppConfig {
  static Environment _environment = Environment.dev; // default

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return "http://192.168.0.139:8000/api/";
      case Environment.staging:
        return "http://192.168.0.139:8000/api/";
      case Environment.production:
        return "http://122.187.19.156:8000/api/";
    }
  }

  static String get appName {
    switch (_environment) {
      case Environment.dev:
        return "Saksham Dev";
      case Environment.staging:
        return "Saksham Staging";
      case Environment.production:
        return "Saksham";
    }
  }

  static bool get isDebug => _environment == Environment.dev;
}
