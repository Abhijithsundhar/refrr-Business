import 'package:flutter/material.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';

class AddNewPage extends StatelessWidget {
  const AddNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture Section (grey background)
            Container(
              color: const Color(0xFFF5F5F5),
              child: Column(
                children: [
                  SizedBox(height: height * 0.01),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.add, size: 19, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  const Text(
                    "Add Profile Picture",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  SizedBox(height: 18),
                ],
              ),
            ),
            // White background for form section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 0),
              child: Column(
                children: [
                  _buildLabeledTextField("Name"),
                  _buildLabeledTextField("Location"),
                  _buildLabeledTextField("Phone NO", keyboardType: TextInputType.phone),
                  _buildLabeledTextField("Email ID", keyboardType: TextInputType.emailAddress),
                  _buildLabeledDropdownField("Industry"),
                  _buildLabeledTextField("Qualification"),
                  _buildLabeledTextField("Experience"),
                  _buildLabeledTextField("More Info", maxLines: 3),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F3F3), // light grey
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            items: const [
              DropdownMenuItem(value: "IT", child: Text("IT")),
              DropdownMenuItem(value: "Finance", child: Text("Finance")),
              DropdownMenuItem(value: "Marketing", child: Text("Marketing")),
            ],
            onChanged: (value) {},
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F3F3), // light grey
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
