import 'dart:math';
import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'package:fpdart/fpdart.dart';

class AudioSegment {
  final int start;
  final int end;
  AudioSegment(this.start, this.end);
}

class FFTResult {
  final double bestFreq;
  final double confidence;
  FFTResult(this.bestFreq, this.confidence);
}

abstract class AudioFailure {
  final String message;
  AudioFailure(this.message);
  @override
  String toString() => '\${runtimeType.toString()}: \$message';
}

class ParseFailure extends AudioFailure {
  ParseFailure(String m) : super(m);
}
class DecodeFailure extends AudioFailure {
  DecodeFailure(String m) : super(m);
}

class WavFile {
  final int sampleRate;
  final int bitsPerSample;
  final int numChannels;
  final bool isPcm;
  final Uint8List pcmBytes;

  WavFile({
    required this.sampleRate,
    required this.bitsPerSample,
    required this.numChannels,
    required this.isPcm,
    required this.pcmBytes,
  });
}

abstract class AudioProcessingService {
  TaskEither<AudioFailure, WavFile> parseWav(Uint8List wavBytes);
  Either<AudioFailure, List<double>> pcmToMonoFloat(Uint8List pcmBytes, int bitsPerSample, int channels);
  Either<AudioFailure, List<AudioSegment>> findAudioSegments(List<double> samples, int sampleRate,
      {double frameMs = 50, double hopFraction = 0.25, double minToneMs = 60});
  Either<AudioFailure, FFTResult> detectFrequencyFFT(List<double> samples, int sampleRate,
      {int zeroPadFactor = 1});
}

String _readFourCC(ByteData bd, int offset) {
  return String.fromCharCodes([
    bd.getUint8(offset),
    bd.getUint8(offset + 1),
    bd.getUint8(offset + 2),
    bd.getUint8(offset + 3),
  ]);
}

class AudioProcessingServiceImpl implements AudioProcessingService {
  @override
  TaskEither<AudioFailure, WavFile> parseWav(Uint8List wavBytes) {
    return TaskEither.tryCatch(() async {
      final bd = wavBytes.buffer.asByteData();
      if (_readFourCC(bd, 0) != 'RIFF') throw ParseFailure('Not a RIFF file');
      if (_readFourCC(bd, 8) != 'WAVE') throw ParseFailure('Not a WAVE file');

      int offset = 12;
      int sampleRate = 44100;
      int bitsPerSample = 16;
      int numChannels = 1;
      bool isPcm = true;
      Uint8List? dataChunk;

      while (offset + 8 <= wavBytes.length) {
        final chunkId = _readFourCC(bd, offset);
        final chunkSize = bd.getUint32(offset + 4, Endian.little);
        final chunkDataStart = offset + 8;

        if (chunkId == 'fmt ') {
          final audioFormat = bd.getUint16(chunkDataStart, Endian.little);
          numChannels = bd.getUint16(chunkDataStart + 2, Endian.little);
          sampleRate = bd.getUint32(chunkDataStart + 4, Endian.little);
          bitsPerSample = bd.getUint16(chunkDataStart + 14, Endian.little);
          isPcm = (audioFormat == 1);
        } else if (chunkId == 'data') {
          dataChunk = wavBytes.sublist(chunkDataStart, chunkDataStart + chunkSize);
          break;
        }
        offset = chunkDataStart + chunkSize;
      }

      if (dataChunk == null) throw ParseFailure('No data chunk found');

      return WavFile(
        sampleRate: sampleRate,
        bitsPerSample: bitsPerSample,
        numChannels: numChannels,
        isPcm: isPcm,
        pcmBytes: dataChunk,
      );
    }, (err, st) {
      if (err is AudioFailure) return err;
      return ParseFailure(err.toString());
    });
  }

