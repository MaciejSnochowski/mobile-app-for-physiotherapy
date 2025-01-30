import 'package:flutter/material.dart';
import 'package:physiotherapy/core/theme/theme.dart';
import 'package:physiotherapy/services/auth/firebase_auth_service.dart';
import 'package:physiotherapy/viewmodel/home/first_login/personal_info_viewmodel.dart';
import 'package:physiotherapy/viewmodel/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuthService();

  bool isLightOn = true;
  bool isAcOn = false;
  bool isTvOn = false;
  bool isFanOn = false;

  @override
  Widget build(BuildContext context) {
    final _homeViewModel = Provider.of<HomeViewmodel>(context);
    final _personalInfoViewModel = Provider.of<PersonalInfoViewModel>(context);
    _personalInfoViewModel.shouldShowSettingsIcon = true;
    void _logout() {
      _auth.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }

    final bool isPhysiotherapist = _homeViewModel.getPhysio() ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: !isPhysiotherapist
            ? IconButton(
                icon: Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/personal_info'); // Przekierowanie do /home
                },
              )
            : Container(),
        backgroundColor: Colors.black38,
        elevation: 0,
        title: Container(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Text(
              _homeViewModel.getFormattedDate(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          )),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 25.0), // Dodany padding
                child: Text(
                  isPhysiotherapist
                      ? 'Witaj Fizjoterapeuto'
                      : 'Witaj, ${_homeViewModel.getName()}!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    buildSmartDevice(
                      deviceName: 'Rozpocznij czat',
                      icon: Icons.chat_bubble,
                      context: context,
                      route: '/history_chat',
                    ),
                    buildSmartDevice(
                      deviceName:
                          isPhysiotherapist ? "Ustawienia" : "Kalendarz",
                      icon: isPhysiotherapist
                          ? Icons.settings
                          : Icons.calendar_month,
                      context: context,
                      route: isPhysiotherapist ? '/personal_info' : '/calendar',
                    ),
                    buildSmartDevice(
                      deviceName: isPhysiotherapist
                          ? 'Zaplanuj Grafik '
                          : "Fizjoterapeuci",
                      icon: isPhysiotherapist ? Icons.schedule : Icons.person,
                      context: context,
                      route: isPhysiotherapist
                          ? '/modify_calendar'
                          : '/list_of_physiotherapists',
                    ),
                    buildSmartDevice(
                      deviceName: 'Baza ćwiczeń',
                      icon: Icons.data_exploration_sharp,
                      context: context,
                      route: '/list_of_protocols',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSmartDevice({
    required String deviceName,
    required IconData icon,
    required BuildContext context,
    required String route, // Dodano parametr route
  }) {
    return GestureDetector(
      onTap: () {
        // Przekierowanie do określonej trasy (route)
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.TurquoiseLagoon,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  deviceName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
