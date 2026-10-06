import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportStateNotifier extends Notifier<String> {
  @override
  String build() => '';

  set update(String text) => state = text;
  void clear() => state = '';
}

final importProvider = NotifierProvider<ImportStateNotifier, String>(
  ImportStateNotifier.new,
);
