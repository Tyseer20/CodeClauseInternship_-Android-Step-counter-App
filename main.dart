import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  runApp(PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
    );
  }
}

class Credential {
  String title;
  String username;
  String encryptedPassword;

  Credential({
    required this.title,
    required this.username,
    required this.encryptedPassword,
  });
}

class EncryptionService {
  static String encrypt(String input) {
    final key = utf8.encode("super_secret_key");
    final bytes = utf8.encode(input);
    final hmacSha256 = Hmac(sha256, key);
    return base64.encode(hmacSha256.convert(bytes).bytes);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Credential> credentials = [];

  void _addCredential() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditScreen()),
    );

    if (result != null && result is Credential) {
      setState(() {
        credentials.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password Manager")),
      body: credentials.isEmpty
          ? Center(child: Text("No passwords saved yet."))
          : ListView.builder(
              itemCount: credentials.length,
              itemBuilder: (context, index) {
                final cred = credentials[index];
                return ListTile(
                  title: Text(cred.title),
                  subtitle: Text("Username: ${cred.username}"),
                  trailing: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Password copied (encrypted)!")));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCredential,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddEditScreen extends StatefulWidget {
  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Credential")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Site/App Name'),
              onChanged: (val) => title = val,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (val) => username = val,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (val) => password = val,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final encrypted = EncryptionService.encrypt(password);
                  final cred = Credential(
                      title: title,
                      username: username,
                      encryptedPassword: encrypted);
                  Navigator.pop(context, cred);
                }
              },
              child: Text("Save"),
            )
          ]),
        ),
      ),
    );
  }
}
