abstract interface class AnalyticsService {
  Future<Map<String, dynamic>> getAnalyticsData(
    String username,
    String chatName,
  );
}
