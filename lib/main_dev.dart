import 'app.dart';
import 'bootstrap.dart';
import 'core/config/build_flavor.dart';

void main() => bootstrap(BuildFlavor.dev, const TikTalkApp());
