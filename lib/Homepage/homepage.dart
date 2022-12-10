import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/todo.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _todoController = TextEditingController();
  List<ToDo> list = <ToDo>[];
  List _foundTodo = [];

  var todoLength;

  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    initSharedPreferences();
    todoLength = list.length;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }

  initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  bool showAdd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfff6f3f0),
      drawer: drawer(),
      appBar: appBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[addButton(), todoTitle(), todoListView()],
          ),
        ),
      ),
    );
  }

  Widget todoTitle() {
    return Container(
      width: double.infinity,
      color: const Color(0xfff6f3f0),
      margin: const EdgeInsets.only(bottom: 20),
      child: Text(
        todoLength == 0
            ? "You have no todos"
            : todoLength == 1
                ? "$todoLength ToDo"
                : "$todoLength ToDos",
        textAlign: todoLength == 0 ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Color(0xff795548)),
      ),
    );
  }

  Widget buildItem(ToDo item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        onTap: () {
          _handleToDoChange(item);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tileColor: Colors.white,
        leading: Icon(
          item.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: const Color(0xff795548),
        ),
        title: Text(
          item.todoText!,
          style: TextStyle(
              fontSize: 16,
              color: const Color(0xff795548),
              decoration: item.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
              color: const Color(0xff795548),
              borderRadius: BorderRadius.circular(5)),
          child: IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            iconSize: 18,
            onPressed: () {
              _deleteToDoItem(item);
            },
          ),
        ),
      ),
    );
  }

  Widget todoListView() {
    if (list.isEmpty) {
      return Expanded(
          child: Column(
        children: [
          const Text(
            "Let's get started and add some todos",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xff795548)),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Press the Plus icon in order to add todos",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xff795548)),
          ),
          const SizedBox(
            height: 50,
          ),
          Image.asset(
            "assets/images/happyFace.png",
            color: const Color(0xff795548),
            height: 100,
            width: 100,
          ),
        ],
      ));
    }
    return Expanded(
      child: ListView.builder(
        itemCount: _foundTodo.length,
        itemBuilder: (context, index) {
          return buildItem(_foundTodo[index]);
        },
      ),
    );
  }

  Widget addButton() {
    return Container(
      color: const Color(0xfff6f3f0),
      height: 80,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: () {
            if (showAdd == true) {
              if (_todoController.text != "") {
                setState(() {
                  _addToDoItem(ToDo(todoText: _todoController.text));
                });
              }
            }
            if (showAdd == false) {
              setState(() {
                showAdd = true;
              });
            }
          },
          child: const Icon(
            Icons.add,
            color: Color(0xff795548),
            size: 40,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 50,
          width: showAdd ? MediaQuery.of(context).size.width * 0.6 : 0,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: _todoController,
              decoration: const InputDecoration(
                hintText: "Add a new todo item",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          ),
        ),
        if (showAdd)
          GestureDetector(
            child: const Icon(
              Icons.cancel,
              color: Color(0xff795548),
              size: 40,
            ),
            onTap: () {
              setState(() {
                FocusScope.of(context).unfocus();
                showAdd = false;
              });
            },
          ),
      ]),
    );
  }

  Widget searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            onChanged: (value) => _runFilter(value),
            decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                contentPadding: const EdgeInsets.all(0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.withOpacity(0.8),
                  size: 20,
                ),
                prefixIconConstraints:
                    const BoxConstraints(maxHeight: 20, minWidth: 25),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      leading: Builder(builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.menu,
            size: 40,
            color: Color(0xff795548),
          ), //icon
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      }),
      title: searchBox(),
      backgroundColor: const Color(0xfff6f3f0),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text("ToDos"),
          ),
          ListTile(
            title: Text("Groceries"),
            onTap: null,
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo item) {
    setState(() {
      item.isDone = !item.isDone;
      saveData();
    });
  }

  void _deleteToDoItem(ToDo item) {
    setState(() {
      list.remove(item);
      _foundTodo.remove(item);
      saveData();
      todoLength = list.length;
    });
  }

  void _addToDoItem(ToDo item) {
    setState(() {
      list.add(item);
      saveData();
      todoLength = list.length;
    });
    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = list;
    } else {
      results = list
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundTodo = results;
    });
  }

  void saveData() {
    List<String> spList =
        list.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
  }

  void loadData() {
    List<String>? spList = sharedPreferences.getStringList("list");
    list = spList!.map((item) => ToDo.fromMap(json.decode(item))).toList();
    _foundTodo = list;
    setState(() {});
  }
}
