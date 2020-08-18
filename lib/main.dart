import 'dart:io';
import 'package:ftpclient/ftpclient.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  File file;
  final Map<String, HighlightedWord> _highlights = {
    'server': HighlightedWord(
      onTap: () => print('server'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'uploaded': HighlightedWord(
      onTap: () => print('uploaded'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    'error': HighlightedWord(
      onTap: () => print('error'),
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    'timeout': HighlightedWord(
      onTap: () => print('timeout'),
      textStyle: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'camera': HighlightedWord(
      onTap: () => print('camera'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  stt.SpeechToText _speech;
  stt.SpeechToText _speech1;
  bool _isListening = false;
  bool _isListening1 = false;
  String _text = 'Press the button and start speaking';
  String _text1 = 'Press the button and start speaking';
  double _confidence = 1.0;
  double _confidence1 =1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech1 = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: Column(
        children:[ SingleChildScrollView(
          reverse: true,
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
            child: TextHighlight(
              text: _text,
              words: _highlights,
              textStyle: const TextStyle(
                fontSize: 32.0,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
          FlatButton(onPressed: upload,color: Colors.redAccent, child:
          Text('Ftp Upload'),)
        ],
      ),
    );
  }
  void _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    file = File('${directory.path}/my_file.txt');
    await file.writeAsString(text);
//    String contents= await file.readAsString();
//    print(contents);
  }
  upload() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    file = File('${directory.path}/my_file.txt');
    String contents= await file.readAsString();
    print(contents);
//    try {
//      FTPClient ftpClient = FTPClient(
//          '182.50.151.114', user: 'pihms', pass: "MobApp@123\$");
//      ftpClient.connect();
//      ftpClient.uploadFile(file);
//      ftpClient.disconnect();
//      print('done');
//    }
//    catch(e){
//      print(e);
//    }

  }
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _write(_text);
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
