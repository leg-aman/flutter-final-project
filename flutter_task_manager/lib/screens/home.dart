import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task_manager/constants/colors.dart';
import 'package:flutter_task_manager/widgets/todo_item.dart';
import 'package:flutter_task_manager/model/todo.dart';
import 'package:flutter_task_manager/pages/auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/weather_model.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  final _database = FirebaseDatabase.instance.ref();

  Weather? _currentWeather;

  @override
  void initState() {
    _foundToDo = todosList;
    _fetchWeatherData(); // Fetch the weather data when the widget initializes
    super.initState();
  }

  // Method to fetch weather data from the API
  Future<void> _fetchWeatherData() async {
    final apiKey = 'd2ca49b95cc74ff79b015145231707';
    final city = 'atlanta'; // Replace with your desired city name
    final apiUrl =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          final description = data['current']['condition']['text'];
          final temperature = data['current']['temp_c'];

          setState(() {
            _currentWeather =
                Weather(description: description, temperature: temperature);
          });
        } else {
          print('Error: Data is null');
        }
      } else {
        print('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 50,
                          bottom: 50,
                        ),
                        child: const Text(
                          'All To Dos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todoo in _foundToDo)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: (todo) =>
                              _handleToDoChanged(todo, todoo.id!),
                          onDeleteItem: () => _deleteToDoItem(todoo.id!),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _addToDoItem(_todoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdBlue,
                      minimumSize: const Size(60, 60),
                      elevation: 10,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChanged(ToDo todo, String id) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    // Update the item in the Firebase Realtime Database
    _database.child('todos').child(id).update({
      'isDone': todo.isDone,
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
    });

    // Remove the item from the Firebase Realtime Database
    _database.child('todos').child(id).remove();
  }

  void _addToDoItem(String todo) {
    setState(() {
      final newToDo = ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: todo,
        isDone: false,
      );
      todosList.add(newToDo);
    });
    _todoController.clear();

    // Save the new todo item to the Firebase Realtime Database
    final newToDoRef = _database.child('todos').push();
    newToDoRef.set({
      'id': newToDoRef.key,
      'todoText': todo,
      'isDone': false,
    });
  }

  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      setState(() {
        _foundToDo = List.from(todosList);
      });
    } else {
      final results = todosList.where((item) =>
          item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase()));
      setState(() {
        _foundToDo = List.from(results);
      });
    }
  }

  Container searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      margin: const EdgeInsets.only(left: 15, right: 15),
      child: const TextField(
        //  onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentWeather != null) // Display weather if available
            Text(
              '${_currentWeather!.temperature.toStringAsFixed(1)}°C, ${_currentWeather!.description}',
              style: TextStyle(fontSize: 16, color: tdBlack),
            ),
          // You can add additional app bar content here if needed
        ],
      ),
      backgroundColor: tdBGColor,
      iconTheme: IconThemeData(color: tdBlack),
    );
  }

  Drawer _buildDrawer() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: tdBGColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YXZhdGFyfGVufDB8fDB8fHww&w=1000&q=80'),
                ),
                SizedBox(height: 4),
                // Text(
                //   currentUser?.displayName ?? 'User Name',
                //   style: TextStyle(
                //     color: tdBlack,
                //     fontSize: 24,
                //   ),
                // ),
                SizedBox(height: 4),
                Text(
                  currentUser?.email ?? '',
                  style: TextStyle(
                    color: tdBlack,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Sign Out'),
            leading: const Icon(
              Icons.logout,
              color: tdBlue,
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              //  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    // await Auth().signOut();
    await FirebaseAuth.instance.signOut();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}
