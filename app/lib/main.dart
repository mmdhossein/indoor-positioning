import 'dart:ffi';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Polwinno IPS',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Polwinno IPS'));
}

class MyHomePage extends StatefulWidget {
  final String title;
  // final List<BluetoothDevice> listDevices =
  //     <BluetoothDevice>[]; //? use  list literal
  final List<List<dynamic>> rows = <List<dynamic>>[];
  final List<Map> _beaconsList = <Map>[];
  // final _sequenceMapList =
  //     Map<Map<int, int>, List>(); // Map<Map<beacon,position>,sequence>()
  final List<List<List>> _sequenceList =
      <List<List>>[]; // position<beacon<sequence>>
  MyHomePage({this.title = 'No Name'});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool checkPermission = false;
  bool _startGettingBeacons = false;
  bool findMeBool = false;
  bool haveBeacon_1 = false;
  bool haveBeacon_2 = false;
  bool haveBeacon_3 = false;
  bool haveBeacon_4 = false;
  BluetoothDevice? _connectedDevice;
  List<BluetoothService>? _services;
  List<Region> regions = <Region>[];
  StreamSubscription<RangingResult>? _streamRanging;
  TextEditingController positionLabelController = TextEditingController();
  String _positionLabel = '0';
  int _totalNumberBeacons = 0;
  int _numberBeacon_1 = 0;
  int _numberBeacon_2 = 0;
  int _numberBeacon_3 = 0;
  int _numberBeacon_4 = 0;
  int _sequence_1 = 0;
  int _sequence_2 = 0;
  int _sequence_3 = 0;
  int _sequence_4 = 0;
  int _lastLocation_1 = 0;
  int _lastLocation_2 = 0;
  int _lastLocation_3 = 0;
  int _lastLocation_4 = 0;
  int _sequence = 0;
  int rssi_1 = 0;
  int rssi_2 = 0;
  int rssi_3 = 0;
  int rssi_4 = 0;
  List<List<dynamic>> coefData = [];
  List <dynamic> interceptData = [];
  List labels = [];
  String location = '?';
  String yourAreNear = '?';

  ScrollController _scrollController = ScrollController();

  void initBeacons() async {
    try {
      // if you want to manage manual checking about the required permissions
      await flutterBeacon.initializeScanning;

      // or if you want to include automatic checking permission
      await flutterBeacon.initializeAndCheckScanning;
    } on PlatformException catch (e) {
      // library failed to initialize, check code and message
      print(e);
    }

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }

// to start ranging beacons
    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult results) {
      // result contains a region and list of beacons found
      // list can be empty if no matching beacons were found in range

      for (var beacon in results.beacons) {
        _addBeaconToList(
            beacon.proximityUUID, beacon.major, beacon.rssi, _positionLabel);
        if (findMeBool) {
          switch (beacon.major) {
            case 1:
              if (!haveBeacon_1) {
                setState(() {
                  rssi_1 = beacon.rssi;
                  haveBeacon_1 = true;
                });
              }
              break;
            case 2:
              if (!haveBeacon_2) {
                setState(() {
                  rssi_2 = beacon.rssi;
                  haveBeacon_2 = true;
                });
              }
              break;
            case 3:
              if (!haveBeacon_3) {
                setState(() {
                  rssi_3 = beacon.rssi;
                  haveBeacon_3 = true;
                });
              }
              break;
            case 4:
              if (!haveBeacon_4) {
                setState(() {
                  rssi_4 = beacon.rssi;
                  haveBeacon_4 = true;
                });
              }
              break;
          }
          if (haveBeacon_1 & haveBeacon_2 & haveBeacon_3 & haveBeacon_4) {
            print('rssi_1:');
            print(rssi_1);
            print('rssi_2:');
            print(rssi_2);
            print('rssi_3:');
            print(rssi_3);
            print('rssi_4:');
            print(rssi_4);

            findMe(rssi_1, rssi_2, rssi_3, rssi_4);
            // findMe(-20, -30, -20, -10);
          }
        }
        // print('major:${beacon.major}, rssi:${beacon.rssi}');
      }
    });

