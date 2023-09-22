import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Login Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedUsername = prefs.getString('username') ?? '';
    String savedPassword = prefs.getString('password') ?? '';
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    setState(() {
      usernameController.text = savedUsername;
      passwordController.text = savedPassword;
      isChecked = rememberMe;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Användarnamn',
              ),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Lösenord',
              ),
              obscureText: true,
            ),
            CheckboxExample(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (isChecked) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('username', usernameController.text);
                  await prefs.setString('password', passwordController.text);
                  await prefs.setBool('rememberMe', isChecked);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondRoute()),
                );
              },
              child: Text('Logga in'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});

  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  final _dogImageWidgetState = _DogImageWidgetState(); // Skapa en instans av _DogImageWidgetState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DogImageWidget(state: _dogImageWidgetState),
            ),
            ElevatedButton(
              onPressed: () {
                _dogImageWidgetState.fetchNewImage();
              },
              child: const Text('Get New Image'),
            ),
          ],
        ),
      ),
    );
  }
}

class DogImageWidget extends StatefulWidget {
  final _DogImageWidgetState state;

  const DogImageWidget({required this.state, Key? key}) : super(key: key);

  @override
  _DogImageWidgetState createState() => state;

  void fetchNewImage() {
    state.fetchNewImage();
  }
}

class _DogImageWidgetState extends State<DogImageWidget> {
  String? imageUrl;

  Future<String> fetchDogImage() async {
    final response =
    await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final imageUrl = data['message'];
      return imageUrl;
    } else {
      throw Exception('Failed to load dog image');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDogImage().then((image) {
      setState(() {
        imageUrl = image;
      });
    });
  }

  void fetchNewImage() async {
    final newImage = await fetchDogImage();
    setState(() {
      imageUrl = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return imageUrl != null
        ? Image.network(imageUrl!)
        : CircularProgressIndicator();
  }
}

bool isChecked = true;

class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Checkbox(
          checkColor: Colors.white,
          value: isChecked,
          onChanged: (bool? value) async {
            setState(() {
              isChecked = value ?? false;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('rememberMe', isChecked);
          },
        ),
        Text('Remember me'),
      ],
    );
  }
}

