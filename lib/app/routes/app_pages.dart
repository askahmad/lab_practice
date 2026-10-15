import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/signup_view.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/tasks/views/add_edit_task_view.dart';
import '../../modules/tasks/views/task_detail_view.dart';
import '../bindings/app_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static String get initialRoute {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? AppRoutes.HOME : AppRoutes.LOGIN;
  }

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupView(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ADD_TASK,
      page: () => const AddEditTaskView(),
      binding: TaskBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.EDIT_TASK,
      page: () => const AddEditTaskView(),
      binding: TaskBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.TASK_DETAIL,
      page: () => const TaskDetailView(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
