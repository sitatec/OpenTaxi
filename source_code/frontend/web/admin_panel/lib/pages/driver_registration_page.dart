import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

const double _registrationFormWidth = 800;

class DriverRegistrationPage extends StatelessWidget {
  const DriverRegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hamba Admin"),
        foregroundColor: Colors.black,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35, bottom: 45),
                child: Text(
                  "DRIVER REGISTRATION",
                  style: theme.textTheme.headline5?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < _registrationFormWidth ? 16 : 40,
                    vertical: 40,
                  ),
                  constraints:
                      const BoxConstraints(maxWidth: _registrationFormWidth),
                  child: const _DriverRegistrationForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverRegistrationForm extends StatefulWidget {
  const _DriverRegistrationForm({Key? key}) : super(key: key);

  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<_DriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSouthAfricanCitizen = true;
  bool _hasAdditionalCertifications = false;
  bool _dropZoneHovered = false;
  DropzoneViewController? _filePicker;
  String? _nationality;
  String _gender = "";
  String _profilePictureName = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Driver Informations",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("First Names *"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Last Name *"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                    decoration: _getTextFieldDecoration("Display Name *")),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration:
                      _getTextFieldDecoration(" Date of Birth (yyyy-mm-dd) *"),
                  inputFormatters: [MaskedInputFormatter("0000-00-00")],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Driver Profile Picture *",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              SizedBox(
                height: 130,
                child: DropzoneView(
                  mime: const ['image/jpeg', 'image/png'],
                  operation: DragOperation.copy,
                  onCreated: (controller) => _filePicker = controller,
                  onDrop: (imageFile) {
                    imageFile as File;
                    setState(() {
                      _profilePictureName = imageFile.name;
                      _dropZoneHovered = false;
                    });
                  },
                  onHover: () => setState(() => _dropZoneHovered = true),
                  onLeave: () => setState(() => _dropZoneHovered = false),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // var mediaData = await ImagePickerWeb.getImageInfo;
                  if (_filePicker == null) return;
                  File imageFile = (await _filePicker!
                          .pickFiles(mime: ['image/jpeg', 'image/png']))
                      .first;
                  setState(() => _profilePictureName = imageFile.name);
                },
                style: TextButton.styleFrom(
                  fixedSize: const Size(double.infinity, 130),
                  backgroundColor: Colors.blueGrey[50],
                  primary: Colors.black87,
                ),
                child: Center(
                  child: _dropZoneHovered
                      ? const Text(
                          "Drop Here",
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.upload_file,
                              size: 32,
                              color: Colors.black87,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Browse Files",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text("Drag and drop picture here."),
                          ],
                        ),
                ),
              ),
            ],
          ),
          if (_profilePictureName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.blueGrey[50],
              ),
              child: Text(
                _profilePictureName,
                style: TextStyle(color: Colors.blue),
              ),
            )
          ],
          const SizedBox(height: 32),
          const Text(
            "Is The Driver a South African citizen? *",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Radio(
                    value: true,
                    groupValue: _isSouthAfricanCitizen,
                    onChanged: (_) =>
                        setState(() => _isSouthAfricanCitizen = true),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Yes",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Radio(
                    value: false,
                    groupValue: _isSouthAfricanCitizen,
                    onChanged: (_) =>
                        setState(() => _isSouthAfricanCitizen = false),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "No ",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("ID/Passport Number *"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: TextEditingController(
                      text: _isSouthAfricanCitizen &&
                              (_nationality?.isEmpty ?? true)
                          ? "South African"
                          : _nationality),
                  decoration: _getTextFieldDecoration("Nationality *"),
                  onChanged: (newValue) => _nationality = newValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Email *"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Phone Number *"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration:
                      _getTextFieldDecoration("Alternative Phone Number"),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Gender *",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Radio(
                    value: "MALE",
                    groupValue: _gender,
                    onChanged: (_) => setState(() => _gender = "MALE"),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Male",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Radio(
                    value: "FEMALE",
                    groupValue: _gender,
                    onChanged: (_) => setState(() => _gender = "FEMALE"),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Female",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          TextFormField(
            decoration: _getTextFieldDecoration("Home Address *"),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration:
                      _getTextFieldDecoration("Driver's License Number *"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration:
                      _getTextFieldDecoration("Driver's License Code *"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration(
                      "Driver's License Expiry Date (yyyy-mm-dd) *"),
                  inputFormatters: [MaskedInputFormatter("0000-00-00")],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration(
                      "Average ratings for Uber Bolt and Didi"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Does the Driver has Additional Certifications? *",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Radio(
                    value: true,
                    groupValue: _hasAdditionalCertifications,
                    onChanged: (_) =>
                        setState(() => _hasAdditionalCertifications = true),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Yes",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Radio(
                    value: false,
                    groupValue: _hasAdditionalCertifications,
                    onChanged: (_) =>
                        setState(() => _hasAdditionalCertifications = false),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "No ",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                "SUBMIT",
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  elevation: 10,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 40)),
            ),
          )
        ],
      ),
    );
  }
}

InputDecoration _getTextFieldDecoration(String label) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
