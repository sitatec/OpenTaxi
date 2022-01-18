import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:dio/dio.dart';

const double _registrationFormWidth = 800;
const _nationalitiesCSVUrl =
    "https://gist.githubusercontent.com/sitatec/84ba82abf161cb2115845dc4e47ff03e/raw/0045fb5f54f9ad357e301cf30e23d9834058618a/nationalities.csv";

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({Key? key}) : super(key: key);

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  String _driverId = "";
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(top: 35, bottom: 45),
              //   child: Text(
              //     "Driver Registration",
              //     style: theme.textTheme.headline5?.copyWith(
              //       color: Colors.blue,
              //       fontWeight: FontWeight.bold,
              //       letterSpacing: 1.2,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 50),
              Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < _registrationFormWidth ? 16 : 40,
                    vertical: 40,
                  ),
                  constraints:
                      const BoxConstraints(maxWidth: _registrationFormWidth),
                  child: _DriverRegistrationForm(
                    onSubmitted: (driverId) =>
                        setState(() => _driverId = driverId),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < _registrationFormWidth ? 16 : 40,
                    vertical: 40,
                  ),
                  constraints:
                      const BoxConstraints(maxWidth: _registrationFormWidth),
                  child: _CarRegistrationForm(_driverId),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

const _fndAccountTypes = {
  "Public Recipient": "0",
  "Current (cheque/bond) account": "1",
  "Savings account": "2",
  "Transmission account": "3",
  "Bond Account": "4",
  "Subscription Share Account": "6",
  "eWallet Account (eWallet Pro)": "D",
  "eWallet Account (Send Money)": "S",
  "FNB Card Account": "F",
  "WesBank": "W"
};

const _supportedBanks = [
  'FNB',
  'STANDARD_BANK',
  'NEDBANK',
  'ABSA',
  'CAPITECH',
  'TYME'
];

class _DriverRegistrationForm extends StatefulWidget {
  final void Function(String)? onSubmitted;
  const _DriverRegistrationForm({this.onSubmitted, Key? key}) : super(key: key);

  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

// TODO refactor
class _DriverRegistrationFormState extends State<_DriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSouthAfricanCitizen = true;
  bool _hasAdditionalCertifications = false;
  bool _pictureDropZoneHovered = false;
  DropzoneViewController? _profilePicturePicker;
  String _nationality = "South African";
  var _nationalitiesList = ["South African", "Loading..."];
  String _gender = "";
  String _profilePictureName = "";
  String _documentsFolderDescription = "";
  String _selectedFNDAccountType = _fndAccountTypes.keys.first;
  String _selectedBank = _supportedBanks.first;

  File? _profilePictureFile;
  var _driverDocumentsFolder = <File>[];

  String _profilePictureErrorMessage = "";
  String _documentsFolderErrorMessage = "";
  String _genderErrorMessage = "";

  @override
  initState() {
    super.initState();
    _loadNationalities();
  }

  Future<void> _loadNationalities() async {
    final response = await Dio().get<String>(_nationalitiesCSVUrl);
    setState(() {
      if (response.data != null) {
        _nationalitiesList = response.data!.split(",");
      } else {
        _nationalitiesList = ["Loading failed."];
      }
    });
  }

