import 'dart:io';
import 'package:exif/exif.dart';

/// Lightweight anti-cheat validation for mission proof photos.
///
/// Current rule checks EXIF camera hardware tags to reject obvious
/// downloads/screenshots. GPS validation hook is reserved for future use.
Future<bool> validateLocalPhoto(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final tags = await readExifFromBytes(bytes);

  // 1. Check for Hardware Signatures (Blocks most internet downloads/screenshots)
  if (!tags.containsKey('Image Make') && !tags.containsKey('Image Model')) {
    return false;
  }

  // 2. Check Geographical Location (Optional: only if GPS data exists)
  if (tags.containsKey('GPS GPSLatitude') &&
      tags.containsKey('GPS GPSLongitude')) {
    // ... (Use the Lat/Lng calculation from our previous discussion to ensure it falls within Malaysia's coordinates)
  }

  return true;
}
