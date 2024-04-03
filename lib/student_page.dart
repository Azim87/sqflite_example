import 'package:flutter/material.dart';
import 'package:sqflites/db/database.dart';

import 'model/student.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  late Future<List<Student>> _studentList;
  String? _name;
  bool isUpdate = false;
  int? studentIdForUpdate;

  @override
  void initState() {
    updateStudentList();
  }

  updateStudentList() {
    setState(() {
      _studentList = DBProvider.db.getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD Demo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Form(
            key: _formStateKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null) {
                        return 'Please Enter Student Name';
                      }
                      if (value.trim() == "") {
                        return "Only Space is Not Valid!!!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value;
                    },
                    controller: _studentNameController,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent, width: 2, style: BorderStyle.solid),
                      ),
                      labelText: "Student Name",
                      icon: Icon(
                        Icons.people,
                        color: Colors.black,
                      ),
                      fillColor: Colors.white,
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                // color: Colors.green,
                child: Text(
                  isUpdate ? 'UPDATE' : 'ADD',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (isUpdate) {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      DBProvider.db.updateStudent(Student(studentIdForUpdate, _name)).then((_) {
                        setState(() {
                          isUpdate = false;
                        });
                      });
                    }
                  } else {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      DBProvider.db.insertStudent(Student(null, _name));
                    }
                  }
                  _studentNameController.text = '';
                  updateStudentList();
                },
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  isUpdate ? 'CANCEL UPDATE' : 'CLEAR',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _studentNameController.text = '';
                  setState(() {
                    isUpdate = false;
                    studentIdForUpdate = null;
                  });
                },
              ),
            ],
          ),
          const Divider(
            height: 5.0,
          ),
          Expanded(
            child: FutureBuilder(
              future: _studentList,
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  return generateList(snapshot.data as List<Student>);
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Text('No data has found!');
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView generateList(List<Student> st) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Delete')),
          ],
          rows: st
              .map(
                (student) => DataRow(
                  cells: [
                    DataCell(
                      Text(student.name!),
                      onTap: () {
                        setState(() {
                          isUpdate = true;
                          studentIdForUpdate = student.id;
                        });
                        _studentNameController.text = student.name!;
                      },
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          DBProvider.db.deleteStudent(student.id!);
                          updateStudentList();
                        },
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
