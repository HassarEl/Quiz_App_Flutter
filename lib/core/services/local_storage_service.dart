import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/hive_adapters.dart';
import '../../data/models/user_model.dart';
import '../../data/models/quiz_result_model.dart';

class LocalStorageService {
  static late SharedPreferences prefs;

  static const String usersBoxName = 'users_box';
  static const String resultsBoxName = 'results_box';

  static late Box<UserModel> usersBox;
  static late Box<QuizResultModel> resultsBox;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    // Register Hive adapters (manual)
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(QuizResultModelAdapter());

    usersBox = await Hive.openBox<UserModel>(usersBoxName);
    resultsBox = await Hive.openBox<QuizResultModel>(resultsBoxName);
  }

  // SharedPreferences keys
  static const String kLoggedEmail = 'logged_email';
  static const String kThemeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
}
