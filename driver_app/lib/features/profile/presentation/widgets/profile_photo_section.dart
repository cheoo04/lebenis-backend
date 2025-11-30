import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/theme/app_colors.dart';

class ProfilePhotoSection extends StatelessWidget {
  final dynamic newProfilePhoto;
  final Uint8List? newProfilePhotoBytes;
  final String? initialProfilePhotoUrl;
  final bool photoMarkedForDeletion;
  final bool isSubmitting;
  final VoidCallback onPickProfilePhoto;

  const ProfilePhotoSection({
    super.key,
    required this.newProfilePhoto,
    required this.newProfilePhotoBytes,
    required this.initialProfilePhotoUrl,
    required this.photoMarkedForDeletion,
    required this.isSubmitting,
    required this.onPickProfilePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withAlpha((0.1 * 255).toInt()),
            child: photoMarkedForDeletion
                ? const Icon(Icons.person, size: 60)
                : newProfilePhoto != null
                    ? ClipOval(
                        child: newProfilePhotoBytes != null
                            ? Image.memory(newProfilePhotoBytes!,
                                width: 120, height: 120, fit: BoxFit.cover)
                            : (newProfilePhoto is File)
                                ? Image.file(newProfilePhoto as File,
                                    width: 120, height: 120, fit: BoxFit.cover)
                                : (newProfilePhoto is XFile)
                                    ? Image.file(File((newProfilePhoto as XFile).path),
                                        width: 120, height: 120, fit: BoxFit.cover)
                                    : const Icon(Icons.person, size: 60),
                      )
                    : (initialProfilePhotoUrl != null &&
                            initialProfilePhotoUrl!.isNotEmpty &&
                            (initialProfilePhotoUrl!.startsWith('http://') || initialProfilePhotoUrl!.startsWith('https://')))
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: initialProfilePhotoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (initialProfilePhotoUrl != null &&
                            initialProfilePhotoUrl!.isNotEmpty &&
                            initialProfilePhotoUrl!.startsWith('file://'))
                        ? ClipOval(
                            child: Image.file(
                              File(Uri.parse(initialProfilePhotoUrl!).toFilePath()),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.person, size: 60, color: AppColors.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: isSubmitting ? null : onPickProfilePhoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
