import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';
import 'focus_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专注树'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              '选择专注时长',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildDurationCard(context, 30, 'assets/images/tree_30min.png'),
                  _buildDurationCard(context, 45, 'assets/images/tree_45min.png'),
                  _buildDurationCard(context, 60, 'assets/images/tree_60min.png'),
                  _buildDurationCard(context, 120, 'assets/images/tree_120min.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(BuildContext context, int minutes, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // Start focus session and navigate to focus page
          Provider.of<FocusProvider>(context, listen: false)
              .startFocus(minutes, imagePath);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FocusPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$minutes 分钟',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 