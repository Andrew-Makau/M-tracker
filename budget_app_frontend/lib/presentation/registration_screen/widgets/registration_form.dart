import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationForm extends StatefulWidget {
  final Function(bool) onValidationChanged;
  final Function(Map<String, String>) onFormDataChanged;

  const RegistrationForm({
    super.key,
    required this.onValidationChanged,
    required this.onFormDataChanged,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  final Map<String, bool> _passwordRequirements = {
    'length': false,
    'uppercase': false,
    'lowercase': false,
    'number': false,
    'special': false,
  };

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(() {
      _validatePassword();
      _validateForm();
    });
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      _passwordRequirements['length'] = password.length >= 8;
      _passwordRequirements['uppercase'] = password.contains(RegExp(r'[A-Z]'));
      _passwordRequirements['lowercase'] = password.contains(RegExp(r'[a-z]'));
      _passwordRequirements['number'] = password.contains(RegExp(r'[0-9]'));
      _passwordRequirements['special'] =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      final validCount = _passwordRequirements.values.where((v) => v).length;

      if (validCount <= 2) {
        _passwordStrength = 'Weak';
        _passwordStrengthColor = AppTheme.lightTheme.colorScheme.error;
      } else if (validCount <= 3) {
        _passwordStrength = 'Fair';
        _passwordStrengthColor = Colors.orange;
      } else if (validCount <= 4) {
        _passwordStrength = 'Good';
        _passwordStrengthColor = Colors.blue;
      } else {
        _passwordStrength = 'Strong';
        _passwordStrengthColor = AppTheme.lightTheme.colorScheme.tertiary;
      }
    });
  }

  void _validateForm() {
    final isValid = _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _passwordRequirements.values.every((v) => v) &&
        _acceptTerms;

    widget.onValidationChanged(isValid);

    widget.onFormDataChanged({
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFloatingTextField(
            controller: _fullNameController,
            label: 'Full Name',
            iconName: 'person',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),
          _buildFloatingTextField(
            controller: _emailController,
            label: 'Email Address',
            iconName: 'email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!_isValidEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),
          _buildFloatingTextField(
            controller: _passwordController,
            label: 'Password',
            iconName: 'lock',
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onTogglePassword: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (!_passwordRequirements.values.every((v) => v)) {
                return 'Password does not meet requirements';
              }
              return null;
            },
          ),
          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            _buildPasswordStrengthIndicator(),
            SizedBox(height: 1.h),
            _buildPasswordRequirements(),
          ],
          SizedBox(height: 3.h),
          _buildFloatingTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            iconName: 'lock',
            isPassword: true,
            isPasswordVisible: _isConfirmPasswordVisible,
            onTogglePassword: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),
          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildFloatingTextField({
    required TextEditingController controller,
    required String label,
    required String iconName,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Material(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        elevation: 6,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !isPasswordVisible,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.disabled,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: iconName,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onTogglePassword,
                    icon: CustomIconWidget(
                      iconName:
                          isPasswordVisible ? 'visibility_off' : 'visibility',
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : null,

            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.2.h),

            // Let the field manage borders so error/help space is reserved
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 2,
              ),
            ),
            errorStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
            labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withAlpha(220),
            ),
            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withAlpha(180),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              _passwordStrength,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: _passwordStrengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: _passwordRequirements.values.where((v) => v).length / 5,
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Requirements:',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        SizedBox(height: 0.5.h),
        ..._passwordRequirements.entries.map((entry) {
          String requirement = '';
          switch (entry.key) {
            case 'length':
              requirement = 'At least 8 characters';
              break;
            case 'uppercase':
              requirement = 'One uppercase letter';
              break;
            case 'lowercase':
              requirement = 'One lowercase letter';
              break;
            case 'number':
              requirement = 'One number';
              break;
            case 'special':
              requirement = 'One special character';
              break;
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName:
                      entry.value ? 'check_circle' : 'radio_button_unchecked',
                  size: 16,
                  color: entry.value
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 2.w),
                Text(
                  requirement,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: entry.value
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : Theme.of(context).colorScheme.onPrimary.withAlpha(200),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
              _validateForm();
            });
          },
          activeColor: AppTheme.lightTheme.colorScheme.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
                _validateForm();
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
