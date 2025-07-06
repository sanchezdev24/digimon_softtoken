import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 40),
            
            // Title
            Text(
              'Digimon SoftToken',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 8),
            
            Text(
              'Generador de OTP Seguro',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            
            SizedBox(height: 60),
            
            // Loading indicator
            SpinKitWave(
              color: Colors.white,
              size: 40,
            ),
            
            SizedBox(height: 20),
            
            // Loading message
            Obx(() => Text(
              controller.loadingMessage.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            )),
            
            SizedBox(height: 20),
            
            // Progress bar
            Container(
              width: 200,
              child: Obx(() => LinearProgressIndicator(
                value: controller.progress.value,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )),
            ),
            
            SizedBox(height: 60),
            
            // Version info
            Text(
              'Versión 1.0.0',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Skip button (for development)
            TextButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text(
                'Saltar inicialización',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}