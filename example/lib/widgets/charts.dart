import 'package:flutter/material.dart';

/// Widget de graphique en barres simple pour les statistiques
class SimpleBarChart extends StatelessWidget {
  final Map<String, int> data;
  final double height;
  final Color? primaryColor;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.height = 200,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Aucune donnée à afficher')),
      );
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final color = primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.entries.map((entry) {
                final barHeight = maxValue > 0
                    ? (entry.value / maxValue) * (height - 80)
                    : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Valeur au-dessus de la barre
                        Text(
                          entry.value.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // Barre
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          height: barHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.8),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [color, color.withOpacity(0.7)],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de graphique en secteurs simple
class SimplePieChart extends StatelessWidget {
  final Map<String, int> data;
  final double size;

  const SimplePieChart({super.key, required this.data, this.size = 200});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text('Aucune donnée')),
      );
    }

    final total = data.values.reduce((a, b) => a + b);
    final colors = _generateColors(data.length);

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: PieChartPainter(data: data, colors: colors, total: total),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            final color = colors[index % colors.length];
            final percentage = total > 0 ? (entry.value / total * 100) : 0;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Color> _generateColors(int count) {
    const baseColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    if (count <= baseColors.length) {
      return baseColors.take(count).toList();
    }

    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      colors.add(baseColors[i % baseColors.length]);
    }
    return colors;
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final List<Color> colors;
  final int total;

  PieChartPainter({
    required this.data,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    double startAngle = -90 * (3.14159 / 180); // Commencer en haut

    int colorIndex = 0;
    for (final entry in data.entries) {
      final sweepAngle = total > 0 ? (entry.value / total) * 2 * 3.14159 : 0.0;

      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Bordure
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
