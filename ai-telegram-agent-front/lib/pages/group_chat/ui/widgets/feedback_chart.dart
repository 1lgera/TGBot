import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FeedbackChart extends StatelessWidget {
  final List<String> feedbackData;

  FeedbackChart({Key? key, required this.feedbackData}) : super(key: key);

  Map<String, int> _parseFeedbackData() {
    final Map<String, int> result = {
      'PositiveFeedback': 0,
      'NegativeFeedback': 0,
      'Agreement': 0,
      'Announcement': 0,
      'Apology': 0,
      'Conflict': 0,
      'Confusion': 0,
      'Disagreement': 0,
      'Encouragement': 0,
      'Instruction': 0,
      'Joke': 0,
      'Motivation': 0,
      'Neutral': 0,
      'OffTopic': 0,
      'Question': 0,
      'Sarcasm': 0,
      'Spam': 0,
      'Support': 0,
      'Trolling': 0,
      'Urgent': 0,
    };

    final regExp = RegExp(r'^(.+?)\s\((\d+)\s(?:message|messages)\)$');

    for (var item in feedbackData) {
      final match = regExp.firstMatch(item);
      if (match != null) {
        final category = match.group(1)!;
        final count = int.parse(match.group(2)!);

        if (result.containsKey(category)) {
          result[category] = count;
        }
      }
    }

    return result;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'PositiveFeedback': Colors.green,
      'NegativeFeedback': Colors.red,
      'Agreement': Colors.blue[400]!,
      'Announcement': Colors.orange[400]!,
      'Apology': Colors.purple[400]!,
      'Conflict': Colors.red[800]!,
      'Confusion': Colors.yellow[700]!,
      'Disagreement': Colors.red[400]!,
      'Encouragement': Colors.lightGreen[400]!,
      'Instruction': Colors.teal[400]!,
      'Joke': Colors.pink[300]!,
      'Motivation': Colors.deepOrange[300]!,
      'Neutral': Colors.grey[500]!,
      'OffTopic': Colors.brown[400]!,
      'Question': Colors.indigo[400]!,
      'Sarcasm': Colors.amber[800]!,
      'Spam': Colors.deepPurple[300]!,
      'Support': Colors.lightBlue[400]!,
      'Trolling': Colors.red[900]!,
      'Urgent': Colors.redAccent[400]!,
    };

    return colors[category] ?? Colors.grey;
  }

  List<PieChartSectionData> _generatePieChartSections(Map<String, int> data) {
    final entries = data.entries.where((e) => e.value > 0).toList();
    final total = entries.fold(0, (sum, e) => sum + e.value);

    return entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.value} ($percentage%)',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(String category, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(
              color: AppColors.appWhite,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: TextStyle(
              color: AppColors.appWhite,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _parseFeedbackData();
    final pieChartSections = _generatePieChartSections(data);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: 500,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.appLightGrey, width: 0.7),
        color: AppColors.appFieldColor,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                startDegreeOffset: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Message classifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.appWhite,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: entries
                  .map((entry) => _buildLegendItem(
                      entry.key, _getCategoryColor(entry.key), entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
