import 'package:flutter/material.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/provider/session_data.dart';
import 'package:freibad_app/screens/home_screen/components/custom_textField.dart';
import 'package:provider/provider.dart';

class PersonDetailDialog extends StatefulWidget {
  final String personId;
  final bool canEdit;
  final bool hasPerson;
  PersonDetailDialog({
    this.personId,
    this.canEdit = false,
  }) : hasPerson = personId != null {
    if (!hasPerson && canEdit == false) {
      throw 'Must provide at least a person or make PersonDetailDialog editable to work';
    }
  }
  @override
  _PersonDetailDialogState createState() => _PersonDetailDialogState();
}

class _PersonDetailDialogState extends State<PersonDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isInit = true;
  Person person;
  TextEditingController forenameController;
  TextEditingController nameController;
  TextEditingController streetNameController;
  TextEditingController streetNumberController;
  TextEditingController postCodeController;
  TextEditingController cityController;
  TextEditingController phoneNumberController;
  TextEditingController emailController;

  @override
  void didChangeDependencies() {
    if (isInit) {
      if (widget.hasPerson) {
        person = Provider.of<SessionData>(context, listen: false)
            .findPersonById(widget.personId);
      }
      forenameController = TextEditingController(
        text: widget.hasPerson ? person.forename : '',
      );
      nameController = TextEditingController(
        text: widget.hasPerson ? person.name : '',
      );
      streetNameController = TextEditingController(
        text: widget.hasPerson ? person.streetName : '',
      );
      streetNumberController = TextEditingController(
        text: widget.hasPerson ? person.streetNumber : '',
      );
      postCodeController = TextEditingController(
        text: widget.hasPerson ? person.postcode.toString() : '',
      );
      cityController = TextEditingController(
        text: widget.hasPerson ? person.city : '',
      );
      phoneNumberController = TextEditingController(
        text: widget.hasPerson ? person.phoneNumber : '',
      );
      emailController = TextEditingController(
        text: widget.hasPerson ? person.email : '',
      );
      isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    forenameController.dispose();
    nameController.dispose();
    streetNameController.dispose();
    streetNumberController.dispose();
    postCodeController.dispose();
    cityController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8),
          width: 300,
          height: 430,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).dialogBackgroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (widget.canEdit)
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 28,
                      ),
                    Text(
                      widget.hasPerson ? '${person.forename}' : 'Person',
                      style: TextStyle(fontSize: 28),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 120,
                              child: CustomTextField(
                                labelText: 'forename',
                                controller: forenameController,
                                readOnly: !widget.canEdit,
                              ),
                            ),
                            Container(
                              width: 120,
                              child: CustomTextField(
                                labelText: 'name',
                                controller: nameController,
                                readOnly: !widget.canEdit,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 120,
                              child: CustomTextField(
                                labelText: 'street number',
                                controller: streetNumberController,
                                readOnly: !widget.canEdit,
                              ),
                            ),
                            Container(
                              width: 120,
                              child: CustomTextField(
                                labelText: 'street name',
                                controller: streetNameController,
                                readOnly: !widget.canEdit,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 120,
                              child: CustomTextField(
                                labelText: 'post code',
                                controller: postCodeController,
                                readOnly: !widget.canEdit,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (int.tryParse(val) == null) {
                                    return 'Must be a number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              width: 120,
                              child: CustomTextField(
                                labelText: 'city name',
                                controller: cityController,
                                readOnly: !widget.canEdit,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 260,
                          child: CustomTextField(
                            labelText: 'email',
                            controller: emailController,
                            readOnly: !widget.canEdit,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        Container(
                          width: 260,
                          child: CustomTextField(
                            labelText: 'telephone number',
                            controller: phoneNumberController,
                            readOnly: !widget.canEdit,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        if (widget.canEdit)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if (widget.hasPerson)
                                    Provider.of<SessionData>(context,
                                            listen: false)
                                        .updatePerson(
                                      id: person.id,
                                      city: cityController.text,
                                      email: emailController.text,
                                      forename: forenameController.text,
                                      name: nameController.text,
                                      phoneNumber: phoneNumberController.text,
                                      postcode:
                                          int.parse(postCodeController.text),
                                      streetName: streetNameController.text,
                                      streetNumber: streetNumberController.text,
                                    );
                                  else
                                    Provider.of<SessionData>(context,
                                            listen: false)
                                        .addPerson(
                                      city: cityController.text,
                                      email: emailController.text,
                                      forename: forenameController.text,
                                      name: nameController.text,
                                      phoneNumber: phoneNumberController.text,
                                      postcode:
                                          int.parse(postCodeController.text),
                                      streetName: streetNameController.text,
                                      streetNumber: streetNumberController.text,
                                    );
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text('Submit'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
