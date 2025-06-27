import 'package:doloooki/core/presentation/ondoarding/screens/bottom_navigation.dart';
import 'package:doloooki/core/presentation/ondoarding/screens/loading_screen.dart';
import 'package:doloooki/core/presentation/ondoarding/screens/onboarding_screen.dart';
import 'package:doloooki/core/presentation/ondoarding/screens/video_loading_screen.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/creating_profile.dart';
import 'package:doloooki/web/core/presentation/left_navigation/screens/left_navigation_screen.dart';
import 'package:doloooki/web/features/auth_feature/screens/checking_info_screen.dart';
import 'package:doloooki/web/features/auth_feature/screens/creating_profile_screen.dart';
import 'package:doloooki/web/features/auth_feature/screens/auth_feature.dart';
import 'package:doloooki/web/features/auth_feature/screens/password_reset_success_screen.dart';
import 'package:doloooki/web/features/auth_feature/screens/forget_password_screen.dart';
import 'package:doloooki/web/features/recomendations_feature/screens/recomendations_screen.dart';
import 'package:doloooki/web/features/requests_feature/screens/requests_screen.dart';
import 'package:doloooki/web/features/settings_feature/screens/settings_screen.dart';
import 'package:doloooki/web/features/users_feature/screens/users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Initializing Firebase...');
    
    // Проверяем, инициализирован ли уже Firebase
    if (Firebase.apps.isEmpty) {
      print('No Firebase apps found, initializing...');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print('Firebase initialized successfully');
    } else {
      print('Firebase already initialized');
    }
    
    // Настройка персистентности для веба - КРИТИЧЕСКИ ВАЖНО для сохранения сессии
    if (kIsWeb) {
      try {
        // Устанавливаем персистентность для IndexedDB
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        print('Firebase Auth persistence установлена');
      } catch (e) {
        print('Warning: Could not set web persistence: $e');
        // Продолжаем работу даже если не удалось установить персистентность
      }
    }
    
    print('Firebase apps count: ${Firebase.apps.length}');
    print('Default Firebase app name: ${Firebase.app().name}');
    
    // Проверяем доступность Firestore
    try {
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      print('Firestore is accessible');
    } catch (e) {
      print('Error accessing Firestore: $e');
    }
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');
    runApp(MaterialApp(
      home: LoadingScreen(),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DOLOOKI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: kIsWeb ? WebAuthWrapper() : FutureBuilder(
          future: Future.delayed(const Duration(seconds: 7)), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const VideoLoadingScreen();
            }
            
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = snapshot.data;
                if (user == null) {
                  return OnboardingScreen();
                }

                // Проверяем, есть ли профиль пользователя
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Если профиль не существует, показываем экран создания профиля
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return CreatingProfileScreen();
                    }

                    // Если профиль существует, показываем основной экран
                    return BottomNavigation();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class WebAuthWrapper extends StatefulWidget {
  @override
  _WebAuthWrapperState createState() => _WebAuthWrapperState();
}

class _WebAuthWrapperState extends State<WebAuthWrapper> {
  @override
  void initState() {
    super.initState();
    _quickAuthCheck();
  }

  Future<void> _quickAuthCheck() async {
    if (kDebugMode) {
      print('🔄 Quick auth check...');
    }
    
    try {
      // Быстрая проверка без задержек
      final regularUser = FirebaseAuth.instance.currentUser;
      
      if (kDebugMode) {
        print('Firebase Auth user: ${regularUser?.uid}');
      }
      
      // Если пользователь найден, логируем это
      if (regularUser != null) {
        if (kDebugMode) {
          print('✅ Сессия восстановлена автоматически');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error during quick auth check: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Сразу используем StreamBuilder без лишних экранов загрузки
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (kDebugMode) {
          print('🔄 Auth state: ${snapshot.data?.uid ?? "не авторизован"}');
        }
        
        // Показываем простую загрузку только когда действительно загружается
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        
        if (user == null) {
          if (kDebugMode) {
            print('❌ Требуется авторизация');
          }
          return AuthFeature(isLogin: true);
        }

        if (kDebugMode) {
          print('✅ Пользователь авторизован: ${user.uid}');
        }
        
        // Проверяем, есть ли стилист в коллекции stylists
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('stylists')
              .doc(user.uid)
              .get(),
          builder: (context, stylistSnapshot) {
            if (stylistSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Если стилист найден, показываем дашборд
            if (stylistSnapshot.hasData && stylistSnapshot.data!.exists) {
              if (kDebugMode) {
                print('✅ Стилист найден, показываем дашборд');
              }
              return LeftNavigationScreen();
            }

            if (kDebugMode) {
              print('⚠️ Стилист не найден, нужно создать профиль');
            }
            return CreatingProfileScreenWeb();
          },
        );
      },
    );
  }
}

