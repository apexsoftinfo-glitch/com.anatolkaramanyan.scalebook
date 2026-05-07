import 'package:flutter/material.dart';
import '../../../../core/design_system/widgets/cutting_mat_background.dart';

class LinksScreen extends StatelessWidget {
  const LinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LINKI'), // L10N
      ),
      body: const CuttingMatBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link, size: 64, color: Colors.white54),
              SizedBox(height: 16),
              Text(
                'TWOJA BAZA WIEDZY', // L10N
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Zapisuj linki do poradników i sklepów...', // L10N
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
