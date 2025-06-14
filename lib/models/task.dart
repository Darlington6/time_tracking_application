class Task {
  final String id;
  final String name;
  final String projectId;

  Task({required this.id, required this.name, required this.projectId});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'projectId': projectId,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'], 
      projectId: '',
    );
  }
}