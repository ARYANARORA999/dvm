import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp()); }


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'openSans'),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  var db = FirebaseFirestore.instance;
  List<dynamic> _allUsers =[];
  void callFirebase(int index) async{
    final friend = await FirebaseFirestore.instance.collection('friendList').doc(_foundUsers[index]["name"]).get();

    if (!friend.exists) {
      setState(() {
        _foundUsers[index]['friend'] = !_foundUsers[index]['friend'];
        db
            .collection("friendList")
            .doc(_foundUsers[index]["name"])
            .set(_foundUsers[index])
            .onError((e, _) => print("Error writing document: $e"));
      });
    }
    else{
      setState(() {
        _foundUsers[index]['friend'] = !_foundUsers[index]['friend'];
        db
            .collection("friendList")
            .doc(_foundUsers[index]["name"])
            .delete()
            .then((doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
      });
    }
  }
  void callAPI() async{
    print("main Method");
    String url = "https://jsonplaceholder.typicode.com/users";
    final response = await http.get(Uri.parse(url));
    List<dynamic> dataBase = json.decode(response.body) as List<dynamic>;
    for (var i=0; i < dataBase.length; i++) {
      final friend = await FirebaseFirestore.instance.collection('friendList').doc(dataBase[i]["name"]).get();

      if (!friend.exists)
        dataBase[i]["friend"] = false;
      else
        dataBase[i]["friend"] = true;
    }
    setState(() {
      _allUsers = dataBase;
      _foundUsers = _allUsers;
    });
  }

  // This list holds the data for the list view
  List<dynamic> _foundUsers = [];
  double _currentSliderValue = 200;
  @override
  initState() {

    // at the beginning, all users are shown
    super.initState();
    callAPI();
  }

  // This function is called whenever the text field changes
  void _runFilterSearch(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
          user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState(() {
      _foundUsers = results;
    });
  }

  void _runFilterslide(double value) {
    List<dynamic> results = _allUsers.where((element) => double.parse(element["address"]["geo"]["lng"])<value).toList();

    setState(() {
      _currentSliderValue = value;
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 72, 16, 46),
        decoration:BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage('images/background.png'),
              fit: BoxFit.cover,
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 48,),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.95,1],
                    colors: [Color(0x4DA46C00),Color(0x80D19A08)]
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                onChanged: (value) => _runFilterSearch(value),
                decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Search', prefixIcon: Icon(
                  Icons.search,
                  color:  Color(0xFFC0C0C0),
                )
                ),
              ),
            ),
            SizedBox(height: 10,),
            Slider(
              value: _currentSliderValue,
              max: 200,
              min: -200,
              divisions: 400,
              label: _currentSliderValue.round().toString(),
              onChanged: (value) => _runFilterslide(value),
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 17);
                },
                itemCount: _foundUsers.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => callFirebase(index),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(21, 26, 37, 27),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.95,1],
                          colors: [Color(0x80A46C00),Color(0x80D19A08)]
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _foundUsers[index]["name"],
                          style: TextStyle(
                            color: _foundUsers[index]["friend"] ? Colors.amber : Colors.white,
                          ),
                        ),
                        SizedBox(height: 12,),
                        Text(
                          _foundUsers[index]["email"],
                          style: TextStyle(
                            color: Colors.yellow,
                          ),
                        ),
                        SizedBox(height: 13,),
                        Text(
                          'street: '+_foundUsers[index]["address"]["suite"],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'city: '+_foundUsers[index]["address"]["zipcode"],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 17,),
                        Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Colors.white,
                            ),
                            Text(
                              _foundUsers[index]["address"]["geo"]["lat"],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Icon(
                              Icons.access_time_filled,
                              color: Colors.white,
                            ),
                            Text(
                              _foundUsers[index]["address"]["geo"]["lng"],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
                  : const Text(
                'No results found',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}