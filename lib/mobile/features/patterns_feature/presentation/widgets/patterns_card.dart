import 'package:flutter/material.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';

class PatternCard extends StatelessWidget {
  final PatternItem pattern;
  final VoidCallback? onTap;

  const PatternCard({Key? key, required this.pattern, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Palette.white100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Картинка образа
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 1, // квадрат
                child: Image.network(
                  pattern.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern.name,
                    style: TextStyles.titleLarge.copyWith(color: Palette.black100),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}