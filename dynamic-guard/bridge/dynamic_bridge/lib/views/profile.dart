import 'package:dynamic_bridge/logic/user_data_manager.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final MeData selfData;
  const ProfilePage({super.key, required this.selfData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5), // Shadow position
            ),
          ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileField(label: "Name", value: name),
            const Divider(),
            ProfileField(label: "Surname", value: surname),
            const Divider(),
            ProfileField(label: "Signup Date", value: signupDate),
            const Divider(),
            ProfileField(label: "Email", value: email),
            ],
          ),
        ),
      ),
    );
  }
}