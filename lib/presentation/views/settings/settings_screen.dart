import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/data/local/local_config.dart';
import 'package:unifytechxenosadmin/presentation/providers/auth_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/user.dart';
import 'package:unifytechxenosadmin/data/repositories/user_repository.dart';
import 'package:unifytechxenosadmin/presentation/views/settings/company_settings_screen.dart';
import 'package:unifytechxenosadmin/presentation/providers/user_management_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _userTableController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userTableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configurações', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Gerenciamento do sistema', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Servidor'),
                  Tab(text: 'Empresa'),
                  Tab(text: 'Usuários'),
                  Tab(text: 'Sistema'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ServerSettingsTab(),
                  const CompanySettingsScreen(),
                  _UsersSettingsTab(controller: _userTableController),
                  _SystemSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerSettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(localConfigProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Configuração do Servidor', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          _settingRow('Host', config.serverHost, theme),
          _settingRow('Porta', '${config.serverPort}', theme),
          _settingRow('URL Base', 'http://${config.serverHost}:${config.serverPort}', theme),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Para alterar o servidor, faça logout e reconfigure.')),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Alterar Servidor'),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _UsersSettingsTab extends ConsumerWidget {
  final ScrollController controller;
  const _UsersSettingsTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Usuários do Sistema', style: theme.textTheme.titleLarge),
              ElevatedButton.icon(
                onPressed: () => _showUserDialog(context, ref),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Novo Usuário'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ref.watch(userManagementProvider).when(
              data: (users) {
                if (users.isEmpty) {
                  return const EmptyState(icon: Icons.people_outline, title: 'Nenhum usuário');
                }
                return Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Scrollbar(
                      controller: controller,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: controller,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('NOME')),
                            DataColumn(label: Text('LOGIN')),
                            DataColumn(label: Text('PERFIL')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('AÇÕES')),
                          ],
                          rows: users.map((u) => DataRow(cells: [
                            DataCell(Text(u.nome)),
                            DataCell(Text(u.login)),
                            DataCell(StatusChip(label: u.perfil.toUpperCase(), color: AppTheme.primaryColor)),
                            DataCell(StatusChip.fromStatus(u.ativo ? 'ativo' : 'inativo')),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryColor),
                                  onPressed: () => _showUserDialog(context, ref, usuario: u),
                                  tooltip: 'Editar Usuário',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.accentRed),
                                  onPressed: () => _confirmInactivateUser(context, ref, u),
                                  tooltip: 'Inativar Usuário',
                                ),
                              ],
                            )),
                          ])).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const LoadingOverlay(message: 'Carregando usuários...'),
              error: (err, stack) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: err.toString()),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmInactivateUser(BuildContext context, WidgetRef ref, Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inativação'),
        content: Text('Deseja realmente inativar o usuário "${usuario.nome}"? Ele não poderá mais acessar o sistema.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(userManagementProvider.notifier).inativarUsuario(usuario.idUsuario);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Inativar'),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, WidgetRef ref, {Usuario? usuario}) {
    final nomeCtrl = TextEditingController(text: usuario?.nome);
    final loginCtrl = TextEditingController(text: usuario?.login);
    final senhaCtrl = TextEditingController();
    String perfil = usuario?.perfil ?? 'caixa';
    final formKey = GlobalKey<FormState>();
    final isEditing = usuario != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome *'), validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: loginCtrl, decoration: const InputDecoration(labelText: 'Login *'), validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: senhaCtrl, 
                    decoration: InputDecoration(
                      labelText: isEditing ? 'Nova Senha (deixe em branco para manter)' : 'Senha *'
                    ), 
                    obscureText: true, 
                    validator: (v) {
                      if (!isEditing && (v == null || v.length < 4)) return 'Mínimo 4 caracteres';
                      if (isEditing && v != null && v.isNotEmpty && v.length < 4) return 'Mínimo 4 caracteres';
                      return null;
                    }
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: perfil,
                    decoration: const InputDecoration(labelText: 'Perfil'),
                    items: const [
                      DropdownMenuItem(value: 'caixa', child: Text('Caixa')),
                      DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                      DropdownMenuItem(value: 'gerente', child: Text('Gerente')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    ],
                    onChanged: (v) => setDialogState(() => perfil = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  final req = CriarUsuarioRequest(
                    nome: nomeCtrl.text,
                    login: loginCtrl.text,
                    senha: senhaCtrl.text,
                    perfil: perfil,
                  );
                  
                  if (isEditing) {
                    await ref.read(userManagementProvider.notifier).atualizarUsuario(usuario!.idUsuario, req);
                  } else {
                    await ref.read(userManagementProvider.notifier).criarUsuario(req);
                  }
                  
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
                  }
                }
              },
              child: Text(isEditing ? 'Salvar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemSettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sistema', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
            ),
            title: const Text('Versão do Sistema'),
            subtitle: const Text('v1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.backup_outlined, color: AppTheme.accentGreen),
            ),
            title: const Text('Backup'),
            subtitle: const Text('Criar backup do banco de dados'),
            trailing: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade de backup será disponibilizada em breve')),
                );
              },
              child: const Text('Executar'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: AppTheme.accentRed),
            ),
            title: const Text('Sair do Sistema'),
            subtitle: const Text('Desconectar e voltar para a tela de login'),
            trailing: ElevatedButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
