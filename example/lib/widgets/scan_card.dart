import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pda_broadcast/flutter_pda_broadcast.dart';

/// Widget de carte pour afficher un scan de code-barres
class ScanCard extends StatelessWidget {
  final ScanData scan;
  final bool isLatest;
  final VoidCallback? onTap;

  const ScanCard({
    super.key,
    required this.scan,
    this.isLatest = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Formatage simple de la date et heure
    final hour = scan.timestamp.hour.toString().padLeft(2, '0');
    final minute = scan.timestamp.minute.toString().padLeft(2, '0');
    final second = scan.timestamp.second.toString().padLeft(2, '0');
    final timeString = '$hour:$minute:$second';

    final day = scan.timestamp.day.toString().padLeft(2, '0');
    final month = scan.timestamp.month.toString().padLeft(2, '0');
    final year = scan.timestamp.year.toString();
    final dateString = '$day/$month/$year';

    return Card(
      elevation: isLatest ? 6 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isLatest ? theme.primaryColor.withOpacity(0.05) : null,
      child: InkWell(
        onTap: onTap ?? () => _showScanDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(scan.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(scan.type),
                      color: _getTypeColor(scan.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isLatest) ...[
                              Icon(
                                Icons.fiber_new,
                                color: theme.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              scan.type,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getTypeColor(scan.type),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          scan.barcode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(context, scan.barcode),
                    tooltip: 'Copier',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeString,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    dateString,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'EAN13':
      case 'EAN8':
        return Colors.blue;
      case 'QR_CODE':
      case 'QR':
        return Colors.green;
      case 'CODE128':
        return Colors.orange;
      case 'CODE39':
        return Colors.purple;
      case 'UPC_A':
      case 'UPC_E':
        return Colors.red;
      case 'DATA_MATRIX':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'QR_CODE':
      case 'QR':
        return Icons.qr_code;
      case 'DATA_MATRIX':
        return Icons.grid_4x4;
      default:
        return Icons.barcode_reader;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copié: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showScanDetails(BuildContext context) {
    // Formatage de la date et heure pour les détails
    final hour = scan.timestamp.hour.toString().padLeft(2, '0');
    final minute = scan.timestamp.minute.toString().padLeft(2, '0');
    final second = scan.timestamp.second.toString().padLeft(2, '0');
    final timeString = '$hour:$minute:$second';

    final day = scan.timestamp.day.toString().padLeft(2, '0');
    final month = scan.timestamp.month.toString().padLeft(2, '0');
    final year = scan.timestamp.year.toString();
    final dateString = '$day/$month/$year';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getTypeIcon(scan.type), color: _getTypeColor(scan.type)),
            const SizedBox(width: 8),
            Text('Détails du scan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Code-barres', scan.barcode),
            _buildDetailRow('Type', scan.type),
            _buildDetailRow('Date', dateString),
            _buildDetailRow('Heure', timeString),
            if (scan.originalBarcode != null)
              _buildDetailRow('Code original', scan.originalBarcode!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _copyToClipboard(context, scan.barcode);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copier'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
