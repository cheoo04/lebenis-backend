import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'document_card.dart';

class VehicleDocumentsSection extends StatelessWidget {
  final String? initialInsuranceUrl;
  final Uint8List? insuranceBytes;
  final String? initialInspectionUrl;
  final Uint8List? inspectionBytes;
  final String? initialGrayCardUrl;
  final Uint8List? grayCardBytes;
  final String? initialLicenseUrl;
  final Uint8List? licenseBytes;
  final String? initialVignetteUrl;
  final Uint8List? vignetteBytes;
  final bool isSubmitting;
  final VoidCallback onPickInsurance;
  final VoidCallback onPickInspection;
  final VoidCallback onPickGrayCard;
  final VoidCallback onPickLicense;
  final VoidCallback onPickVignette;

  const VehicleDocumentsSection({
    super.key,
    required this.initialInsuranceUrl,
    required this.insuranceBytes,
    required this.initialInspectionUrl,
    required this.inspectionBytes,
    required this.initialGrayCardUrl,
    required this.grayCardBytes,
    required this.initialLicenseUrl,
    required this.licenseBytes,
    required this.isSubmitting,
    required this.initialVignetteUrl,
    required this.vignetteBytes,
    required this.onPickVignette,
    required this.onPickInsurance,
    required this.onPickInspection,
    required this.onPickGrayCard,
    required this.onPickLicense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documents véhicule', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            DocumentCard(
              title: 'Assurance',
              url: initialInsuranceUrl,
              bytes: insuranceBytes,
              onUpload: isSubmitting ? (){} : onPickInsurance,
                // onDelete: isSubmitting ? (){} : onDeleteInsurance,
            ),
            DocumentCard(
              title: 'Vignette',
              url: initialVignetteUrl,
              bytes: vignetteBytes,
              onUpload: isSubmitting ? (){} : onPickVignette,
                // onDelete: isSubmitting ? (){} : onDeleteVignette,
            ),
            DocumentCard(
              title: 'Visite technique',
              url: initialInspectionUrl,
              bytes: inspectionBytes,
              onUpload: isSubmitting ? (){} : onPickInspection,
                // onDelete: isSubmitting ? (){} : onDeleteInspection,
            ),
            DocumentCard(
              title: 'Carte grise',
              url: initialGrayCardUrl,
              bytes: grayCardBytes,
              onUpload: isSubmitting ? (){} : onPickGrayCard,
                // onDelete: isSubmitting ? (){} : onDeleteGrayCard,
            ),
            DocumentCard(
              title: 'Permis de conduire',
              url: initialLicenseUrl,
              bytes: licenseBytes,
              onUpload: isSubmitting ? (){} : onPickLicense,
                // onDelete: isSubmitting ? (){} : onDeleteLicense,
            ),
          ],
        ),
      ],
    );
  }
}
