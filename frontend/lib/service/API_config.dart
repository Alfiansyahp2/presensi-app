import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    // Get base URL from .env file
    final apiUrl = dotenv.env['API_BASE_URL'];

    // Fallback to localhost if not set
    if (apiUrl == null || apiUrl.isEmpty) {
      return 'http://10.0.2.2:8000/api';
    }

    return apiUrl;
  }

  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  static bool get isProduction {
    return environment == 'production';
  }

  static bool get isDevelopment {
    return environment == 'development';
  }
}
