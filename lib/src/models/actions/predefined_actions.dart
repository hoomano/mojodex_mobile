class PredefinedAction {
  final String name;
  final String buttonText;
  final String messagePrefix;
  final int taskPk;

  PredefinedAction({
    required this.name,
    required this.buttonText,
    required this.messagePrefix,
    required this.taskPk,
  });

  // Convert a Action object into a Map
  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'button_text': buttonText,
      'message_prefix': messagePrefix,
      'task_pk': taskPk,
    };
    return data;
  }

  // Create a Action object from a Map
  factory PredefinedAction.fromJson(Map<String, dynamic> json) {
    return PredefinedAction(
      name: json['name'],
      buttonText: json['button_text'],
      messagePrefix: json['message_prefix'],
      taskPk: json['task_pk'],
    );
  }
}
