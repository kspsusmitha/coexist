import 'package:flutter/material.dart';
import 'animal_detection_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Co-Exist'),
        backgroundColor: Colors.green,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFeatureCard(
            context,
            'Animal Detection',
            Icons.camera_alt,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnimalDetectionView()),
            ),
          ),
          _buildFeatureCard(
            context,
            'Wildlife Guide',
            Icons.menu_book,
            () {
              // TODO: Implement wildlife guide
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          _buildFeatureCard(
            context,
            'Conservation Tips',
            Icons.eco,
            () {
              // TODO: Implement conservation tips
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          _buildFeatureCard(
            context,
            'Report Wildlife',
            Icons.report,
            () {
              // TODO: Implement wildlife reporting
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnimalDetectionView()),
        ),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Detect Animal'),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 