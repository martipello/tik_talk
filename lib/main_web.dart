import 'app.dart';
import 'bootstrap.dart';
import 'core/config/build_flavor.dart';

void main() => bootstrap(BuildFlavor.prod, const TikTalkApp());
