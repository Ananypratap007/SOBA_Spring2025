import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page background
      backgroundColor: const Color(0XFF4CAF93),
      
      // AppBar with matching color scheme
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0XFF4CAF93),
          ),
        ),
        backgroundColor: const Color(0XFF4CAF93),
        elevation: 0,
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0XFF4CAF93),
        ),
        child: Column(
          children: [
            // Top spacing
            const SizedBox(height: 10),
            
            // Main content area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF003366),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        '1. Acceptance of Terms',
                        'By accessing and using Universal Safety, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, please do not use our application.',
                      ),
                      _buildSection(
                        '2. Privacy Policy',
                        'Your privacy is important to us. We collect and process your personal information in accordance with our Privacy Policy. By using Universal Safety, you consent to such processing.',
                      ),
                      _buildSection(
                        '3. User Responsibilities',
                        'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
                      ),
                      _buildSection(
                        '4. Mental Health Support',
                        'Universal Safety is designed to provide support and resources for mental health. However, it is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your mental health professional or other qualified health provider.',
                      ),
                      _buildSection(
                        '5. Emergency Situations',
                        'In case of emergency, please call 988 or your local emergency services immediately. Universal Safety is not designed to handle emergency situations.',
                      ),
                      _buildSection(
                        '6. Content Guidelines',
                        'Users must not post harmful, threatening, or inappropriate content. We reserve the right to remove any content that violates these guidelines.',
                      ),
                      _buildSection(
                        '7. Modifications',
                        'We reserve the right to modify these terms at any time. We will notify users of any material changes to these terms.',
                      ),
                      _buildSection(
                        '8. Contact',
                        'If you have any questions about these Terms and Conditions, please contact us at support@universalsafety.com',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Last updated: March 2024',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0XFF4CAF93),
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

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0XFF4CAF93).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0XFF4CAF93),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
