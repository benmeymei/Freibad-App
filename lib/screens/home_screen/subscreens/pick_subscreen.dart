import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:freibad_app/models/weather.dart';
import 'package:freibad_app/services/api_service.dart';

class PickSubscreen extends StatefulWidget {
  @override
  _PickSubscreenState createState() => _PickSubscreenState();
}

class _PickSubscreenState extends State<PickSubscreen> {
  DateTime sessionDate;
  DateTime startTime;
  DateTime endTime;
  Future<List<Weather>> weather;

  @override
  void initState() {
    weather = _setWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: <Widget>[
        FutureBuilder(
            future: weather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print('finished waiting for weather response');
                return getDate(snapshot.data);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                print('waiting for weather response');
                return getDate(null);
              } else {
                //Something went wrong
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Weather not available'),
                    content: Text('Something went wrong ${snapshot.error}'),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'))
                    ],
                  ),
                );
                return getDate(null);
              }
            }),
        getTime(sessionDate),
        //getPerson(),
        RaisedButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.check,
            color: Colors.green,
          ),
          label: Text(
            'Submit',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    ));
  }

  Widget getDate(List<Weather> weatherInfo) {
    double informerHeight = 11.5;
    Color selectedColor = Theme.of(context).primaryColor;
    Color unselectedColor = Colors.white;
    bool hasInformer = weatherInfo != null && weatherInfo.length > 0;
    List<List<Widget>> coloredWeatherInformer = [];
    for (int i = 0; hasInformer && i < weatherInfo.length; i++) {
      coloredWeatherInformer.add(_getWeatherInformer(
          weatherInfo[i].skyIcon,
          '${weatherInfo[i].temp}${weatherInfo[i].tempUnit}',
          informerHeight,
          unselectedColor,
          selectedColor));
    }

    return DatePicker(
      DateTime.now(),
      daysCount: hasInformer ? weatherInfo.length : 15,
      onDateChange: (selectedDate) {
        setState(() {
          sessionDate = selectedDate;
        });
      },
      selectedTextColor: selectedColor,
      unselectedTextColor: Colors.white,
      width: 70,
      selectedBackgroundColor: Theme.of(context).accentColor,
      informerHeight: informerHeight,
      informers: coloredWeatherInformer,
    );
  }

  Widget getTime(DateTime selectedDate) {
    if (selectedDate != null)
      return Column(
        children: APIService.availableTimeBlocks(selectedDate)
            .map((e) => Container(child: Text(e[0].toIso8601String())))
            .toList(),
      );
    else
      return Container();
  }

  Widget getPerson() {
    return null;
  }

  Future<List<Weather>> _setWeather() {
    Future<List<Weather>> tempWeather;
    try {
      tempWeather = APIService.getWeather();
    } catch (exception) {
      throw exception;
    }
    return tempWeather;
  }

  List<Widget> _getWeatherInformer(
      //first item in the list
      IconData skyIcon,
      String temp,
      double size,
      Color passiveColor,
      Color activeColor) {
    return [
      for (int i = 0; i < 2; i++) ...{
        Row(
          children: <Widget>[
            Icon(
              skyIcon,
              color: i == 0 ? passiveColor : activeColor,
              size: size,
            ),
            Text(
              temp,
              style: TextStyle(
                  fontSize: size, color: i == 0 ? passiveColor : activeColor),
            ),
          ],
        ),
      }
    ];
  }
}
