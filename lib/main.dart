import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/scheduler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<charts.Series> seriesList;
  charts.TimeSeriesChart _chart;

  int _lpwm = 10;
  String _set = "15-05";
  int _pwm0 = 100;
  String _time1 = "20-00";
  int _pwm1 = 100;
  String _time2 = "21-30";
  int _pwm2 = 50;
  String _time3 = "03-00";
  int _pwm3 = 70;
  String _time4 = "04-00";
  int _pwm4 = 100;
  String _rise = "04-21";

  DateTime _sliderDomainValue;

  @override
  Widget build(BuildContext context) {
    seriesList = _createSampleData();
    _chart = charts.TimeSeriesChart(
      seriesList,
      animate: false,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      defaultInteractions: true,
      defaultRenderer: charts.LineRendererConfig(includePoints: true),
      domainAxis: charts.DateTimeAxisSpec(
          tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
            day: charts.TimeFormatterSpec(format: "HH:mm", transitionFormat: "HH:mm"),
            hour: charts.TimeFormatterSpec(format: "HH:mm", transitionFormat: "HH:mm"),
            minute: charts.TimeFormatterSpec(format: "HH:mm", transitionFormat: "HH:mm"),
          )
      ),
      behaviors: [
        charts.LinePointHighlighter(
            showHorizontalFollowLine:
            charts.LinePointHighlighterFollowLineType.all,
            showVerticalFollowLine:
            charts.LinePointHighlighterFollowLineType.all),
        /*charts.SelectNearest(
                eventTrigger: charts.SelectionTrigger.tapAndDrag),*/
        charts.Slider(initialDomainValue: DateTime(1970,1,2,0,0), onChangeCallback: _onSliderChange)
      ],
    );

    final children = <Widget>[
      new SizedBox(
        height: 180.0,
        child: _chart,
      )
    ];

    if (_sliderDomainValue != null) {
      children.add(new Padding(
          padding: new EdgeInsets.only(top: 5.0),
          child: new Text('Slider domain value: ${_sliderDomainValue.hour.toString().padLeft(2,"0")}:${_sliderDomainValue.minute.toString().padLeft(2,"0")}')));
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: children,
        )
      ),
    );
  }

  _onSliderChange(Point<int> point, dynamic domain, String roleId, charts.SliderListenerDragState dragState) {
    void rebuild(_) {
      setState(() {
        _sliderDomainValue = domain;
      });
    }

    SchedulerBinding.instance.addPostFrameCallback(rebuild);
  }

  List<charts.Series<TimeSeriesPwm, DateTime>> _createSampleData() {
    final set = stringToDateTime(_set);
    final origin = set.subtract(Duration(minutes: 30)); // minus 30 minutes
    final t1 = stringToDateTime(_time1);
    final t2 = stringToDateTime(_time2);
    final t3 = stringToDateTime(_time3);
    final t4 = stringToDateTime(_time4);
    final rise = stringToDateTime(_rise);
    final tN = rise.add(Duration(minutes: 30)); // plus 30 minutes

    var data = [
      TimeSeriesPwm(origin, _lpwm),
      TimeSeriesPwm(set, _pwm0),
    ];

    var lastPWM = _pwm0;

    if (set.isBefore(t1)) {
      data.add(TimeSeriesPwm(t1, _pwm0));
      data.add(TimeSeriesPwm(t1, _pwm1));
      data.add(TimeSeriesPwm(t2, _pwm1));
      data.add(TimeSeriesPwm(t2, _pwm2));
      lastPWM = _pwm2;
    } else if ((set.isAfter(t1) || set.isAtSameMomentAs(t1)) && (set.isBefore(t2) || set.isAtSameMomentAs(t2))) {
      data.add(TimeSeriesPwm(t2, _pwm0));
      data.add(TimeSeriesPwm(t2, _pwm2));
      lastPWM = _pwm2;
    }

    if (rise.isBefore(t3)) {
      data.add(TimeSeriesPwm(rise, lastPWM));
    } else if ((rise.isAfter(t3) || rise.isAtSameMomentAs(t3)) && (rise.isBefore(t4) || rise.isAtSameMomentAs(t4))) {
      data.add(TimeSeriesPwm(t3, lastPWM));
      data.add(TimeSeriesPwm(t3, _pwm3));
      data.add(TimeSeriesPwm(rise, _pwm3));
    } else {
      data.add(TimeSeriesPwm(t3, lastPWM));
      data.add(TimeSeriesPwm(t3, _pwm3));
      data.add(TimeSeriesPwm(t4, _pwm3));
      data.add(TimeSeriesPwm(t4, _pwm4));
      data.add(TimeSeriesPwm(rise, _pwm4));
    }

    data.add(TimeSeriesPwm(tN, _lpwm));

    return [
      charts.Series<TimeSeriesPwm, DateTime>(
        id: "profile",
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesPwm p, _) => p.time,
        measureFn: (TimeSeriesPwm p, _) => p.pwm,
        data: data,
      )
    ];
  }

  DateTime stringToDateTime(String time) {
    var l = time.split("-");

//    if (l.length < 2) {
//      throw Failure("parse_time_error");
//    }

    var h = int.tryParse(l[0]);
    var m = int.tryParse(l[1]);

//    if (h == null || m == null) {
//      throw Failure("parse_time_error");
//    }

    if (h > 12) {
      return DateTime(1970, 1, 1, h, m);
    } else {
      return DateTime(1970, 1, 2, h, m);
    }
  }
}

class TimeSeriesPwm {
  final DateTime time;
  final int pwm;

  TimeSeriesPwm(this.time, this.pwm);
}
