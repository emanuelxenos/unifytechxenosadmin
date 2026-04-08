import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/validators.dart';
import 'package:unifytechxenosadmin/data/local/local_config.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

class ServerConfigScreen extends ConsumerStatefulWidget {
  final VoidCallback onConfigured;
  const ServerConfigScreen({super.key, required this.onConfigured});

  @override
  ConsumerState<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends ConsumerState<ServerConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController(text: 'localhost');
  final _portController = TextEditingController(text: '8080');
  bool _testing = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    final config = ref.read(localConfigProvider);
    if (config.hasServerConfig) {
      _hostController.text = config.serverHost;
      _portController.text = config.serverPort.toString();
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _testResult = null;
      _testSuccess = null;
    });

    try {
      final config = ref.read(localConfigProvider);
      await config.setServer(
        _hostController.text.trim(),
        int.parse(_portController.text.trim()),
      );
      final api = ref.read(apiServiceProvider);
      final success = await api.testConnection();

      setState(() {
        _testing = false;
        _testSuccess = success;
        _testResult = success
            ? 'Conexão estabelecida com sucesso!'
            : 'Não foi possível conectar ao servidor';
      });
    } catch (e) {
      setState(() {
        _testing = false;
        _testSuccess = false;
        _testResult = 'Erro: ${e.toString()}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final config = ref.read(localConfigProvider);
    await config.setServer(
      _hostController.text.trim(),
      int.parse(_portController.text.trim()),
    );
    widget.onConfigured();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(40),
          decoration: AppTheme.glassCard(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.dns_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  'Configurar Servidor',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Informe o endereço do servidor para conectar o sistema',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço do Servidor',
                    hintText: 'localhost ou 192.168.1.100',
                    prefixIcon: Icon(Icons.computer_rounded),
                  ),
                  validator: Validators.ipAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Porta',
                    hintText: '8080',
                    prefixIcon: Icon(Icons.settings_ethernet_rounded),
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.port,
                ),
                const SizedBox(height: 24),
                if (_testResult != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: (_testSuccess == true
                              ? AppTheme.accentGreen
                              : AppTheme.accentRed)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (_testSuccess == true
                                ? AppTheme.accentGreen
                                : AppTheme.accentRed)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _testSuccess == true
                              ? Icons.check_circle
                              : Icons.error,
                          color: _testSuccess == true
                              ? AppTheme.accentGreen
                              : AppTheme.accentRed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testResult!,
                            style: TextStyle(
                              color: _testSuccess == true
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentRed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _testConnection,
                        icon: _testing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.wifi_find_rounded, size: 18),
                        label: Text(_testing ? 'Testando...' : 'Testar Conexão'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
