import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/data/local/local_config.dart';
import 'package:unifytechxenosadmin/presentation/providers/auth_provider.dart';
import 'package:unifytechxenosadmin/presentation/views/shell/app_shell.dart';
import 'package:unifytechxenosadmin/presentation/views/login/login_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/server_config/server_config_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/dashboard/dashboard_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/products/products_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/categories/categories_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/stock/stock_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/sales/sales_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/purchases_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/finance/finance_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/reports/reports_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/settings/settings_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/customers/customers_screen.dart';
import 'package:unifytechxenosadmin/presentation/views/stock/inventory_counting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final config = LocalConfig(prefs);

  runApp(
    ProviderScope(
      overrides: [
        localConfigProvider.overrideWithValue(config),
      ],
      child: const UnifyTechAdminApp(),
    ),
  );
}

class UnifyTechAdminApp extends ConsumerWidget {
  const UnifyTechAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final localConfig = ref.watch(localConfigProvider);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLogin = state.uri.toString() == '/login';
        final isServerConfig = state.uri.toString() == '/server-config';

        // If no server config, go to server config
        if (!localConfig.hasServerConfig && !isServerConfig) {
          return '/server-config';
        }

        // If not authenticated and not on login/server-config, go to login
        if (!authState.isAuthenticated && !isLogin && !isServerConfig) {
          return '/login';
        }

        // If authenticated and on login, go to dashboard
        if (authState.isAuthenticated && isLogin) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/server-config',
          builder: (context, state) => ServerConfigScreen(
            onConfigured: () => context.go('/login'),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/produtos',
              builder: (context, state) => const ProductsScreen(),
            ),
            GoRoute(
              path: '/categorias',
              builder: (context, state) => const CategoriesScreen(),
            ),
            GoRoute(
              path: '/clientes',
              builder: (context, state) => const CustomersScreen(),
            ),
            GoRoute(
              path: '/estoque',
              builder: (context, state) => const StockScreen(),
              routes: [
                GoRoute(
                  path: 'contagem/:id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return InventoryCountingScreen(inventoryId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/vendas',
              builder: (context, state) => const SalesScreen(),
            ),
            GoRoute(
              path: '/compras',
              builder: (context, state) => const PurchasesScreen(),
            ),
            GoRoute(
              path: '/financeiro',
              builder: (context, state) => const FinanceScreen(),
            ),
            GoRoute(
              path: '/relatorios',
              builder: (context, state) => const ReportsScreen(),
            ),
            GoRoute(
              path: '/configuracoes',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'UnifyTech Xenos - Admin',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const CustomScrollBehavior(),
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (axisDirectionToAxis(details.direction)) {
      case Axis.horizontal:
        return Scrollbar(
          controller: details.controller,
          thumbVisibility: true,
          trackVisibility: false,
          child: child,
        );
      case Axis.vertical:
        return Scrollbar(
          controller: details.controller,
          thumbVisibility: true,
          trackVisibility: false,
          child: child,
        );
    }
  }
}
