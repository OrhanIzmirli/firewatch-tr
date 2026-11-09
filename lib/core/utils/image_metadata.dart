import 'dart:convert';
import 'dart:typed_data';

/// Removes metadata from a report photo without decoding it, so the pixels
/// are untouched. image_picker copies EXIF, including GPS, into the files it
/// resizes. Written as an allowlist: anything not known to be needed to draw
/// the image goes.
///
/// JPEG: only the EXIF orientation survives, rewritten as a minimal block,
/// because phones store photos rotated and rely on it. Bytes after the end of
/// the image are dropped too: phones append extra images there, with their
/// own EXIF.
///
/// Returns null for anything it cannot clean; the caller must not upload the
/// original instead. The backend's src/utils/imageMetadata.ts is the same
/// logic.
Uint8List? stripImageMetadata(Uint8List input) {
  try {
    if (_isJpeg(input)) return _stripJpeg(input);
    if (_isPng(input)) return _stripPng(input);
    if (_isWebp(input)) return _stripWebp(input);
  } on _Unreadable {
    return null;
  } on RangeError {
    return null;
  }
  return null;
}

class _Unreadable implements Exception {}

const _keptPngChunks = {
  'IHDR', 'PLTE', 'IDAT', 'IEND', 'tRNS', 'cHRM', 'gAMA', 'iCCP', 'sBIT', 'sRGB', 'bKGD', 'hIST', 'pHYs',
};
const _keptWebpChunks = {'VP8 ', 'VP8L', 'VP8X', 'ALPH', 'ANIM', 'ANMF', 'ICCP'};

bool _isJpeg(Uint8List b) => b.length >= 3 && b[0] == 0xff && b[1] == 0xd8 && b[2] == 0xff;

bool _isPng(Uint8List b) {
  const signature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  if (b.length < 8) return false;
  for (var i = 0; i < 8; i++) {
    if (b[i] != signature[i]) return false;
  }
  return true;
}

bool _isWebp(Uint8List b) => b.length >= 12 && _ascii(b, 0, 4) == 'RIFF' && _ascii(b, 8, 12) == 'WEBP';

String _ascii(Uint8List b, int start, int end) => latin1.decode(Uint8List.sublistView(b, start, end));

bool _startsWith(Uint8List data, String text) => data.length >= text.length && _ascii(data, 0, text.length) == text;

int _readOrientation(Uint8List payload) {
  const tiff = 6;
  if (payload.length < tiff + 8) return 1;
  final order = _ascii(payload, tiff, tiff + 2);
  if (order != 'II' && order != 'MM') return 1;
  final endian = order == 'II' ? Endian.little : Endian.big;
  final data = ByteData.sublistView(payload);
  if (data.getUint16(tiff + 2, endian) != 42) return 1;
  final ifd = tiff + data.getUint32(tiff + 4, endian);
  if (ifd + 2 > payload.length) return 1;
  final count = data.getUint16(ifd, endian);
  for (var i = 0; i < count; i++) {
    final entry = ifd + 2 + i * 12;
    if (entry + 12 > payload.length) return 1;
    if (data.getUint16(entry, endian) != 0x0112) continue;
    final value = data.getUint16(entry + 8, endian);
    return value >= 1 && value <= 8 ? value : 1;
  }
  return 1;
}

List<int> _orientationSegment(int orientation) => [
      0xff, 0xe1, 0x00, 0x22,
      ...latin1.encode('Exif\u0000\u0000'),
      ...latin1.encode('MM'),
      0, 42, 0, 0, 0, 8, 0, 1, 0x01, 0x12, 0, 3, 0, 0, 0, 1, 0, orientation, 0, 0, 0, 0, 0, 0,
    ];

bool _keepJpegSegment(int marker, Uint8List payload) {
  if (marker >= 0xc0 && marker <= 0xcf) return true; // frames, Huffman and arithmetic tables
  if (marker == 0xdb || marker == 0xdc || marker == 0xdd) return true; // quantisation, lines, restart
  if (marker == 0xe0) return _startsWith(payload, 'JFIF\u0000');
  if (marker == 0xe2) return _startsWith(payload, 'ICC_PROFILE\u0000');
  if (marker == 0xee) return _startsWith(payload, 'Adobe');
  return false;
}

