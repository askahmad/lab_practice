class AppStrings {
  AppStrings._();

  // App General
  static const String appName = 'TaskFlow Pro';
  static const String appTagline = 'Organize, Prioritize & Achieve';

  // Auth Strings
  static const String welcomeBack = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to access your personalized tasks';
  static const String createAccount = 'Create Account';
  static const String signupSubtitle = 'Register to stay productive and organized';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String login = 'Sign In';
  static const String signup = 'Sign Up';
  static const String logout = 'Log Out';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = "Already have an account? ";

  // Validations
  static const String nameRequired = 'Please enter your full name';
  static const String nameMinLength = 'Name must be at least 3 characters';
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String titleRequired = 'Please enter task title';

  // Task Screen Strings
  static const String myTasks = 'My Tasks';
  static const String searchPlaceholder = 'Search tasks by title...';
  static const String total = 'Total';
  static const String completed = 'Completed';
  static const String pending = 'Pending';
  static const String all = 'All';

  // Add / Edit Task
  static const String addNewTask = 'Add New Task';
  static const String editTask = 'Edit Task';
  static const String taskTitle = 'Task Title';
  static const String taskTitleHint = 'e.g., Finalize presentation slides';
  static const String taskDesc = 'Description';
  static const String taskDescHint = 'Add details or notes about this task...';
  static const String dueDate = 'Due Date';
  static const String priority = 'Priority';
  static const String saveTask = 'Save Task';
  static const String updateTask = 'Update Task';
  static const String deleteTask = 'Delete Task';
  static const String taskDetails = 'Task Details';

  // Dialogs & Messages
  static const String confirmDeleteTitle = 'Delete Task';
  static const String confirmDeleteMessage =
      'Are you sure you want to delete this task? This action cannot be undone.';
  static const String confirmLogoutTitle = 'Log Out';
  static const String confirmLogoutMessage =
      'Are you sure you want to log out of TaskFlow?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String noTasksFound = 'No tasks found';
  static const String noTasksSubtitle =
      'Tap the "+" button below to create your first task!';
}
