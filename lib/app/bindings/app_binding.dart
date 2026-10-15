import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/task_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/tasks/controllers/task_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<TaskService>(TaskService(), permanent: true);

    // Core Auth Controller
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<TaskController>(() => TaskController());
  }
}

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(() => TaskController());
  }
}
