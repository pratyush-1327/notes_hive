import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes_hive/boxes/boxes.dart';
import 'package:notes_hive/models/notes_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes with Hive"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ValueListenableBuilder<Box<NotesModel>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<NotesModel>();
          return Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade700,
                      Colors.blue.shade700,
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: box.length,
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 160,
                    child: Card(
                      margin: EdgeInsets.all(10),
                      color: Color.fromARGB(108, 255, 255, 255),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  data[index].title.toString(),
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                InkWell(
                                    onTap: () {
                                      delete(data[index]);
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 206, 16, 2),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                    onTap: () {
                                      _editMyDialog(
                                          data[index],
                                          data[index].title.toString(),
                                          data[index].description.toString());
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      color: Color.fromARGB(255, 124, 33, 243),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              data[index].description.toString(),
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showMyDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add your Note"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        hintText: "Enter Title", border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        hintText: "Enter Desc", border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  )),
              TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty ||
                        descriptionController.text.isNotEmpty) {
                      final data = NotesModel(
                          title: titleController.text,
                          description: descriptionController.text);
                      final box = Boxes.getData();
                      box.add(data);
                      data.save();
                      titleController.clear();
                      descriptionController.clear();
                      Navigator.pop(context);
                      // pop error if empty
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please enter both the fields for your note.'),
                        ),
                      );
                    }
                  },
                  child: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                  ))
            ],
          );
        });
  }

//deelete function
  void delete(NotesModel notesModel) async {
    await notesModel.delete();
  }

//function for editing control
  Future<void> _editMyDialog(
      NotesModel notesModel, String title, String description) async {
    titleController.text = title;
    descriptionController.text = description;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            //pop element
            title: const Text("Edit your note"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        hintText: "Enter Title", border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        hintText: "Enter Title", border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  )),
              TextButton(
                  onPressed: () async {
                    notesModel.title = titleController.text.toString();
                    notesModel.description =
                        descriptionController.text.toString();
                    notesModel.save();
                    titleController.clear();
                    descriptionController.clear();

                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.edit_note,
                    color: Colors.green,
                  ))
            ],
          );
        });
  }
}