// to stop ranging beacons
//     _streamRanging.cancel();
  }

  void _addBeaconToList(
      String proximityUUID, int major, int rssi, String location) {
    // if this is my phone ibeacon proximityUUID
    int locationINT = int.parse(location);
    if (_startGettingBeacons) {
      // proximityUUID == '2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6'

      setState(() {
        switch (major) {
          case 1:
            if (_lastLocation_1 == locationINT) {
              _sequence_1++;
            } else {
              _sequence_1 = 1;
              _lastLocation_1 = locationINT;
            }
            _sequence = _sequence_1;

            break;
          case 2:
            if (_lastLocation_2 == locationINT) {
              _sequence_2++;
            } else {
              _sequence_2 = 1;
              _lastLocation_2 = locationINT;
            }
            _sequence = _sequence_2;

            break;
          case 3:
            if (_lastLocation_3 == locationINT) {
              _sequence_3++;
            } else {
              _sequence_3 = 1;
              _lastLocation_3 = locationINT;
            }
            _sequence = _sequence_3;

            break;
          case 4:
            if (_lastLocation_4 == locationINT) {
              _sequence_4++;
            } else {
              _sequence_4 = 1;
              _lastLocation_4 = locationINT;
            }
            _sequence = _sequence_4;
            break;
        }
      });

      Map<String, dynamic> _beaconInfo = Map<String, dynamic>();
      _beaconInfo['proximityUUID'] = proximityUUID;
      _beaconInfo['major'] = major;
      _beaconInfo['rssi'] = rssi;
      _beaconInfo['sequence'] = _sequence;
      _beaconInfo['location'] = location;
      _totalNumberBeacons = widget._beaconsList.length;

      // beacons have same proximityUUID
      //but will split based on major

      setState(() {
        widget._beaconsList.add(_beaconInfo);
        if (major == 1) {
          _numberBeacon_1 += 1;
        }
        if (major == 2) {
          _numberBeacon_2 += 1;
        }
        if (major == 3) {
          _numberBeacon_3 += 1;
        }
        if (major == 4) {
          _numberBeacon_4 += 1;
        }
        // print('widget._beaconsList:');
        // print(widget._beaconsList);
      });

      //save the results to a csv
      getCsv(major, rssi, _sequence, location);
    }
  }

  void getCsv(int ap, int rssi, int sequence, String location) async {
    List<dynamic> row = <dynamic>[];

    // declare columns
    if (widget.rows.isEmpty) {
      row.add('ap');
      row.add('rssi');
      row.add('sequence');
      row.add('location');
      widget.rows.add(row);
    }
    // add data
    row.add(ap);
    row.add(rssi);
    row.add(sequence);
    row.add(location);
    widget.rows.add(row);

    // print('row:');
    // print(row);
    // print('checkPermission:');
    // print(checkPermission);
    //write csv
    if (checkPermission) {
      String dir =
          (await getExternalStorageDirectory())!.absolute.path + '/polwinno';
      String file = dir + 'Beacons.csv';
      // print('saving csv file to $file');
      File f = File(file);
      String myCsv = const ListToCsvConverter().convert(widget.rows);
      // print('myCsv:');
      // print(myCsv);
      f.writeAsString(myCsv);
    }
  }

  void loadCoefficients() async {
    String dir = (await getExternalStorageDirectory())!.absolute.path;
    String coefFileName = dir + '/coef_.csv';
    String interceptFileName = dir + '/intercept_.csv';
    String labelsFileName = dir + '/labels.csv';

    print('coefFileName:');
    print(coefFileName);
    File coefFile = File(coefFileName);
    File interceptFile = File(interceptFileName);
    File labelsFile = File(labelsFileName);

    // String coefString = coefFile.toString();
    String coefString = await coefFile.readAsString();
    print('coefString:');
    print(coefString);
    String interceptString = await interceptFile.readAsString();
    String labelsString = await labelsFile.readAsString();

    setState(() {
      coefData = CsvToListConverter().convert(coefString);
      interceptData = CsvToListConverter().convert(interceptString);
      labels = CsvToListConverter().convert(labelsString);
    });
  }

  void findMe(int rssi_1, int rssi_2, int rssi_3, int rssi_4) async {
    int idx = 0;
    List<double> probabilities = [];

    while (idx < coefData.length) {
      print('coefData:');
      print(coefData);
      print('coefData[idx][0] .runtimeType:');
      print(coefData[idx][0].runtimeType);
      print('coefData[0][2]:');
      print(coefData[0][2]);
      print('double * int');
      print(0.45 * 2);
      print('interceptData[idx]:');
      print(interceptData[idx][0]);
      double probability = coefData[idx][0] * rssi_1 +
          coefData[idx][1] * rssi_2 +
          coefData[idx][2] * rssi_3 +
          coefData[idx][3] * rssi_4 +
          interceptData[idx][0];
      probabilities.add(probability);
      print('probability:');
      print(probability);
      idx++;
    }

    double maxProbability = probabilities.reduce(max);
    int indexMax = probabilities.indexOf(maxProbability);
    print('location is:');
    print(labels[indexMax]);
    setState(() {
      location = labels[indexMax][0].toInt().toString();
      yourAreNear = labels[indexMax][1];
    });
    print('you are near:');
    print(yourAreNear);
  }

  Container buildPositionText() {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
        child: TextField(
          controller: positionLabelController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'position',
          ),
          onChanged: (position) {
            setState(() {
              _positionLabel = position;
              print(_positionLabel);
//you can access nameController in its scope to get
// the value of text entered as shown below
//UserName = nameController.text;
            });
          },
        ));
  }

  Row buildButtons() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _startGettingBeacons = true;
                });
              },
              child: Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent)),
            ),
            SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _startGettingBeacons = false;
                  _numberBeacon_1 = 0;
                  _numberBeacon_2 = 0;
                  _numberBeacon_3 = 0;
                  _numberBeacon_4 = 0;
                });
              },
              child: Text(
                'Stop',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent)),
            ),
            SizedBox(
              width: 200,
            ),
            TextButton(
              onPressed: () {
                setState(() {});
              },
              child: Text(
                'Total Beacons: $_totalNumberBeacons',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.lightGreen),
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.lightGreen)),
            ),
          ],
        ))
      ],
    );
  }

  Row buildBeaconsCount() {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            loadCoefficients();
            setState(() {
              findMeBool = true;
            });
          },
          child: Text(
            'Find Me!',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.deepOrange),
              shadowColor: MaterialStateProperty.all<Color>(Colors.deepOrange)),
        ),
        SizedBox(width: 10),
        TextButton(
          onPressed: () {},
          child: Text(
            '$location',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shadowColor: MaterialStateProperty.all<Color>(Colors.white)),
        ),
        SizedBox(
          width: 100,
        ),
        TextButton(
          onPressed: () {
            setState(() {});
          },
          child: Text(
            'Beacon 1: $_numberBeacon_1',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.lightGreen),
              shadowColor: MaterialStateProperty.all<Color>(Colors.red)),
        ),
        SizedBox(
          width: 1,
        ),
        TextButton(
          onPressed: () {
            setState(() {});
          },
          child: Text(
            'Beacon 2: $_numberBeacon_2',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.lightGreen),
              shadowColor: MaterialStateProperty.all<Color>(Colors.lightGreen)),
        ),
        SizedBox(
          width: 1,
        ),
        TextButton(
          onPressed: () {
            setState(() {});
          },
          child: Text(
            'Beacon 3: $_numberBeacon_3',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.lightGreen),
              shadowColor: MaterialStateProperty.all<Color>(Colors.lightGreen)),
        ),
        SizedBox(
          width: 1,
        ),
        TextButton(
          onPressed: () {
            setState(() {});
          },
          child: Text(
            'Beacon 4: $_numberBeacon_4',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.lightGreen),
              shadowColor: MaterialStateProperty.all<Color>(Colors.lightGreen)),
        )
      ],
    );
  }

  ListView _buildListViewOfBeacons() {
    List<Container> containers = <Container>[]; //?
    // containers.add(buildPositionText());
    for (Map beacon in widget._beaconsList) {
      // print(beacon);
      containers.add(Container(
        height: 30,
        child: Row(
          children: <Widget>[
            Container(
                // margin: const EdgeInsets.all(3),
                // padding: const EdgeInsets.all(1),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white60)),
                child: Row(
                  children: [
                    Text("AP: ${beacon['major']}",
                        style:
                            TextStyle(color: Colors.lightGreen, fontSize: 25)),
                    SizedBox(
                      width: 15,
                    ),
                    Text("rssi: ${beacon['rssi']}",
                        style: TextStyle(color: Colors.red, fontSize: 25)),
                    SizedBox(
                      width: 15,
                    ),
                    Text("seq: ${beacon['sequence']}",
                        style: TextStyle(
                            color: Colors.deepPurpleAccent, fontSize: 25)),
                    SizedBox(
                      width: 15,
                    ),
                    Text("position: ${beacon['location']}",
                        style: TextStyle(color: Colors.purple, fontSize: 25))
                  ],
                )),
          ],
        ),
      ));
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
    return ListView.builder(
        controller: _scrollController,
        itemCount: containers.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(1),
            child: Column(
              children: [containers[index]],
            ),
          );
        });
  }

  Row buildLocationLabel() {

    return Row( children: [SizedBox(width: 225,),TextButton(
      onPressed: () {
        setState(() {});
      },
      child: Text(
        'You Are Near $yourAreNear',
        style: TextStyle(color: Colors.black87, fontSize: 20),
      ),
      style: ButtonStyle(
          backgroundColor:
          MaterialStateProperty.all<Color>(Colors.lightGreen),
          shadowColor: MaterialStateProperty.all<Color>(Colors.lightGreen)),
    )]);
  }

 
  ListView _buildConnectDeviceView() {
    List<Container> containers = <Container>[];

    for (BluetoothService service in _services ?? []) {
      containers.add(Container(
        height: 50,
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: <Widget>[Text(service.uuid.toString())],
            ))
          ],
        ),
      ));

      return ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[...containers],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfBeacons();
  }

  void getPermission() async {
    // await Permission.manageExternalStorage.request();
    checkPermission = await Permission.accessMediaLocation.request().isGranted;
    print('checkPermission:');
    print(checkPermission);
  }

  // in initState method we subscribe to stream by adding listeners to this class
  // so every time new data arrives, we add them to listDevices
  @override
  void initState() {
    super.initState();

    getPermission();
    initBeacons();

    if (Platform.isAndroid) {
      print('Hello from android!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(children: [
          Container(
              child: Column(
            children: [
              buildButtons(),
              buildBeaconsCount(),
              buildPositionText()
            ],
          )),
          Expanded(child: _buildListViewOfBeacons()),
          buildLocationLabel()
        ]));
  }
}
