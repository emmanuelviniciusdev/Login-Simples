import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Authentication'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var wrongCredentials = false;

  Future<bool> _checkIfUserExists(Database db, String username,
      String password) async {
    final selectUser = await db.query(
        'tb_user',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password]
    );

    return selectUser.isNotEmpty;
  }

  /// Allowed user credentials:
  ///
  /// username: emmanuel
  ///
  /// password: emmanuel123
  Future<void> _createAllowedUserIfNotExists(Database db) async {
    final userAlreadyExists = await _checkIfUserExists(
        db, 'emmanuel', 'emmanuel123');

    if (userAlreadyExists) {
      return;
    }

    await db.insert('tb_user', {
      'username': 'emmanuel',
      'password': 'emmanuel123'
    });
  }

  Future<Database> get database async {
    return openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tb_user (
            id INTEGER PRIMARY KEY,
            username TEXT,
            password TEXT
          );
        ''');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (wrongCredentials) const Text('Wrong credentials.' ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username'
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password'
                ),
                obscureText: true,
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    final databaseConnection = await database;

                    await _createAllowedUserIfNotExists(databaseConnection);

                    var username = usernameController.text;
                    var password = passwordController.text;

                    final userCredentialsAreValid = await _checkIfUserExists(
                        databaseConnection, username, password);

                    if (userCredentialsAreValid) {
                      setState(() {
                        wrongCredentials = false;
                      });

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage(username: username)
                          )
                      );

                      return;
                    }

                    setState(() {
                      wrongCredentials = true;
                    });
                  },
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}


