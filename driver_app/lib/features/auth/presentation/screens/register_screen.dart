import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_text_field.dart';
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
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isValid ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
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
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec gradient vert
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xxxl),
                  bottomRight: Radius.circular(AppRadius.xxxl),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  // Bouton retour
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  // Icône
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      size: 40,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Titre
                  Text(
                    'Créer un compte',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  Text(
                    'Devenez livreur LeBenis',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      
                      // First Name
                      ModernTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        hint: 'Votre prénom',
                        prefixIcon: Icons.person_outlined,
                        validator: (value) => Validators.validateRequired(value, fieldName: 'Prénom'),
                        enabled: !isLoading,
                        textCapitalization: TextCapitalization.words,
                      ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Last Name
                ModernTextField(
                  controller: _lastNameController,
                  label: 'Nom',
                  hint: 'Votre nom',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) => Validators.validateRequired(value, fieldName: 'Nom'),
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Email
                ModernTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'exemple@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) => Validators.validateEmail(value ?? ''),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Phone
                ModernTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  hint: '07 12 34 56 78',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) => Validators.validatePhone(value ?? ''),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Phone format hint
                Text(
                  'Format: 07 12 34 56 78 (Côte d\'Ivoire)',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Vehicle Type
                Text(
                  'Type de véhicule',
                  style: AppTypography.label,
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: _vehicleTypes.map((type) {
                    final isSelected = _selectedVehicleType == type['value'];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: InkWell(
                          onTap: isLoading ? null : () {
                            setState(() {
                              _selectedVehicleType = type['value'];
                            });
                          },
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: 2,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  type['icon'],
                                  color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                                  size: 32,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  type['label'],
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Password
                ModernTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Min 8 caractères, lettres + chiffres',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) => Validators.validatePassword(value ?? ''),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Password requirements hint with real-time feedback
                if (_passwordController.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Force du mot de passe :',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
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
                ],
                
                const SizedBox(height: AppSpacing.lg),
                
                // Confirm Password
                ModernTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: 'Retapez votre mot de passe',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: _validateConfirmPassword,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Register Button
                ModernButton(
                  text: 'S\'inscrire',
                  onPressed: _handleRegister,
                  isLoading: isLoading,
                  icon: Icons.person_add,
                  type: ModernButtonType.primary,
                  size: ModernButtonSize.large,
                  fullWidth: true,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Terms
                Text(
                  'En vous inscrivant, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Error Message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.error, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: AppTypography.bodySmall.copyWith(
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
          ],
        ),
      ),
    );
  }
}
