import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show utf8, json;
import 'models/website.dart';
import 'screens/search_page.dart';
import 'screens/login_page.dart';
import 'widgets/website_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/account_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/persistent_search_bar.dart';
import 'services/api_service.dart';
import 'screens/chat_page.dart';
import 'theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/banner_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShowAI',
      theme: AppTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }
          return const MainScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/account': (context) => const AccountPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  final _apiService = ApiService();
  bool _showBanner = true;

  final List<Widget> _screens = [
    const HomePage(),
    const ChatPage(),
    const LoginPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerPreference();
    BannerState.showBanner.addListener(_onBannerStateChanged);
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _isLoggedIn = user != null;
      });
    });
  }

  @override
  void dispose() {
    BannerState.showBanner.removeListener(_onBannerStateChanged);
    super.dispose();
  }

  void _onBannerStateChanged() {
    setState(() {
      _showBanner = BannerState.showBanner.value;
    });
  }

  Future<void> _loadBannerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final showBanner = prefs.getBool('show_banner') ?? true;
    setState(() {
      _showBanner = showBanner;
    });
    BannerState.showBanner.value = showBanner;
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _screens[2] = _isLoggedIn ? const AccountPage() : const LoginPage();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex == 0 && _showBanner)
              InkWell(
                onTap: () async {
                  final uri = Uri.parse('https://showai.io.vn');
                  try {
                    if (!await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                      webOnlyWindowName: '_blank',
                    )) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không thể mở link này'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Có lỗi xảy ra khi mở link'),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.8),
                        AppTheme.primaryColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: AppTheme.textColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Truy cập ShowAI trên Web',
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'showai.io.vn',
                              style: TextStyle(
                                color: AppTheme.textColor.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            PersistentSearchBar(
              onTap: _navigateToSearch,
            ),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        backgroundColor: AppTheme.cardColor,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home, color: AppTheme.primaryColor),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat, color: AppTheme.primaryColor),
            label: 'Trò chuyện',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: AppTheme.primaryColor),
            label: _isLoggedIn ? 'Tài khoản' : 'Đăng nhập',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Website> websites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWebsites();
  }

  Future<void> fetchWebsites() async {
    try {
      final response =
          await http.get(Uri.parse('https://showai.io.vn/api/showai'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          websites = (data['data'] as List)
              .map((item) => Website.fromJson(item))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: websites.length,
              itemBuilder: (context, index) {
                return WebsiteCard(website: websites[index]);
              },
            ),
    );
  }
}
