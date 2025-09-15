// analytics_data.dart
class AnalyticsData {
  final String chatName;
  final List<String> feedbackData;
  final String markdownContent;
  final List<Map<String, dynamic>> messages;

  AnalyticsData({
    required this.chatName,
    required this.feedbackData,
    required this.markdownContent,
    required this.messages,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      chatName: json['chatName'] ?? '',
      feedbackData: List<String>.from(json['bert_classification'] ?? []),
      markdownContent: json['llm_response'] ?? '',
      messages: List<Map<String, dynamic>>.from(json['messages'] ?? []),
    );
  }

  factory AnalyticsData.empty() {
    return AnalyticsData(
      chatName: '',
      feedbackData: [],
      markdownContent: '',
      messages: [],
    );
  }
}