import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'home.dart';
import 'package:flutter/services.dart';
import 'component/message.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '7 Deli App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _latestLink = 'Unknown';
  Uri _latestUri;
  StreamSubscription _sub;
  String receipt_no = '1000000548';
  final TextEditingController _numberBill = new TextEditingController();

  String _amountPayment;
  String _typePayment = '';
  String _reasonCode = '';
  List<String> _receiptdetails = new List();
  final TextEditingController _reason = new TextEditingController();
  List<Message> reasonList = [];

  @override
  void initState() {
    setState(() {
      _numberBill.text = receipt_no;
    });
    initPlatformState();
    super.initState();
  }

  initPlatformState() async {
    await initPlatformStateForUriUniLinks();
  }

  initPlatformStateForUriUniLinks() async {
    // Attach a listener to the Uri links stream
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      setState(() {
        _latestUri = uri;
        _latestLink = uri?.toString() ?? 'Unknown';
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        _latestLink = 'Failed to get latest link: $err.';
      });
    });

    // Attach a second listener to the stream
    getUriLinksStream().listen((Uri uri) {
      print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest Uri
    Uri initialUri;
    String initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialUri = await getInitialUri();
      print('initial uri: ${initialUri?.path}'
          ' ${initialUri?.queryParametersAll}');
      initialLink = initialUri?.toString();
    } on PlatformException {
      initialUri = null;
      initialLink = 'Failed to get initial uri.';
    } on FormatException {
      initialUri = null;
      initialLink = 'Bad parse the initial link as Uri.';
    }

    if (!mounted) return;

    setState(() {
      _latestUri = initialUri;
      print("latestUri : $_latestUri");
      _latestLink = initialLink;
      print("latestLink: $_latestLink");
    });

    if (_latestLink != null) {
      if (_latestLink.startsWith("testcallback://gosoft.co.th/callback")) {
        // String receipt_no = "";
        // String callback_url = "";
        // String channel = "";
        // String user_id = "";
        // String user_name = "";
        // String user_surname = "";
        // var uri = Uri.parse('$_latestLink');
        // uri.queryParameters.forEach((key, value) {
        //   print('key: $key - value: $value');
        //   if (key == "receipt_no") {
        //     receipt_no = value;
        //   } else if (key == "callback_url") {
        //     callback_url = value;
        //   } else if (key == "channel") {
        //     channel = value;
        //   } else if (key == "user_id") {
        //     user_id = value;
        //   } else if (key == "user_name") {
        //     user_name = value;
        //   } else if (key == "user_surname") {
        //     user_surname = value;
        //   }
        // });

        // print(' receipt_no =>$receipt_no');
        // print(' callback_url => $callback_url');
        // print(' channel =>$channel ');
        // print(' user_id =>$user_id ');
        // print(' user_name =>$user_name');
        // print(' user_surname =>$user_surname');

      }
    }
  }

  _launchURLPostvoid() async {
    final Uri _postvoidLaunchUri = Uri(
        scheme: 'posonline',
        host: 'gosoft.co.th',
        path: 'postvoid',
        queryParameters: {
          'store_id': '03791',
          'reference_id':'1',
          'receipt_no': _numberBill.text,
          'callback_url': 'testcallback://gosoft.co.th/callback',
          'channel': '7delivery',
          'user_id': '5431111',
          'user_name': 'ชื่อทดสอบ',
          'user_surname': 'นามสกุล',
          'approve_user_id': "1234444",
          'approve_user_name': 'kung',
          'approve_user_surname': 'kunakorn',
          'reason_code': "1",
        });

    print(' _reprintLaunchUri => ${_postvoidLaunchUri.toString()}');
    if (await canLaunch(_postvoidLaunchUri.toString())) {
      await launch(_postvoidLaunchUri.toString());
    } else {
      throw 'Could not launch ${_postvoidLaunchUri.toString()}';
    }
  }

  _launchURLReprint() async {
    final Uri _reprintLaunchUri = Uri(
        scheme: 'posonline',
        host: 'gosoft.co.th',
        path: 'reprint',
        queryParameters: {
          "store_id": "03791",
          'receipt_no': _numberBill.text,
          'callback_url': 'testcallback://gosoft.co.th/callback',
          'channel': '7delivery',
          'user_id': '5431111',
          'user_name': 'ชื่อทดสอบ',
          'user_surname': 'นามสกุล',
        });

    print(' _reprintLaunchUri => ${_reprintLaunchUri.toString()}');
    if (await canLaunch(_reprintLaunchUri.toString())) {
      await launch(_reprintLaunchUri.toString());
    } else {
      throw 'Could not launch ${_reprintLaunchUri.toString()}';
    }
  }

  Widget _numberbill() {
    return Container(
      width: double.infinity,
      height: 112.0,
      margin: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลขที่ใบเสร็จ',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Container(
                  height: 48.0,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _numberBill.text;
                      });
                    },
                    enableInteractiveSelection: true,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(10),
                    ],
                    controller: _numberBill,
                    textAlign: TextAlign.left,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF394764),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'เลขที่ใบเสร็จ 10 หลัก',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          color: Color.fromARGB(40, 0, 0, 0)),
                      contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF163473), width: 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF163473), width: 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD63135)),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ButtonTheme(
                height: 48.0,
                minWidth: 48.0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _numberBill.text.length > 0
                        ? Color(0xFF223357)
                        : Color(0xFFA7ADBC),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: RaisedButton(
                  highlightElevation: 0,
                  elevation: 0,
                  disabledColor: Color(0xFFA7ADBC),
                  onPressed: _launchURLReprint,
                  color: Color(0xFF223357),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(4),
                        child: Text(
                          'Reprint',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget postvoid() {
    return Container(
      width: 180,
      child: RaisedButton(
          highlightElevation: 0,
          elevation: 0,
          onPressed:
              //launch postvoid
              _launchURLPostvoid,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          padding: EdgeInsets.all(0.0),
          child: Container(
              padding: EdgeInsets.fromLTRB(12, 10, 10, 9),
              height: MediaQuery.of(context).size.height * 0.088,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                  colors: [Color(0xff7BA3C9), Color(0xff001C56)],
                  begin: Alignment.centerLeft,
                  end: Alignment.bottomRight,
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/menu-another.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/images/cancelbill.png',
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "ยกเลิกใบเสร็จ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ))),
    );
  }

  Widget _reasonCancellation() {
    return Container(
        width: double.infinity,
        height: 112.0,
        margin: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เหตุผลที่ยกเลิก',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            Container(
              height: 48.0,
              width: double.infinity,
              padding: EdgeInsets.only(left: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFF163473),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF223357),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                        color: Color(0xFF223357),
                      ),
                      width: 48,
                      height: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: _deviceDropDown(),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  DropdownButton _deviceDropDown() {
    return DropdownButton<Message>(
      hint: Text(
        _reason.text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white,
      ),
      isExpanded: true,
      iconSize: 24,
      underline: Container(
        color: Colors.white,
      ),
      onChanged: (value) {
        setState(() {
          _reason.text = value.name;
          _reasonCode = value.code;
        });
      },
      items: _toDropDownItem(reasonList),
    );
  }

  List<DropdownMenuItem> _toDropDownItem(List<Message> _list) {
    List<DropdownMenuItem> _dropDownItem =
        _list.map<DropdownMenuItem<Message>>((value) {
      return DropdownMenuItem(
        value: value,
        child: Text(
          value.name,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();

    return _dropDownItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[_numberbill(), postvoid()],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
