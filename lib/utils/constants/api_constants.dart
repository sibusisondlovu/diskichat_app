class ApiConstants {
  // Using localhost for Android Emulator
  // For physical device, use your machine's LAN IP (e.g., http://192.168.1.x:5000)
  // For iOS Simulator, use http://localhost:5000
  // CHANGE THIS to your machine's local IP if testing on physical device
  // Android Emulator: 10.0.2.2
  // iOS Simulator: localhost
  // Physical Device: 192.168.x.x
  static const String baseUrl = 'http://192.168.8.212:5000'; 
  // If user is on emulator, try http://10.0.2.2:5000
  
  // Endpoints
  static const String matches = '/api/matches';
  static const String teams = '/api/teams';
  static const String competitions = '/api/competitions';
}
