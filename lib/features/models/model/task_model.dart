class TaskModel {
  int? id;
  String title;
  String? description;
  DateTime dueDate;
  int status;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.status = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['dueDate'] as String),
      status: map['status'] as int,
    );
  }
}
