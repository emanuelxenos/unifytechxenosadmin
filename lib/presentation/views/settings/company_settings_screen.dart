import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/domain/models/company.dart';
import 'package:unifytechxenosadmin/presentation/providers/empresa_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends ConsumerState<CompanySettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _razaoSocialCtrl = TextEditingController();
  final _nomeFantasiaCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _ieCtrl = TextEditingController();
  final _imCtrl = TextEditingController();
  final _logradouroCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _complementoCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _telefone2Ctrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _siteCtrl = TextEditingController();
  final _moedaCtrl = TextEditingController();
  final _casasDecimaisCtrl = TextEditingController();
  final _fusoHorarioCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  final _corPrimariaCtrl = TextEditingController();
  final _corSecundariaCtrl = TextEditingController();
  final _observacoesCtrl = TextEditingController();

  String _regimeTributario = 'SIMPLES';

  // Formatters
  final _cnpjFormatter = MaskTextInputFormatter(mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9A-Za-z]')});
  final _cepFormatter = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});
  final _phoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _phone2Formatter = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  bool _initialized = false;

  void _initFields(Empresa empresa) {
    if (_initialized) return;
    
    _razaoSocialCtrl.text = empresa.razaoSocial;
    _nomeFantasiaCtrl.text = empresa.nomeFantasia;
    _cnpjCtrl.text = _cnpjFormatter.maskText(empresa.cnpj.replaceAll(RegExp(r'[^0-9A-Za-z]'), ''));
    _ieCtrl.text = empresa.inscricaoEstadual ?? '';
    _imCtrl.text = empresa.inscricaoMunicipal ?? '';
    _logradouroCtrl.text = empresa.logradouro;
    _numeroCtrl.text = empresa.numero;
    _complementoCtrl.text = empresa.complemento ?? '';
    _bairroCtrl.text = empresa.bairro;
    _cidadeCtrl.text = empresa.cidade;
    _estadoCtrl.text = empresa.estado;
    _cepCtrl.text = _cepFormatter.maskText(empresa.cep.replaceAll(RegExp(r'[^0-9]'), ''));
    _telefoneCtrl.text = _phoneFormatter.maskText(empresa.telefone.replaceAll(RegExp(r'[^0-9]'), ''));
    _telefone2Ctrl.text = empresa.telefone2 != null ? _phone2Formatter.maskText(empresa.telefone2!.replaceAll(RegExp(r'[^0-9]'), '')) : '';
    _emailCtrl.text = empresa.email;
    _siteCtrl.text = empresa.site ?? '';
    _moedaCtrl.text = empresa.moeda;
    _casasDecimaisCtrl.text = empresa.casasDecimais.toString();
    _fusoHorarioCtrl.text = empresa.fusoHorario;
    _logoUrlCtrl.text = empresa.logotipoUrl ?? '';
    _corPrimariaCtrl.text = empresa.corPrimaria;
    _corSecundariaCtrl.text = empresa.corSecundaria;
    _observacoesCtrl.text = empresa.observacoes ?? '';
    _regimeTributario = empresa.regimeTributario;

    _initialized = true;
  }

  @override
  void dispose() {
    _razaoSocialCtrl.dispose();
    _nomeFantasiaCtrl.dispose();
    _cnpjCtrl.dispose();
    _ieCtrl.dispose();
    _imCtrl.dispose();
    _logradouroCtrl.dispose();
    _numeroCtrl.dispose();
    _complementoCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _cepCtrl.dispose();
    _telefoneCtrl.dispose();
    _telefone2Ctrl.dispose();
    _emailCtrl.dispose();
    _siteCtrl.dispose();
    _moedaCtrl.dispose();
    _casasDecimaisCtrl.dispose();
    _fusoHorarioCtrl.dispose();
    _logoUrlCtrl.dispose();
    _corPrimariaCtrl.dispose();
    _corSecundariaCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(Empresa current) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Empresa(
      idEmpresa: current.idEmpresa,
      razaoSocial: _razaoSocialCtrl.text,
      nomeFantasia: _nomeFantasiaCtrl.text,
      cnpj: _cnpjCtrl.text.replaceAll(RegExp(r'[^0-9A-Za-z]'), ''),
      inscricaoEstadual: _ieCtrl.text.isEmpty ? null : _ieCtrl.text,
      inscricaoMunicipal: _imCtrl.text.isEmpty ? null : _imCtrl.text,
      logradouro: _logradouroCtrl.text,
      numero: _numeroCtrl.text,
      complemento: _complementoCtrl.text.isEmpty ? null : _complementoCtrl.text,
      bairro: _bairroCtrl.text,
      cidade: _cidadeCtrl.text,
      estado: _estadoCtrl.text,
      cep: _cepCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
      telefone: _telefoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
      telefone2: _telefone2Ctrl.text.isEmpty ? null : _telefone2Ctrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
      email: _emailCtrl.text,
      site: _siteCtrl.text.isEmpty ? null : _siteCtrl.text,
      regimeTributario: _regimeTributario,
      moeda: _moedaCtrl.text,
      casasDecimais: int.tryParse(_casasDecimaisCtrl.text) ?? 2,
      fusoHorario: _fusoHorarioCtrl.text,
      logotipoUrl: _logoUrlCtrl.text.isEmpty ? null : _logoUrlCtrl.text,
      corPrimaria: _corPrimariaCtrl.text,
      corSecundaria: _corSecundariaCtrl.text,
      observacoes: _observacoesCtrl.text.isEmpty ? null : _observacoesCtrl.text,
      ativo: current.ativo,
      dataCadastro: current.dataCadastro,
      dataAtualizacao: DateTime.now(),
    );

    try {
      await ref.read(empresaStateProvider.notifier).atualizarEmpresa(updated);
      if (mounted) {
        AppNotifications.showSuccess(context, 'Configurações da empresa atualizadas!');
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, 'Erro ao salvar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final empresaAsync = ref.watch(empresaStateProvider);
    final theme = Theme.of(context);

    return empresaAsync.when(
      data: (empresa) {
        _initFields(empresa);
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Dados Fiscais', Icons.business_rounded, theme),
                _buildCard([
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildTextField('Razão Social *', _razaoSocialCtrl, validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Nome Fantasia *', _nomeFantasiaCtrl, validator: _requiredValidator)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('CNPJ *', _cnpjCtrl, formatters: [_cnpjFormatter], validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Inscrição Estadual', _ieCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Inscrição Municipal', _imCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _regimeTributario,
                    decoration: const InputDecoration(labelText: 'Regime Tributário'),
                    items: const [
                      DropdownMenuItem(value: 'SIMPLES', child: Text('Simples Nacional')),
                      DropdownMenuItem(value: 'LUCRO_PRESUMIDO', child: Text('Lucro Presumido')),
                      DropdownMenuItem(value: 'LUCRO_REAL', child: Text('Lucro Real')),
                    ],
                    onChanged: (v) => setState(() => _regimeTributario = v!),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Endereço', Icons.location_on_rounded, theme),
                _buildCard([
                  Row(
                    children: [
                      Expanded(child: _buildTextField('CEP *', _cepCtrl, formatters: [_cepFormatter], validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: _buildTextField('Logradouro *', _logradouroCtrl, validator: _requiredValidator)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Número *', _numeroCtrl, validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Complemento', _complementoCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Bairro *', _bairroCtrl, validator: _requiredValidator)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildTextField('Cidade *', _cidadeCtrl, validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Estado (UF) *', _estadoCtrl, validator: _requiredValidator)),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Contato & Sistema', Icons.settings_suggest_rounded, theme),
                _buildCard([
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Telefone *', _telefoneCtrl, formatters: [_phoneFormatter], validator: _requiredValidator)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('E-mail *', _emailCtrl, validator: _requiredValidator)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Moeda', _moedaCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Casas Decimais', _casasDecimaisCtrl, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Fuso Horário', _fusoHorarioCtrl)),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Identidade Visual', Icons.palette_rounded, theme),
                _buildCard([
                  _buildTextField('Logotipo URL', _logoUrlCtrl),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Cor Primária', _corPrimariaCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Cor Secundária', _corSecundariaCtrl)),
                    ],
                  ),
                ]),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: empresaAsync.isLoading ? null : () => _save(empresa),
                    icon: empresaAsync.isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded),
                    label: Text(empresaAsync.isLoading ? 'Salvando...' : 'Salvar Configurações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: LoadingOverlay(message: 'Carregando dados da empresa...')),
      error: (err, stack) => Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Erro ao carregar',
          subtitle: err.toString(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    String? Function(String?)? validator,
    List<MaskTextInputFormatter>? formatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: formatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String? _requiredValidator(String? v) => (v == null || v.isEmpty) ? 'Obrigatório' : null;
}
