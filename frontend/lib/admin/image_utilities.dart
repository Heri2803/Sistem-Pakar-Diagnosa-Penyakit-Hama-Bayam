import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart'; // Sesuaikan dengan path import Anda

class ImageUtilities {
  static Widget buildHamaImage(int id, {double? width, double? height}) {
    final ApiService apiService = ApiService();
    
    return FutureBuilder<bool>(
      future: apiService.isHamaImageAvailable(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final bool imageAvailable = snapshot.data ?? false;
        if (!imageAvailable) {
          return Container(
            width: width,
            height: height ?? 150,
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Gambar tidak tersedia'),
                ],
              ),
            ),
          );
        }

        return Image.network(
          apiService.getHamaImageUrl(id),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              width: width,
              height: height ?? 150,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 40, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Tidak dapat memuat gambar'),
                    SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: TextStyle(fontSize: 10, color: Colors.red[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height ?? 150,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget untuk menampilkan gambar secara langsung dari URL (tanpa pengecekan ketersediaan)
  static Widget buildImageFromUrl(String imageUrl, {double? width, double? height}) {
    return Image.network(
      imageUrl,
      width: width,
      height: height ?? 150,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image from URL: $error');
        return Container(
          width: width,
          height: height ?? 150,
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 40, color: Colors.red),
                SizedBox(height: 8),
                Text('Gagal memuat gambar'),
                SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: TextStyle(fontSize: 10, color: Colors.red[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height ?? 150,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}