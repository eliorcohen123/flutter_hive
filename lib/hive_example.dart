import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterhive/person_model.dart';
import 'package:flutterhive/person_model_adapter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveExample extends StatefulWidget {
  @override
  _HiveExampleState createState() => _HiveExampleState();
}

class _HiveExampleState extends State<HiveExample> {
  Box _personBox;

  @override
  void initState() {
    super.initState();

    Hive.registerAdapter(PersonModelAdapter());
    _openBox();
  }

  Future _openBox() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _personBox = await Hive.openBox('personBox');
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive example"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text("Add"),
                onPressed: () {
                  _addPerson();
                },
              ),
              FlatButton(
                child: Text("Delete Data"),
                onPressed: () {
                  _deleteAllPersons();
                },
              ),
            ],
          ),
          _personBox == null
              ? Text("Box is not initialized")
              : Expanded(
                  child: WatchBoxBuilder(
                    box: _personBox,
                    builder: (context, box) {
                      Map<dynamic, dynamic> raw = box.toMap();
                      List list = raw.values.toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, position) {
                          PersonModel personModel = list[position];
                          return ListTile(
                            title: Text(personModel.name),
                            subtitle: Text(personModel.age.toString()),
                            onTap: () => _updatePerson(position),
                            onLongPress: () => _deletePerson(position),
                          );
                        },
                      );
                    },
                  ),
                )
        ],
      ),
    );
  }

  void _addPerson() async {
    PersonModel personModel = PersonModel(Random().nextInt(100), "John", 23);
    _personBox.add(personModel);
  }

  void _updatePerson(int position) async {
    PersonModel personModel = _personBox.values.toList()[position];
    personModel.name = 'Tom';
    personModel.age = 24;
    _personBox.putAt(position, personModel);
  }

  void _deletePerson(int position) async {
    _personBox.deleteAt(position);
  }

  void _deleteAllPersons() async {
    _personBox.clear();
  }
}
