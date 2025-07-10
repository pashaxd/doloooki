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
    print('🚀 Initializing Firebase...');
    
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      print('📱 No Firebase apps found, initializing...');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print('✅ Firebase initialized successfully');
    } else {
      print('♻️ Firebase already initialized, using existing app');
    }
    
    // Setup persistence for web - CRITICAL for session persistence
    if (kIsWeb) {
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        print('🌐 Firebase Auth persistence set for web');
      } catch (e) {
        print('⚠️ Warning: Could not set web persistence: $e');
      }
    }
    
    print('📊 Firebase apps count: ${Firebase.apps.length}');
    print('🏷️ Default Firebase app name: ${Firebase.app().name}');
    print('🔑 Project ID: ${Firebase.app().options.projectId}');
    
    // Test Firebase Auth with detailed token info
    try {
      print('🔐 Testing Firebase Auth...');
      final currentUser = FirebaseAuth.instance.currentUser;
      print('👤 Current user: ${currentUser?.uid ?? "not authenticated"}');
      
      if (currentUser != null) {
        print('📧 User email: ${currentUser.email}');
        print('✅ User email verified: ${currentUser.emailVerified}');
        print('🔄 User anonymous: ${currentUser.isAnonymous}');
        
        // Get ID token to check claims
        try {
          final idToken = await currentUser.getIdToken();
          if (idToken != null) {
            print('🎫 ID Token: ${idToken.length > 50 ? idToken.substring(0, 50) : idToken}...');
          } else {
            print('🎫 ID Token: null');
          }
          
          final tokenResult = await currentUser.getIdTokenResult();
          print('🔒 Token claims: ${tokenResult.claims}');
          print('🕐 Token issued at: ${tokenResult.issuedAtTime}');
          print('⏰ Token expires at: ${tokenResult.expirationTime}');
          
        } catch (e) {
          print('❌ Error getting ID token: $e');
        }
      }
    } catch (e) {
      print('❌ Error with Firebase Auth: $e');
    }
    
    // Test Firestore accessibility with better error handling
    try {
      print('🔍 Testing Firestore accessibility...');
      // Тест 1: Простое чтение коллекции с детальной ошибкой
      print('📝 Test 1: Reading collection...');
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('test')
            .limit(1)
            .get(const GetOptions(source: Source.server));
        print('✅ Firestore collection read successful! Documents: ${querySnapshot.docs.length}');
      } catch (e) {
        print('❌ Firestore read error: $e');
        
        // Попробуем получить более детальную ошибку
        if (e.toString().contains('PERMISSION_DENIED')) {
          print('🚫 Permission denied - checking auth state...');
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            print('❌ User is not authenticated');
          } else {
            print('✅ User is authenticated: ${user.uid}');
            print('📧 User email: ${user.email}');
            print('✅ Email verified: ${user.emailVerified}');
          }
        }
        
        // Попробуем другой подход - создать документ напрямую
        print('📝 Test 1b: Trying to create document directly...');
        try {
          await FirebaseFirestore.instance
              .collection('debug')
              .doc('test')
              .set({
            'message': 'Debug test',
            'timestamp': FieldValue.serverTimestamp(),
            'user': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous'
          });
          print('✅ Document creation successful!');
        } catch (createError) {
          print('❌ Document creation failed: $createError');
          
          // Если все тесты проваливаются, попробуем выйти и войти заново
          print('🔄 Attempting to sign out and sign in again...');
          try {
            await FirebaseAuth.instance.signOut();
            print('✅ Signed out successfully');
            
            // Войдём анонимно для тестирования
            final userCredential = await FirebaseAuth.instance.signInAnonymously();
            print('✅ Signed in anonymously: ${userCredential.user?.uid}');
            
            // Попробуем создать документ снова
            await FirebaseFirestore.instance
                .collection('debug')
                .doc('test_new_user')
                .set({
              'message': 'Test with new anonymous user',
              'timestamp': FieldValue.serverTimestamp(),
              'user': userCredential.user?.uid ?? 'anonymous_new'
            });
            print('✅ Firestore works with new user!');
            
          } catch (authError) {
            print('❌ Auth reset failed: $authError');
          }
        }
      }
      
    } catch (e) {
      print('❌ Error accessing Firestore: $e');
      // Дополнительная диагностика
      print('🔍 Additional diagnostics:');
      print('   - Current user: ${FirebaseAuth.instance.currentUser?.uid ?? "Not signed in"}');
      print('   - App name: ${Firebase.app().name}');
      print('   - Project ID: ${Firebase.app().options.projectId}');
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('💥 Error initializing Firebase: $e');
    print('📚 Stack trace: $stackTrace');
    
    // Handle specific Firebase errors
    if (e.toString().contains('duplicate-app')) {
      print('🔄 Firebase app already exists, continuing with existing app...');
      runApp(const MyApp());
    } else if (e.toString().contains('network')) {
      print('🌐 Network error - please check your internet connection');
      runApp(MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.orange[600],
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 64, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Проблема с подключением к интернету',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ));
    } else {
      // Don't use LoadingScreen here as ScreenUtil is not initialized yet
      runApp(MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red[600],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Ошибка инициализации Firebase',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ));
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Add design size for ScreenUtil
      minTextAdapt: true,
      splitScreenMode: true,
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

                // Check if user profile exists
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // If profile doesn't exist, show profile creation screen
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return CreatingProfileScreen();
                    }

                    // If profile exists, show main screen
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

            if (stylistSnapshot.hasData && stylistSnapshot.data!.exists) {
              final stylistData = stylistSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              final name = stylistData['name']?.toString().trim() ?? '';
              if (name.isEmpty) {
                if (kDebugMode) print('⚠️ Имя стилиста не заполнено, отправляем на создание профиля');
                return CreatingProfileScreenWeb();
              }
              if (kDebugMode) print('✅ Стилист найден и имя заполнено, показываем дашборд');
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

