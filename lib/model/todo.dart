class ToDo {
  String? todoText;
  bool isDone;

  ToDo({
    this.todoText,
    this.isDone = false,
  });

  ToDo.fromMap(Map map)
      : todoText = map["text"],
        isDone = map["isDone"];

  Map toMap() {
    return {
      'text': todoText,
      'isDone': isDone,
    };
  }
}
