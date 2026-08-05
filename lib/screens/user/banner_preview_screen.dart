import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';

class BannerPreviewScreen extends StatelessWidget {
  static const routeName = '/banner-preview';

  const BannerPreviewScreen({super.key});

  static const _images = [
    'assets/images/living room.png',
    'assets/images/bed room.png',
    'assets/images/launge.png',
    'assets/images/minimalist studio.png',
    'assets/images/susnset launge.png',
    'assets/images/creative desk.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Banner Preview'),
        backgroundColor: AppColors.night,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        itemCount: _images.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final assetPath = _images[index];
          final title = assetPath
              .split('/')
              .last
              .replaceAll('.png', '')
              .replaceAll('  ', ' ')
              .replaceAll('  ', ' ');
          return ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceElevated,
                          alignment: Alignment.center,
                          child: const Text(
                            'Gambar tidak ditemukan',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
