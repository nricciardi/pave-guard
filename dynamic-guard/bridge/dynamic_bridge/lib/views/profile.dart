import 'package:dynamic_bridge/logic/user_data_manager.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final MeData selfData;
  const ProfilePage({super.key, required this.selfData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String surname = "";
  String signupDate = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {

    MeData data = widget.selfData;

    setState(() {
      name = data.getFirstName();
      surname = data.getLastName();
      signupDate = data.getCreatedAt();
      email = data.getEmail();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 30),
            onPressed: (){},
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Name: $name",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Surname: $surname",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Signup Date: $signupDate",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Email: $email",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}