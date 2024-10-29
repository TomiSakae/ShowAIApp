import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show utf8, json;
import 'models/website.dart';
import 'screens/search_page.dart';
import 'screens/login_page.dart';
import 'widgets/website_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShowAI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const SearchPage(),
    const HomePage(),
    const LoginPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Đăng nhập',
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
      appBar: AppBar(
        title: const Text('ShowAI'),
      ),
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
