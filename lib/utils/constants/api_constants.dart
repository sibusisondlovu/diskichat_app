class ApiConstants {
  // Using localhost for Android Emulator
  // For physical device, use your machine's LAN IP (e.g., http://192.168.1.x:5000)
  // For iOS Simulator, use http://localhost:5000
  static const String baseUrl = 'http://192.168.8.151:5000';
  
  // Endpoints
  static const String liveMatches = '/api/live';
  static const String teams = '/api/teams';
  static const String competitions = '/api/competitions';
}