  late final FileUploadInputElement _folderPicker = FileUploadInputElement()
    ..attributes["webkitdirectory"] = ""
    ..onChange.listen((event) {
      if (_folderPicker.files != null && _folderPicker.files!.isNotEmpty) {
        final files = _folderPicker.files!;
        final splitedPath = files.first.relativePath!.split("/");
        String folderDescription = "The selected folder \"";
        folderDescription += splitedPath.elementAt(splitedPath.length - 2);
        folderDescription += "\" contains ${files.length} files :\n";
        files.forEach((file) {
          // TODO process
          folderDescription += "${file.name},      ";
        });
        // folderDescription.r
        setState(() => _documentsFolderDescription = folderDescription);
      }
    });

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
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("First Names *"),
                  maxLength: 60,
                  validator: (value) {
                    if (value == null || value.length < 2) {
                      return "First Name must contain at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Last Name *"),
                  maxLength: 60,
                  validator: (value) {
                    if (value == null || value.length < 2) {
                      return "Last Name must contain at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Display Name *"),
                  maxLength: 60,
                  validator: (value) {
                    if (value == null || value.length < 2) {
                      return "Display Name must contain at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration(
                      " Date of Birth (yyyy-mm-dd) *", ""),
                  inputFormatters: [MaskedInputFormatter("0000-00-00")],
                  validator: (value) {
                    if (value == null || value.length < 10) {
                      return "Please enter a valid date with this format (yyyy-mm-dd).";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              const Text(
                "Driver Profile Picture *",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(width: 10),
              if (_profilePictureErrorMessage.isNotEmpty)
                Text(
                  _profilePictureErrorMessage,
                  style: const TextStyle(color: Colors.red),
                )
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              SizedBox(
                height: 130,
                child: DropzoneView(
                  mime: const ['image/jpeg', 'image/png'],
                  operation: DragOperation.copy,
                  onCreated: (controller) => _profilePicturePicker = controller,
                  onDrop: (imageFile) {
                    imageFile as File;
                    setState(() {
                      _profilePictureName = imageFile.name;
                      _pictureDropZoneHovered = false;
                      _profilePictureErrorMessage = "";
                    });
                  },
                  onHover: () => setState(() => _pictureDropZoneHovered = true),
                  onLeave: () =>
                      setState(() => _pictureDropZoneHovered = false),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // var mediaData = await ImagePickerWeb.getImageInfo;
                  if (_profilePicturePicker == null) return;
                  var imageFiles = (await _profilePicturePicker!
                      .pickFiles(mime: ['image/jpeg', 'image/png']));
                  if (imageFiles.isEmpty) return;
                  setState(() {
                    _profilePictureName = imageFiles.first.name;
                    _profilePictureErrorMessage = "";
                  });
                },
                style: TextButton.styleFrom(
                  fixedSize: const Size(double.infinity, 130),
                  backgroundColor: Colors.blueGrey[50],
                  primary: Colors.black87,
                ),
                child: Center(
                  child: _pictureDropZoneHovered
                      ? const Text(
                          "Drop Picture Here",
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
                style: const TextStyle(color: Colors.blue),
              ),
            )
          ],
          const SizedBox(height: 40),
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
          const SizedBox(height: 40),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text(
                  "Nationality :",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
              const SizedBox(width: 28),
              DropdownButton<String>(
                value: _nationality,
                onChanged: (newValue) {
                  if (newValue == null) return;
                  setState(() {
                    if (newValue != "Loading..." &&
                        newValue != "Loading failed.") {
                      _nationality = newValue;
                    }
                  });
                },
                items: _nationalitiesList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Email *"),
                  validator: (email) {
                    if (email == null ||
                        !RegExp(emailPattern).hasMatch(email)) {
                      return "Invalid email address.";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("ID/Passport Number *"),
                  validator: (idNumber) {
                    if (idNumber == null || idNumber.length < 5) {
                      return "Minimum 5 caracters.";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Phone Number *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    prefixText: "+27 ",
                  ),
                  inputFormatters: [MaskedInputFormatter("00 000 0000")],
                  validator: (phoneNumber) {
                    if (phoneNumber == null || phoneNumber.length < 11) {
                      return "Please enter 9 digits excluding (+27)";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Alternative Phone Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    prefixText: "+27 ",
                  ),
                  inputFormatters: [MaskedInputFormatter("00 000 0000")],
                  validator: (phoneNumber) {
                    if (phoneNumber == null || phoneNumber.length < 11) {
                      return "Please enter 9 digits excluding (+27)";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              const Text(
                "Gender *",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(width: 10),
              if (_genderErrorMessage.isNotEmpty)
                Text(
                  _genderErrorMessage,
                  style: const TextStyle(color: Colors.red),
                )
            ],
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
          const SizedBox(height: 40),
          const Text(
            "Home Address *",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: _getTextFieldDecoration("Street Address *"),
            validator: (address) {
              if (address == null || address.length < 5) {
                return "Require at least 5 characters.";
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          TextFormField(
            decoration: _getTextFieldDecoration("Street Address Line 2"),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("City *"),
                  validator: (address) {
                    if (address == null || address.length < 2) {
                      return "Require at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Province *"),
                  validator: (address) {
                    if (address == null || address.length < 2) {
                      return "Require at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Postal Code *"),
                  validator: (address) {
                    if (address == null || address.length < 2) {
                      return "Require at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Emergency Contact *",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("First Name  *"),
                  maxLength: 60,
                  validator: (address) {
                    if (address == null || address.length < 2) {
                      return "Require at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Last Name *"),
                  maxLength: 60,
                  validator: (address) {
                    if (address == null || address.length < 2) {
                      return "Require at least 2 characters.";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Emergency Contact Phone Number *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              prefixText: "+27 ",
            ),
            inputFormatters: [MaskedInputFormatter("00 000 0000")],
            validator: (phoneNumber) {
              if (phoneNumber == null || phoneNumber.length < 11) {
                return "Please enter 9 digits excluding (+27)";
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          const Text(
            "Emergency Contact 2",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("First Name"),
                  maxLength: 60,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Last Name"),
                  maxLength: 60,
                  validator: (address) {
                    // TODO check if first name is not empty (which means last is required)
                    // if (address != null && address.length < 2) {
                    //   return "Require at least 2 characters.";
                    // }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Emergency Contact 2 Phone Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              prefixText: "+27 ",
            ),
            inputFormatters: [MaskedInputFormatter("00 000 0000")],
            validator: (phoneNumber) {
              // TODO check if emergency contact 2 first name is not empty.
              // if (phoneNumber != null && phoneNumber.length < 11) {
              //   return "Please enter 9 digits excluding (+27)";
              // }
              return null;
            },
          ),
          const SizedBox(height: 40),
          const Text(
            "Driver's License",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration:
                      _getTextFieldDecoration("Driver's License Number *"),
                  validator: (address) {
                    if (address == null || address.length < 3) {
                      return "Require at least 3 characters.";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration:
                      _getTextFieldDecoration("Driver's License Code *"),
                  validator: (address) {
                    if (address == null || address.isEmpty) {
                      return "Required.";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration(
                      "Driver's License Expiry Date (yyyy-mm-dd) *"),
                  inputFormatters: [MaskedInputFormatter("0000-00-00")],
                  validator: (value) {
                    if (value == null || value.length < 10) {
                      return "Please enter a valid date with this format (yyyy-mm-dd).";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 40),
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
          const SizedBox(height: 40),
          TextFormField(
            decoration: _getTextFieldDecoration(
              "Average ratings for Uber Bolt and Didi",
            ),
            inputFormatters: [MaskedInputFormatter("0.0")],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final rating = double.parse(value);
                if (rating > 5 || rating < 0) return "Minimum 0, Maximum 5.";
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          const Text(
            "Driver's Bank Account Information *",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text(
                  "Bank :",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
              const SizedBox(width: 28),
              DropdownButton<String>(
                value: _selectedBank,
                onChanged: (newValue) {
                  if (newValue == null) return;
                  setState(() => _selectedBank = newValue);
                },
                items: _supportedBanks.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_selectedBank != 'NEDBANK') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: Text(
                    "Account Type :",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 28),
                DropdownButton<String>(
                  value: _selectedFNDAccountType,
                  onChanged: (newValue) {
                    if (newValue == null) return;
                    setState(() => _selectedFNDAccountType = newValue);
                  },
                  items: _fndAccountTypes.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextFormField(
              decoration: _getTextFieldDecoration("Account Holder Name *"),
              validator: (value) {
                if (value == null || value.length < 2) {
                  return "Minimum 2 characters.";
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          maxLength: 20,
                          decoration:
                              _getTextFieldDecoration("Account Number *"),
                          validator: (value) {
                            if (value == null || value.length < 5) {
                              return "Minimum 5 characters.";
                            }
                            return null;
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 18),
                        child: Tooltip(
                          padding: EdgeInsets.all(8),
                          textStyle: TextStyle(color: Colors.white),
                          message:
                              """• If you are making payments to eWallets you must enter the 15 digit eWallet Account number.
The 15 digit eWallet Account number can be any number in the range 000000000000001 to 999999999999999. 
You can enter the given digits and the zeros will be filled automatically.

• If Money is Sent to the recipient's local cellphone number (via Send Money), use the valid
'as is’ cellphone number for the Recipient in the Recipient Account field.""",
                          child: Icon(Icons.info, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          maxLength: 6,
                          decoration: _getTextFieldDecoration("Branch Code *"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Required.";
                            }
                            return null;
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 18),
                        child: Tooltip(
                          padding: EdgeInsets.all(8),
                          textStyle: TextStyle(color: Colors.white),
                          message:
                              "• When importing a Public Recipient, enter the Branch Code 0.\n• When making payments to eWallet recipients, please use the FNB Universal Branch Code: 250655",
                          child: Icon(Icons.info, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (_selectedBank == "NEDBANK") ...[
            const SizedBox(height: 40),
            TextFormField(
              decoration: _getTextFieldDecoration("Account Holder Name *"),
              maxLength: 35,
              validator: (value) {
                if (value == null || value.length < 2) {
                  return "Minimum 2 characters.";
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    decoration: _getTextFieldDecoration("Account Number *", ""),
                    validator: (value) {
                      if (value == null || value.length < 5) {
                        return "Minimum 5 characters.";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: _getTextFieldDecoration("Branch Code *"),
                    maxLength: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required.";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 40),
          Row(
            children: [
              const Text(
                "Driver Documents Folder *",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(width: 10),
              const Tooltip(
                padding: EdgeInsets.all(8),
                textStyle: TextStyle(color: Colors.white),
                message:
                    "Please put all the driver's documents (excluding those specific to his vehicle, and his profile picture) in one folder and upload it.",
                child: Icon(Icons.info, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              if (_documentsFolderErrorMessage.isNotEmpty)
                Text(
                  _documentsFolderErrorMessage,
                  style: const TextStyle(color: Colors.red),
                )
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _folderPicker.click();
            },
            style: TextButton.styleFrom(
              fixedSize: const Size(double.infinity, 130),
              backgroundColor: Colors.blueGrey[50],
              primary: Colors.black87,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.upload_file,
                    size: 32,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Browse Folders",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      "Please click to select a folder, drag and drop is not supported for folders yet."),
                ],
              ),
            ),
          ),
          if (_documentsFolderDescription.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.blueGrey[50]?.withAlpha(150),
              ),
              child: Text(
                _documentsFolderDescription,
                style: const TextStyle(color: Colors.blue, height: 2),
              ),
            )
          ],
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_validateForm()) {
                  // TODO push data
                  widget.onSubmitted?.call("sfs");
                }
              },
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

  bool _validateForm() {
    bool isValidForm = true;
    if (_gender.isEmpty) {
      _genderErrorMessage = "REQUIRED";
      isValidForm = false;
    } else {
      _genderErrorMessage = "";
    }
    if (_profilePictureFile == null) {
      _profilePictureErrorMessage = "REQUIRED";
      isValidForm = false;
    } else {
      _profilePictureErrorMessage = "";
    }
    if (_driverDocumentsFolder.isEmpty) {
      _documentsFolderErrorMessage = "REQUIRED";
      isValidForm = false;
    } else {
      _documentsFolderErrorMessage = "";
    }
    setState(() {});
    return _formKey.currentState!.validate() && isValidForm;
  }
}

const emailPattern =
    r'^(([^<>()[\]\\.,%`~&ç;:\s@\"]+(\.[^<>()[\]\\.,%`~&ç;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,15}))$';

const _carCategories = ["STANDARD", "LITE", "PREMIUM", "CREW", "UBUNTU"];

class _CarRegistrationForm extends StatefulWidget {
  final String driverId;
  const _CarRegistrationForm(this.driverId, {Key? key}) : super(key: key);

  @override
  __CarRegistrationFormState createState() => __CarRegistrationFormState();
}

class __CarRegistrationFormState extends State<_CarRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _vehicleInspectionReport = false;
  bool _hasAssurance = false;
  bool _isSpeedometerOn = false;
  String _selectedCategory = _carCategories.first;
  String _carDocumentsFolderName = "";
  late final FileUploadInputElement _folderPicker = FileUploadInputElement()
    ..attributes["webkitdirectory"] = ""
    ..onChange.listen((event) {
      if (_folderPicker.files != null && _folderPicker.files!.isNotEmpty) {
        final files = _folderPicker.files!;
        final splitedPath = files.first.relativePath!.split("/");
        String folderDescription = "The selected folder \"";
        folderDescription += splitedPath.elementAt(splitedPath.length - 2);
        folderDescription += "\" contains ${files.length} files :\n";
        files.forEach((file) {
          // TODO process
          folderDescription += "${file.name},      ";
        });
        // folderDescription.r
        setState(() => _carDocumentsFolderName = folderDescription);
      }
    });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vehicle Informations",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Vehicle Make *"),
                  maxLength: 50,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Vehicle Model *"),
                  maxLength: 60,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 1),
                      child: Text(
                        "Category :",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 28),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        setState(() => _selectedCategory = newValue);
                      },
                      items: _carCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Color *"),
                  maxLength: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("Vehicle Year *"),
                  inputFormatters: [MaskedInputFormatter("0000")],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration:
                      _getTextFieldDecoration("Vehicle registration Number *"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("VIN Number *"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("License Plate number *"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration("License Disk number *"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: _getTextFieldDecoration(
                      "License Disk Expiry Date (yyyy-mm-dd) *"),
                  inputFormatters: [MaskedInputFormatter("0000-00-00")],
                  validator: (value) {
                    if (value == null || value.length < 10) {
                      return "Please enter a valid date with this format (yyyy-mm-dd).";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Has Vehicle Inspection report? *",
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
                    groupValue: _vehicleInspectionReport,
                    onChanged: (_) =>
                        setState(() => _vehicleInspectionReport = true),
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
                    groupValue: _vehicleInspectionReport,
                    onChanged: (_) =>
                        setState(() => _vehicleInspectionReport = false),
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
          const SizedBox(height: 40),
          const Text(
            "Has Insurance? *",
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
                    groupValue: _hasAssurance,
                    onChanged: (_) => setState(() => _hasAssurance = true),
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
                    groupValue: _hasAssurance,
                    onChanged: (_) => setState(() => _hasAssurance = false),
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
          const SizedBox(height: 40),
          const Text(
            "Speedometer State? *",
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
                    groupValue: _isSpeedometerOn,
                    onChanged: (_) => setState(() => _isSpeedometerOn = true),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "On ",
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
                    groupValue: _isSpeedometerOn,
                    onChanged: (_) => setState(() => _isSpeedometerOn = false),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Off",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: const [
              Text(
                "Vehicle Documents *",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              SizedBox(width: 10),
              Tooltip(
                padding: EdgeInsets.all(8),
                textStyle: TextStyle(color: Colors.white),
                message:
                    "Please put all the vehicle's documents in one folder and upload it.",
                child: Icon(Icons.info, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              _folderPicker.click();
            },
            style: TextButton.styleFrom(
              fixedSize: const Size(double.infinity, 130),
              backgroundColor: Colors.blueGrey[50],
              primary: Colors.black87,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.upload_file,
                    size: 32,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Browse Folders",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      "Please click to select a folder, drag and drop is not supported for folders yet."),
                ],
              ),
            ),
          ),
          if (_carDocumentsFolderName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.blueGrey[50]?.withAlpha(150),
              ),
              child: Text(
                _carDocumentsFolderName,
                style: const TextStyle(color: Colors.blue, height: 2),
              ),
            )
          ],
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: widget.driverId.isEmpty ? null : () {},
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 40)),
                ),
                if (widget.driverId.isEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "You must submit the driver Informations first.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _getTextFieldDecoration(String label, [String? helperText]) =>
    InputDecoration(
      labelText: label,
      helperText: helperText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
