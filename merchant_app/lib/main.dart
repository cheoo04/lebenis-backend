import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/providers.dart';
import 'core/services/analytics_service.dart';
import 'data/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase initialization may fail on some devices - continue anyway
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    // Écouter l'état d'authentification pour rediriger vers l'écran de connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
          try {
            final isLoggedIn = next.asData?.value != null;
            if (!isLoggedIn) {
              final ctx = _navigatorKey.currentContext;
              if (ctx != null) Navigator.pushReplacementNamed(ctx, '/login');
            }
          } catch (_) {}
        });
      } catch (_) {
        // ignore errors — listener not critical
      }
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();

      // Configurer le handler de navigation pour les notifications
      notificationService.onNotificationTap = (data) {
        _handleNotificationNavigation(data);
      };
    } catch (_) {
      // Notification initialization may fail - continue without notifications
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final action = data['action'] as String?;
    final type = data['type'] as String?;


    final context = _navigatorKey.currentContext;
    if (context == null) return;

    // Router selon le type de notification
    switch (type) {
      case 'merchant_approved':
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      
      case 'merchant_rejected':
        Navigator.pushReplacementNamed(context, '/rejected');
        break;
      
      case 'merchant_documents_received':
        Navigator.pushNamed(context, '/profile');
        break;
      
      case 'merchant_delivery_assigned':
        final deliveryId = data['delivery_id'] as String?;
        if (deliveryId != null) {
          Navigator.pushNamed(
            context,
            '/delivery-detail',
            arguments: deliveryId,
          );
        }
        break;
      
      case 'merchant_invoice_paid':
        final invoiceId = data['invoice_id'] as String?;
        if (invoiceId != null) {
          Navigator.pushNamed(
            context,
            '/invoice-detail',
            arguments: invoiceId,
          );
        }
        break;
      
      default:
        // Action par défaut: ouvrir le dashboard
        if (action == 'open_dashboard') {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeBeni Marchands',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: _navigatorKey,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      // Firebase Analytics navigation observer
      navigatorObservers: [
        AnalyticsService().observer,
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
