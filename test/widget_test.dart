import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // group("l07h01", () => runTestLesson3Task1());
  // group("l07h02", () => runTestLesson3Task2());
  // group("l07h03", () => runTestLesson3Task3());
  // group("l07h04", () => runTestLesson3Task4());
}
