import 'package:dynamic_bridge/logic/views/profile_logic.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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

    ProfileLogic selfLogic = ProfileLogic();
    Map<String, dynamic> data = await selfLogic.getProfileData();

    setState(() {
      name = data["firstName"];
      surname = data["lastName"];
      signupDate = data["createdAt"].toString().substring(0, 10);
      email = data["email"];
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
            onPressed: () {}, // You can add functionality here, e.g., editing profile
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