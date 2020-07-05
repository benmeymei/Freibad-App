import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/weather.dart';
import 'package:freibad_app/provider/local_data.dart';
import 'package:freibad_app/provider/weather_data.dart';

import 'package:freibad_app/screens/home_screen/components/person_detail_dialog.dart';
import 'package:freibad_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PickSubscreen extends StatefulWidget {
  @override
  _PickSubscreenState createState() => _PickSubscreenState();
}

class _PickSubscreenState extends State<PickSubscreen> {
  DateTime sessionDate;
  DateTime startTime;
  List<Person> selectedPersons = [];
  Map<DateTime, Weather> cachedWeather;
  DateTime currentMaxTempDateTime;

  @override
  Widget build(BuildContext context) {
    if (sessionDate != null && cachedWeather != null) {
      currentMaxTempDateTime = cachedWeather[sessionDate].maxTempTime;
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FutureBuilder(
              initialData: cachedWeather,
              future: Provider.of<WeatherData>(context, listen: false)
                  .getWeatherForecast(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.done)
                    cachedWeather = snapshot.data;

                  return buildDateSelector(snapshot.data);
                } else if (snapshot.hasError) {
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
                }
                return buildDateSelector(cachedWeather);
              },
            ),
            buildTimeSelector(sessionDate, maxTemp: currentMaxTempDateTime),
            buildPersonSelector(context),
            RaisedButton.icon(
              onPressed: () {},
              color: Theme.of(context).cardColor,
              icon: Icon(
                Icons.check,
                color: Theme.of(context).primaryColor,
              ),
              label: Text(
                'Submit',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateSelector(Map<DateTime, Weather> weatherForecast) {
    bool hasWeather = weatherForecast != null && weatherForecast.length > 0;

    double dateInfoWidgetHeight = 11.5;

    Color selectedColor = Theme.of(context).primaryColor;
    Color unselectedColor = Colors.white;

    Map<DateTime, Widget> selectedDateInfo = {};
    Map<DateTime, Widget> unselectedDateInfo = {};

    if (hasWeather)
      weatherForecast.forEach(
        (date, dailyWeatherForecast) {
          selectedDateInfo.putIfAbsent(
            date,
            () => _getWeatherWidget(
              dailyWeatherForecast.skyIcon,
              '${dailyWeatherForecast.maxTemp} ${dailyWeatherForecast.tempUnit}',
              dateInfoWidgetHeight,
              selectedColor,
            ),
          );
          unselectedDateInfo.putIfAbsent(
            date,
            () => _getWeatherWidget(
              dailyWeatherForecast.skyIcon,
              '${dailyWeatherForecast.maxTemp} ${dailyWeatherForecast.tempUnit}',
              dateInfoWidgetHeight,
              unselectedColor,
            ),
          );
        },
      );

    return DatePicker(
      DateTime.now(),
      key: ObjectKey(
          cachedWeather), //TODO figure out why UniqueKey does not work here? ;)
      daysCount: hasWeather ? weatherForecast.length : 15,
      onDateChange: (selectedDate) {
        setState(
          () {
            startTime = null;
            sessionDate = selectedDate;
          },
        );
      },
      selectedTextColor: selectedColor,
      unselectedTextColor: Colors.white,
      selectedBackgroundColor: Colors.transparent,
      height: 90,
      width: 75,
      dateInfoHeight: dateInfoWidgetHeight,
      unselectedDateInfo: unselectedDateInfo,
      selectedDateInfo: selectedDateInfo,
    );
  }

  Widget buildTimeSelector(DateTime selectedDate, {DateTime maxTemp}) {
    if (selectedDate != null) {
      List<List<DateTime>> timeBlocks =
          APIService.availableTimeBlocks(selectedDate);

      //find time closest to the best weather
      DateTime bestStartTime;
      if (maxTemp != null) {
        Duration shortestGap;
        for (List<DateTime> timeBlock in timeBlocks) {
          for (DateTime time in timeBlock) {
            Duration timeDifference = time.difference(maxTemp).abs();
            if (shortestGap == null) {
              shortestGap = timeDifference;
              bestStartTime = timeBlock[0];
            } else if (shortestGap > timeDifference) {
              shortestGap = timeDifference;
              bestStartTime = timeBlock[0];
            }
          }
        }
        //developer.log('$bestStartTime recommended session start time for maxTemp: $maxTemp (according to the ClimaCellApi)');
      }
      return Column(
        children: timeBlocks
            .map(
              (time) => SizedBox(
                width: double.infinity,
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      startTime = time[0];
                    });
                  },
                  textColor:
                      startTime != null && startTime.compareTo(time[0]) == 0
                          ? Theme.of(context).primaryColor
                          : time[0] == bestStartTime
                              ? Theme.of(context).primaryColor.withOpacity(0.5)
                              : Colors.white,
                  child: Text(
                    '${DateFormat.Hm().format(time[0])} - ${DateFormat.Hm().format(time[1])}',
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else
      return Container();
  }

  Widget buildPersonSelector(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => buildSelectPersonDialog(context),
              );
            },
          ),
        ),
        ...selectedPersons.map(
          (person) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.all(8),
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('${person.forename} ${person.name}'),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          selectedPersons.remove(person);
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  SimpleDialog buildSelectPersonDialog(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Theme.of(context).cardColor,
      children: [
        IconButton(
          icon: Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => PersonDetailDialog(
                canEdit: true,
                personId: null,
              ),
            );
          },
        ),
        ...Provider.of<LocalData>(context).persons.map(
          (person) {
            if (!selectedPersons.contains(person)) {
              return InkWell(
                onTap: () {
                  setState(
                    () {
                      selectedPersons.add(person);
                    },
                  );
                  Navigator.pop(context);
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => PersonDetailDialog(
                      canEdit: true,
                      personId: person.id,
                    ),
                  );
                },
                child: SizedBox(
                  height: 35,
                  child: Center(
                    child: Text(
                      '${person.forename} ${person.name}',
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }

  Widget _getWeatherWidget(
      IconData skyIcon, String temp, double size, Color color) {
    return Row(
      children: <Widget>[
        Icon(
          skyIcon,
          color: color,
          size: size,
        ),
        Text(
          temp,
          style: TextStyle(fontSize: size, color: color),
        ),
      ],
    );
  }
}
