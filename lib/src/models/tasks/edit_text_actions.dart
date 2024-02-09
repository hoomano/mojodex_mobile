class TextEditAction {
  // The label of this text edit action
  late String name;

  // The description of this text edit action
  late String description;

  // The emoji of this text edit action
  late String emoji;

  // The primary key of this text edit action
  late int textEditActionPk;

  TextEditAction({
    required this.name,
    required this.description,
    required this.emoji,
    required this.textEditActionPk,
  });

  // Constructor to instantiate the text edit action from the json sent from backend
  TextEditAction.fromJson(Map<String, dynamic> data) {
    name = data['name'];
    description = data['description'];
    emoji = data['emoji'];
    textEditActionPk = data['text_edit_action_pk'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'emoji': emoji,
      'text_edit_action_pk': textEditActionPk,
    };
  }
}
