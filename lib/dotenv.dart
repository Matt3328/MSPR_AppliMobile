import 'package:flutter_dotenv/flutter_dotenv.dart';

void loadDotEnv() {
  dotenv.load(fileName: '.env');
}