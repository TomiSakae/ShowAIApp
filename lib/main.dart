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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Nếu đã đăng nhập, chuyển đến MainScreen
          if (snapshot.hasData) {
            return const MainScreen();
          }

          // Nếu chưa đăng nhập, cũng chuyển đến MainScreen
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

  final List<Widget> _screens = [
    const HomePage(),
    const LoginPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Kiểm tra trạng thái đăng nhập
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _isLoggedIn = user != null;
      });
    });
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
    _screens[1] = _isLoggedIn ? const AccountPage() : const LoginPage();

    return Scaffold(
      body: Column(
        children: [
          PersistentSearchBar(
            onTap: _navigateToSearch,
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
