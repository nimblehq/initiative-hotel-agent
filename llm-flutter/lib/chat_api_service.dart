import 'dart:async';
import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';

class ChatApiService {
  static const String apiUrl =
      'https://initiative-hotel-agent.vercel.app/api/chat-llm';

  static Stream<String> sendHotelQuery({
    required String query,
    required List<Map<String, dynamic>> conversationHistory,
  }) async* {
    final controller = StreamController<String>();
    SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: apiUrl,
      header: {
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Content-Type': 'application/json',
      },
      body: {
        'query': query,
        'conversationHistory': conversationHistory,
      },
    ).listen((event) {
      if (event.event == 'token' && event.data != null) {
        // Replace $NEWLINE$ with \n and remove \u0000
        final cleaned =
            event.data!.replaceAll('\u0000', '').replaceAll('\$NEWLINE\$', '');
        controller.add(cleaned);
      } else if (event.event == 'state' && event.data != null) {
        controller.add(event.data!);
      } else if (event.event == 'finished') {
        controller.close();
      }
    }, onError: (e) {
      controller.addError(e);
      controller.close();
    });
    yield* controller.stream;
  }
}
