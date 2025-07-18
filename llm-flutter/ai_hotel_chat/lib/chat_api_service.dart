import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  static StreamSubscription<String> sendMessageStream({
    required String query,
    required List<Map<String, dynamic>> conversationHistory,
    required void Function(String chunk) onData,
    required void Function() onDone,
    required void Function(dynamic error) onError,
  }) {
    final controller = StreamController<String>();
    final url = Uri.parse('http://localhost:8000/chat'); // TODO: Set your backend URL
    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'query': query,
        'conversationHistory': conversationHistory,
      });
    http.Client client = http.Client();
    client.send(request).then((response) {
      response.stream.transform(utf8.decoder).listen((chunk) {
        controller.add(chunk);
        onData(chunk);
      }, onDone: () {
        controller.close();
        onDone();
      }, onError: (e) {
        controller.addError(e);
        onError(e);
      });
    }).catchError((e) {
      controller.addError(e);
      onError(e);
    });
    return controller.stream.listen((_) {});
  }
} 