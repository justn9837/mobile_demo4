import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/home/user_home/user_home_view.dart';
import '../modules/home/dosen_home/dosen_home_view.dart';
import '../modules/daily_journal/daily_journal_view.dart';
import '../modules/benchmark/benchmark_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final routes = [
    GetPage(name: AppRoutes.LOGIN, page: () => LoginView()),
    GetPage(name: AppRoutes.REGISTER, page: () => RegisterView()),
    GetPage(name: AppRoutes.USER_HOME, page: () => UserHomeView()),
    GetPage(name: AppRoutes.DOSEN_HOME, page: () => DosenHomeView()),
    GetPage(name: AppRoutes.DAILY_JOURNAL, page: () => DailyJournalView()),
    GetPage(name: AppRoutes.BENCHMARK, page: () => BenchmarkView()),
  ];
}
