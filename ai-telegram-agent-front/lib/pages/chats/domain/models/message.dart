class Message {
  final String content;
  final DateTime sendTime;
  final String username;

  Message({
    required this.content,
    required this.sendTime,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'send_time': sendTime.toIso8601String(),
      'username': username,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      sendTime: DateTime.parse(json['send_time'] as String),
      username: json['username'] as String,
    );
  }
}
