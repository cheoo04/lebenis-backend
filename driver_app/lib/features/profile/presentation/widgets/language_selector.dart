import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final List<String> allLanguages;
  final List<String> selectedLanguages;
  final bool isSubmitting;
  final ValueChanged<List<String>> onChanged;

  const LanguageSelector({
    super.key,
    required this.allLanguages,
    required this.selectedLanguages,
    required this.isSubmitting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Langues parlées', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: allLanguages.map((lang) {
            final selected = selectedLanguages.contains(lang);
            return ChoiceChip(
              label: Text(lang),
              selected: selected,
              onSelected: isSubmitting
                  ? null
                  : (val) {
                      final newList = List<String>.from(selectedLanguages);
                      if (val) {
                        newList.add(lang);
                      } else {
                        newList.remove(lang);
                      }
                      onChanged(newList);
                    },
            );
          }).toList(),
        ),
      ],
    );
  }
}
