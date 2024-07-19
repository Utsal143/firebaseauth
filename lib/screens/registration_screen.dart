import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlogin/APIservice/api_service.dart';
import 'package:flutterlogin/utilities/constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _googleIdController = TextEditingController();
  final TextEditingController _facebookIdController = TextEditingController();
  final TextEditingController _profilePictureUrlController =
      TextEditingController();
  bool _isLoading = false;

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final googleId = _googleIdController.text.trim();
    final facebookId = _facebookIdController.text.trim();
    final profilePictureUrl = _profilePictureUrlController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        username.isEmpty ||
        fullName.isEmpty ||
        googleId.isEmpty ||
        facebookId.isEmpty ||
        profilePictureUrl.isEmpty) {
      _showErrorDialog('Please fill all the fields');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.signup(email, password, username,
          fullName, googleId, facebookId, profilePictureUrl);

      setState(() {
        _isLoading = false;
      });

      if (response['access_token'] != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Response: $response');
        _showErrorDialog(response['message'] ?? 'Signup failed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: kLabelStyle,
        ),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                icon,
                color: Colors.white,
              ),
              hintText: 'Enter your $label',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signup,
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      _buildTextField('Email', _emailController, Icons.email),
                      const SizedBox(height: 30.0),
                      _buildTextField(
                          'Password', _passwordController, Icons.lock,
                          isPassword: true),
                      const SizedBox(height: 30.0),
                      _buildTextField('Confirm Password',
                          _confirmPasswordController, Icons.lock,
                          isPassword: true),
                      const SizedBox(height: 30.0),
                      _buildTextField(
                          'Username', _usernameController, Icons.person),
                      const SizedBox(height: 30.0),
                      _buildTextField(
                          'Full Name', _fullNameController, Icons.person),
                      const SizedBox(height: 30.0),
                      _buildTextField(
                          'Google ID', _googleIdController, Icons.email),
                      const SizedBox(height: 30.0),
                      _buildTextField(
                          'Facebook ID', _facebookIdController, Icons.facebook),
                      const SizedBox(height: 30.0),
                      _buildTextField('Profile Picture URL',
                          _profilePictureUrlController, Icons.image),
                      _buildSignupBtn(),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