Uint8List _stripJpeg(Uint8List b) {
  final out = BytesBuilder(copy: false)..add(Uint8List.sublistView(b, 0, 2));
  var orientationSeen = false;
  var i = 2;
  while (i < b.length) {
    if (b[i] != 0xff) throw _Unreadable();
    while (i < b.length && b[i] == 0xff) {
      i++;
    }
    if (i >= b.length) throw _Unreadable();
    final marker = b[i++];
    if (marker == 0xd9) {
      out.add(const [0xff, 0xd9]);
      return out.takeBytes();
    }
    if (marker == 0x00 || marker == 0xd8) throw _Unreadable();
    if (marker == 0x01 || (marker >= 0xd0 && marker <= 0xd7)) {
      out.add([0xff, marker]);
      continue;
    }
    if (i + 2 > b.length) throw _Unreadable();
    final size = (b[i] << 8) | b[i + 1];
    if (size < 2 || i + size > b.length) throw _Unreadable();
    final segment = Uint8List.sublistView(b, i - 2, i + size);
    final payload = Uint8List.sublistView(b, i + 2, i + size);
    i += size;

    if (marker == 0xda) {
      out.add(segment);
      final start = i;
      while (i < b.length) {
        if (b[i] == 0xff && i + 1 < b.length) {
          final next = b[i + 1];
          if (next == 0x00 || (next >= 0xd0 && next <= 0xd7)) {
            i += 2;
            continue;
          }
          if (next != 0xff) break;
        }
        i++;
      }
      out.add(Uint8List.sublistView(b, start, i));
      continue;
    }
    if (marker == 0xe1 && !orientationSeen && _startsWith(payload, 'Exif\u0000\u0000')) {
      orientationSeen = true;
      final orientation = _readOrientation(payload);
      if (orientation != 1) out.add(_orientationSegment(orientation));
      continue;
    }
    if (_keepJpegSegment(marker, payload)) out.add(segment);
  }
  return out.takeBytes(); // image data cut short: no metadata can follow
}

Uint8List _stripPng(Uint8List b) {
  final data = ByteData.sublistView(b);
  final out = BytesBuilder(copy: false)..add(Uint8List.sublistView(b, 0, 8));
  var i = 8;
  while (i + 12 <= b.length) {
    final end = i + 12 + data.getUint32(i);
    if (end > b.length) throw _Unreadable();
    final type = _ascii(b, i + 4, i + 8);
    if (_keptPngChunks.contains(type)) out.add(Uint8List.sublistView(b, i, end));
    i = end;
    if (type == 'IEND') return out.takeBytes();
  }
  throw _Unreadable();
}

Uint8List _stripWebp(Uint8List b) {
  final data = ByteData.sublistView(b);
  final chunks = BytesBuilder();
  var i = 12;
  while (i + 8 <= b.length) {
    final size = data.getUint32(i + 4, Endian.little);
    if (i + 8 + size > b.length) throw _Unreadable();
    final padded = i + 8 + size + (size & 1);
    final end = padded > b.length ? b.length : padded;
    final type = _ascii(b, i, i + 4);
    if (_keptWebpChunks.contains(type)) {
      final chunk = Uint8List.fromList(Uint8List.sublistView(b, i, end));
      if (type == 'VP8X' && size >= 1) chunk[8] &= ~0x0c; // the EXIF and XMP flags
      chunks.add(chunk);
    }
    i = end;
  }
  final body = chunks.takeBytes();
  final header = ByteData(12);
  const riff = [0x52, 0x49, 0x46, 0x46];
  const webp = [0x57, 0x45, 0x42, 0x50];
  for (var n = 0; n < 4; n++) {
    header.setUint8(n, riff[n]);
    header.setUint8(8 + n, webp[n]);
  }
  header.setUint32(4, body.length + 4, Endian.little);
  return (BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(body))
      .takeBytes();
}
