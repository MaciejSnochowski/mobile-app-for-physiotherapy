import 'package:flutter/material.dart';
import 'package:physiotherapy/core/theme/theme.dart';
import 'package:physiotherapy/viewmodel/home/first_login/personal_info_viewmodel.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreen();
}

class _PersonalInfoScreen extends State<PersonalInfoScreen> {
  final GlobalKey<FormState> personalInfoFormKey = GlobalKey<FormState>();

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    final _personalInfoViewModel =
        Provider.of<PersonalInfoViewModel>(context, listen: false);
    // Resetowanie formularza przy każdej zmianie zależności
    await Future.delayed(Duration(seconds: 1));

    _personalInfoViewModel.nameController.clear();
    _personalInfoViewModel.surnameController.clear();
    _personalInfoViewModel.addressController.clear();
    _personalInfoViewModel.phoneController.text = '+48 ';
  }

  @override
  void initState() {
    super.initState();
    final _personalInfoViewModel =
        Provider.of<PersonalInfoViewModel>(context, listen: false);

    // Dodanie prefiksu +48 do kontrolera numeru telefonu
    _personalInfoViewModel.phoneController.text = '+48 ';

    // Nasłuchiwanie zmian w polu numeru telefonu
    _personalInfoViewModel.phoneController.addListener(() {
      final text = _personalInfoViewModel.phoneController.text;
      if (!text.startsWith('+48 ')) {
        _personalInfoViewModel.phoneController.text = '+48 ';
        _personalInfoViewModel.phoneController.selection =
            TextSelection.fromPosition(
          TextPosition(
              offset: _personalInfoViewModel.phoneController.text.length),
        );
      } else if (text.length > 13) {
        // Ograniczenie długości tekstu do 13 znaków (+48 + 9 cyfr)
        _personalInfoViewModel.phoneController.text = text.substring(0, 13);
        _personalInfoViewModel.phoneController.selection =
            TextSelection.fromPosition(
          TextPosition(
              offset: _personalInfoViewModel.phoneController.text.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _personalInfoViewModel = Provider.of<PersonalInfoViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: _personalInfoViewModel.shouldShowSettingsIcon
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
                onPressed: () {
                  didChangeDependencies;
                  Navigator.pushNamed(context, '/home');
                },
              )
            : Container(), // Jeśli warunek nie jest spełniony, nic nie renderuj
        backgroundColor: Colors.black38,
        title: Text('Dane osobowe'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        ),
        child: Form(
          key: personalInfoFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _personalInfoViewModel.nameController,
                decoration: InputDecoration(labelText: 'Imię'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę podać imię';
                  } else if (value.length < 3) {
                    return 'Imię musi mieć co najmniej 3 litery';
                  } else if (value.length > 13) {
                    return 'Imię nie może być dłuższe niż 13 znaków';
                  } else if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Imię nie może zawierać cyfr';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _personalInfoViewModel.surnameController,
                decoration: InputDecoration(labelText: 'Nazwisko'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę podać nazwisko';
                  } else if (value.length < 3) {
                    return 'Nazwisko musi mieć co najmniej 3 litery';
                  } else if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Nazwisko nie może zawierać cyfr';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _personalInfoViewModel.addressController,
                decoration: InputDecoration(labelText: 'Adres zamieszkania'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę podać adres zamieszkania';
                  } else if (value.length < 3) {
                    return 'Adres zamieszkania musi mieć co najmniej 3 litery';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _personalInfoViewModel.phoneController,
                decoration: InputDecoration(labelText: 'Numer telefonu'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty || value == '+48 ') {
                    return 'Proszę podać numer telefonu';
                  } else if (!RegExp(r'^\+48 \d{9}$').hasMatch(value)) {
                    return 'Numer telefonu musi składać się z dokładnie 9 cyfr';
                  }
                  return null;
                },
                maxLength:
                    13, // Ustawienie maksymalnej długości na 13 znaków (+48 + 9 cyfr)
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppTheme.TurquoiseLagoon, // Zmiana koloru tła przycisku
                  foregroundColor: Colors.white, // Kolor tekstu na przycisku
                ),
                onPressed: () async {
                  if (personalInfoFormKey.currentState!.validate()) {
                    _personalInfoViewModel.createUserData();
                    await didChangeDependencies();

                    Navigator.pushNamed(context, '/home');
                  }
                },
                child: Text(
                  'Dalej',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
