class Student {
  int? id;
  String? name;

  Student(this.id, this.name);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }

   Student.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
  }
}
