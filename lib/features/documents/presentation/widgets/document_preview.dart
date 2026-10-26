import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:flutter/material.dart';

/// Local preview of a picked file before upload, from memory.
///
/// Flutter's global ImageCache would otherwise keep the decoded ID photo
/// after the screen is gone, so the provider is evicted when this widget is
/// disposed or shown a different file.
class DocumentPreview extends StatefulWidget {
  const DocumentPreview({required this.file, super.key});

  final DocumentFile file;

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  ImageProvider? _provider;

  /// Enough to check legibility on a phone; decoding at full camera
  /// resolution would waste memory.
  static const _decodeWidth = 900;

  @override
  void initState() {
    super.initState();
    _provider = _create(widget.file);
  }

  @override
  void didUpdateWidget(DocumentPreview old) {
    super.didUpdateWidget(old);
    if (!identical(old.file.bytes, widget.file.bytes)) {
      _evict();
      _provider = _create(widget.file);
    }
  }

  @override
  void dispose() {
    _evict();
    super.dispose();
  }

  ImageProvider? _create(DocumentFile file) =>
      file.mime.isImage ? ResizeImage(MemoryImage(file.bytes), width: _decodeWidth) : null;

  void _evict() {
    final provider = _provider;
    // evict() also drops "live" entries (still referenced) by default.
    if (provider != null) imageCache.evict(provider);
    _provider = null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = _provider;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: SizedBox(
          height: 170,
          width: double.infinity,
          child: provider != null
              ? Image(image: provider, fit: BoxFit.contain, gaplessPlayback: true)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, size: 48, color: scheme.primary),
                    const SizedBox(height: 8),
                    Text(context.l10n.documentPdfPreview(_formatSize(widget.file.sizeBytes))),
                  ],
                ),
        ),
      ),
    );
  }
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
