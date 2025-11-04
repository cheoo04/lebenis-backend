import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/utils/helpers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedVehicleType = BackendConstants.vehicleTypeMoto;
  
  // Password strength indicators
  bool _passwordHasMinLength = false;
  bool _passwordHasMixedContent = false;
  bool _passwordNotCommon = false;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'value': BackendConstants.vehicleTypeMoto,
      'label': BackendConstants.getVehicleTypeLabel(BackendConstants.vehicleTypeMoto),
      'icon': Icons.two_wheeler
    },
    {
      'value': BackendConstants.vehicleTypeVoiture,
      'label': BackendConstants.getVehicleTypeLabel(BackendConstants.vehicleTypeVoiture),
      'icon': Icons.directions_car
    },
    {
      'value': BackendConstants.vehicleTypeCamionnette,
      'label': BackendConstants.getVehicleTypeLabel(BackendConstants.vehicleTypeCamionnette),
      'icon': Icons.local_shipping
    },
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Listen to password changes for real-time validation feedback
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _passwordHasMinLength = password.length >= 8;
      
      final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
      final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
      _passwordHasMixedContent = hasLetters && hasNumbers;
      
      final isNumericOnly = RegExp(r'^\d+$').hasMatch(password);
      final commonPasswords = [
        'password', 'password123', '12345678', '123456789',
        'qwerty', 'abc123', 'password1',
      ];
      _passwordNotCommon = password.isNotEmpty && 
                          !isNumericOnly && 
                          !commonPasswords.contains(password.toLowerCase());
    });
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Widget _buildPasswordStrengthIndicator(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.spacingXS),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isValid ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: Dimensions.spacingXS),
          Expanded(
            child: Text(
              text,
              style: TextStyles.caption.copyWith(
                color: isValid ? AppColors.success : AppColors.textSecondary,
                fontWeight: isValid ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Helpers.unfocus(context);

    try {
      await ref.read(authProvider.notifier).registerDriver(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        vehicleType: _selectedVehicleType,
        firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
      );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.isLoggedIn) {
        Helpers.showSuccessSnackBar(context, 'Inscription réussie! Bienvenue!');
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (authState.error != null) {
        Helpers.showErrorSnackBar(context, authState.error!);
      }
    } catch (e) {
      if (!mounted) return;
      // Ne pas afficher l'erreur ici car elle est déjà dans authState.error
      // et sera affichée par le widget d'erreur en bas de l'écran
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Dimensions.spacingL),
                
                // Title
                Text(
                  'Devenez livreur LeBenis',
                  style: TextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: Dimensions.spacingS),
                
                Text(
                  'Remplissez le formulaire pour commencer',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: Dimensions.spacingXL),
                
                // First Name
                CustomTextField(
                  controller: _firstNameController,
                  label: 'Prénom',
                  hint: 'Votre prénom',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) => Validators.validateRequired(value, fieldName: 'Prénom'),
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Last Name
                CustomTextField(
                  controller: _lastNameController,
                  label: 'Nom',
                  hint: 'Votre nom',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) => Validators.validateRequired(value, fieldName: 'Nom'),
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'exemple@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) => Validators.validateEmail(value ?? ''),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Phone
                CustomTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  hint: '07 12 34 56 78',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) => Validators.validatePhone(value ?? ''),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: Dimensions.spacingS),
                
                // Phone format hint
                Text(
                  'Format: 07 12 34 56 78 (Côte d\'Ivoire)',
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Vehicle Type
                Text(
                  'Type de véhicule',
                  style: TextStyles.labelMedium,
                ),
                
                const SizedBox(height: Dimensions.spacingM),
                
                Row(
                  children: _vehicleTypes.map((type) {
                    final isSelected = _selectedVehicleType == type['value'];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: Dimensions.spacingS),
                        child: InkWell(
                          onTap: isLoading ? null : () {
                            setState(() {
                              _selectedVehicleType = type['value'];
                            });
                          },
                          borderRadius: BorderRadius.circular(Dimensions.radiusM),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.spacingM,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.grey[100],
                              borderRadius: BorderRadius.circular(Dimensions.radiusM),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  type['icon'],
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  size: Dimensions.iconL,
                                ),
                                const SizedBox(height: Dimensions.spacingXS),
                                Text(
                                  type['label'],
                                  style: TextStyles.labelSmall.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Min 8 caractères, lettres + chiffres',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) => Validators.validatePassword(value ?? ''),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: Dimensions.spacingS),
                
                // Password requirements hint with real-time feedback
                if (_passwordController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(Dimensions.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusS),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Force du mot de passe :',
                          style: TextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: Dimensions.spacingXS),
                        _buildPasswordStrengthIndicator(
                          'Au moins 8 caractères',
                          _passwordHasMinLength,
                        ),
                        _buildPasswordStrengthIndicator(
                          'Mélange de lettres et chiffres',
                          _passwordHasMixedContent,
                        ),
                        _buildPasswordStrengthIndicator(
                          'Pas un mot de passe courant',
                          _passwordNotCommon,
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: 'Retapez votre mot de passe',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: _validateConfirmPassword,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: Dimensions.spacingXL),
                
                // Register Button
                CustomButton(
                  text: 'S\'inscrire',
                  onPressed: _handleRegister,
                  isLoading: isLoading,
                  icon: Icons.person_add,
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Terms
                Text(
                  'En vous inscrivant, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité',
                  style: TextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Error Message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(Dimensions.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusM),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: Dimensions.spacingS),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