  @override
  Either<AudioFailure, List<double>> pcmToMonoFloat(Uint8List pcmBytes, int bitsPerSample, int channels) {
    try {
      final out = <double>[];
      final bd = pcmBytes.buffer.asByteData();
      final bps = bitsPerSample;
      final totalSamples = (pcmBytes.length * 8) ~/ bps;
      final frameCount = (totalSamples ~/ channels);
      int idx = 0;
      for (int frame = 0; frame < frameCount; frame++) {
        double sum = 0.0;
        for (int ch = 0; ch < channels; ch++) {
          if (bps == 16) {
            final sample = bd.getInt16(idx, Endian.little);
            sum += sample / 32768.0;
            idx += 2;
          } else if (bps == 8) {
            final sample = bd.getUint8(idx);
            sum += (sample - 128) / 128.0;
            idx += 1;
          } else {
            return Left(ParseFailure('Unsupported bitsPerSample: \$bps'));
          }
        }
        out.add(sum / channels);
      }
      return Right(out);
    } catch (e) {
      return Left(ParseFailure(e.toString()));
    }
  }

  @override
  Either<AudioFailure, List<AudioSegment>> findAudioSegments(List<double> samples, int sampleRate,
      {double frameMs = 50, double hopFraction = 0.25, double minToneMs = 60}) {
    try {
      if (samples.isEmpty) return Right([]);
      final frameSize = max(256, (sampleRate * (frameMs / 1000.0)).round());
      final hop = max(1, (frameSize * hopFraction).round());
      final rms = <double>[];

      for (int i = 0; i + frameSize <= samples.length; i += hop) {
        double sum = 0.0;
        for (int j = 0; j < frameSize; j++) {
          final v = samples[i + j];
          sum += v * v;
        }
        rms.add(sqrt(sum / frameSize));
      }

      if (rms.isEmpty) return Right([]);

      final mean = rms.reduce((a, b) => a + b) / rms.length;
      final std = sqrt(rms.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / rms.length);
      final thrHigh = max(mean + 0.6 * std, 0.005);
      final thrLow = thrHigh * 0.6;

      final flags = List<bool>.generate(rms.length, (i) => rms[i] > thrHigh);

      final segments = <AudioSegment>[];
      int idx = 0;
      while (idx < flags.length) {
        if (!flags[idx]) {
          idx++;
          continue;
        }
        int startFrame = idx;
        while (idx < flags.length && (rms[idx] > thrLow)) idx++;
        int endFrame = idx - 1;

        final startSample = startFrame * hop;
        final endSample = min(samples.length, (endFrame * hop) + frameSize);
        if (endSample - startSample >= (minToneMs / 1000.0) * sampleRate) {
          segments.add(AudioSegment(startSample, endSample));
        }
      }

      return Right(segments);
    } catch (e) {
      return Left(DecodeFailure('Segmentation error: \$e'));
    }
  }

  @override
  Either<AudioFailure, FFTResult> detectFrequencyFFT(List<double> samples, int sampleRate, {int zeroPadFactor = 1}) {
    try {
      int n = samples.length;
      if (n == 0) return Left(DecodeFailure('Empty sample buffer'));

      int fftSize = 1;
      while (fftSize < n) fftSize <<= 1;
      fftSize *= max(1, zeroPadFactor);

      final input = Float64x2List(fftSize);

      for (int i = 0; i < fftSize; i++) {
        final x = (i < n) ? samples[i] : 0.0;
        final w = 0.5 * (1 - cos(2 * pi * i / (fftSize - 1)));
        input[i] = Float64x2(x * w, 0.0);
      }

      final fft = FFT(fftSize);
      fft.inPlaceFft(input);
      final half = fftSize ~/ 2;
      final mags = List<double>.generate(half, (i) => sqrt(input[i].x * input[i].x + input[i].y * input[i].y));

      int peak = 0;
      double peakMag = -1;
      for (int i = 1; i < mags.length; ++i) {
        if (mags[i] > peakMag) { peakMag = mags[i]; peak = i; }
      }

      final double alpha = (peak - 1 >= 0) ? mags[peak - 1] : 0.0;
      final double beta = mags[peak];
      final double gamma = (peak + 1 < mags.length) ? mags[peak + 1] : 0.0;
      final double denom = (alpha - 2 * beta + gamma);
      final double p = denom == 0 ? 0.0 : 0.5 * (alpha - gamma) / denom;
      final double freq = (peak + p) * sampleRate / fftSize;

      final mean = mags.reduce((a, b) => a + b) / mags.length;
      final confidence = peakMag / (mean + 1e-9);

      return Right(FFTResult(freq, confidence));
    } catch (e) {
      return Left(DecodeFailure('FFT error: \$e'));
    }
  }
}
