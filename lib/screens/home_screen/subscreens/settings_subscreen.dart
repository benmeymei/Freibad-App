import 'package:flutter/material.dart';
import 'package:freibad_app/licensing/licenses.dart';
import 'package:freibad_app/provider/auth_data.dart';
import 'package:freibad_app/provider/settings.dart';
import 'package:provider/provider.dart';

class SettingsSubscreen extends StatefulWidget {
  @override
  _SettingsSubscreenState createState() => _SettingsSubscreenState();
}

class _SettingsSubscreenState extends State<SettingsSubscreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SizedBox(
          width: 160,
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () {
                  addLicenses();
                  showAboutDialog(
                    context: context,
                    applicationName: "Freibad-App",
                    applicationVersion: "1.0.0",
                    applicationIcon: Image.asset(
                      'assets/icon/swimming-pool.png',
                      width: 40,
                      height: 40,
                    ),
                    children: [
                      Text(
                        "Created by Ben Meyer-Meisel",
                      ),
                    ],
                  );
                },
                child: Text(
                  'More Info',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Freibad-Server'),
                  Switch.adaptive(
                    activeColor: Theme.of(context).primaryColor,
                    value: Provider.of<Settings>(context).useServer,
                    onChanged: (value) {
                      Provider.of<Settings>(context, listen: false).useServer =
                          value;
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weather-API'),
                  Switch.adaptive(
                    activeColor: Theme.of(context).primaryColor,
                    value: Provider.of<Settings>(context, listen: false)
                        .useWeatherAPI,
                    onChanged: (value) {
                      Provider.of<Settings>(context, listen: false)
                          .useWeatherAPI = value;
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Storage-Service"),
                  Switch.adaptive(
                    activeColor: Theme.of(context).primaryColor,
                    value: Provider.of<Settings>(context, listen: false)
                        .useStorageService,
                    onChanged: (value) {
                      Provider.of<Settings>(context, listen: false)
                          .useStorageService = value;
                    },
                  )
                ],
              ),
              RaisedButton(
                onPressed: () async {
                  await Provider.of<AuthData>(context, listen: false).logout();
                },
                child: Text(
                  'Logout',
                  style: TextStyle(color: Theme.of(context).cardColor),
                ),
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
