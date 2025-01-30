import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:physiotherapy/core/theme/theme.dart';
import 'package:physiotherapy/view/auth/forget_password_view.dart';
import 'package:physiotherapy/view/auth/singup_view.dart';
import 'package:physiotherapy/core/config/firebase_options.dart';
import 'package:physiotherapy/view/auth/login_view.dart';
import 'package:physiotherapy/view/calendar/ptient_calendar_view.dart';
import 'package:physiotherapy/view/calendar/modify_calendar.dart';
import 'package:physiotherapy/view/chat/chat_view.dart';
import 'package:physiotherapy/view/chat/history_chat.dart';
import 'package:physiotherapy/view/download.dart';
import 'package:physiotherapy/view/home/first_login/personal_info_view.dart';
import 'package:physiotherapy/view/home/home_view.dart';
import 'package:physiotherapy/view/list_of_physio/physiotherapists_list.dart';
import 'package:physiotherapy/view/protocols/protocolsListView.dart';
import 'package:physiotherapy/viewmodel/auth/forget_password_viewmodel.dart';
import 'package:physiotherapy/viewmodel/calendar/calendar_viewmodel.dart';
import 'package:physiotherapy/viewmodel/calendar/patient_calendar_viewmodel.dart';
import 'package:physiotherapy/viewmodel/calendar/user_calendar_viewmodel.dart';
import 'package:physiotherapy/viewmodel/chat/chat_viewmodel.dart';
import 'package:physiotherapy/viewmodel/chat/history_chat_viewmodel.dart';
import 'package:physiotherapy/viewmodel/download.dart';
import 'package:physiotherapy/viewmodel/home/first_login/personal_info_viewmodel.dart';
import 'package:physiotherapy/viewmodel/auth/singup_viewmodel.dart';
import 'package:physiotherapy/viewmodel/auth/login_viewmodel.dart';
import 'package:physiotherapy/viewmodel/home/home_viewmodel.dart';
import 'package:physiotherapy/viewmodel/physiotherapists_list/physiotherapists_viewmodel.dart';
import 'package:physiotherapy/viewmodel/protocols/protocolsViewModel.dart';
import 'package:provider/provider.dart';

Logger logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pl_PL', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => PersonalInfoViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewmodel()),
        ChangeNotifierProvider(create: (_) => PhysiotherapistsViewModel()),
        ChangeNotifierProvider(create: (_) => ProtocolsViewModel()),
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => UserCalendarViewModel()),
        ChangeNotifierProvider(create: (_) => PatientCalendarViewModel()),
        ChangeNotifierProvider(create: (_) => ChatRoomViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryChatViewModel()),
        ChangeNotifierProvider(create: (_) => ForgetPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => FirestoreToStorageViewModel()),

        // Dodaj inne ViewModel, jeśli potrzebujesz
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: AppTheme.theme.colorScheme),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginScreen(),
        '/singup': (context) => const SignupScreen(),
        '/home': (context) => HomePage(),
        '/calendar': (context) => PatientCalendarView(),
        '/list_of_physiotherapists': (context) => PhysiotherapistsListView(),
        '/list_of_protocols': (context) => ProtocolsListView(),
        '/modify_calendar': (context) => CalendarView(),
        '/forget_password': (context) => ForgetPasswordView(),
        '/chat': (context) => ChatRoomView(),
        '/history_chat': (context) => HistoryChatView(),
        '/personal_info': (context) => PersonalInfoScreen(),
        '/d': (context) => FirestoreBackupView(),
      },
    );
  }
}
