import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'tts_service.dart';

part 'service_providers.g.dart';

@riverpod
TtsService ttsService(Ref ref) => TtsService();
