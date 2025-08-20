import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlaybackControls extends StatefulWidget {
  final String filePath;
  const AudioPlaybackControls({super.key, required this.filePath});

  @override
  State<AudioPlaybackControls> createState() => _AudioPlaybackControlsState();
}

class _AudioPlaybackControlsState extends State<AudioPlaybackControls> {
  late final AudioPlayer _player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    await _setSource();
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        _duration = d;
      });
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        _position = p;
      });
    });
    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() {
        _isPlaying = s == PlayerState.playing;
      });
    });
    _player.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = _duration;
      });
    });
  }

  Future<void> _setSource() async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setSource(DeviceFileSource(widget.filePath));
    _position = Duration.zero;
    // duration will be updated by onDurationChanged once prepared
  }

  @override
  void didUpdateWidget(covariant AudioPlaybackControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _setSource();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final max = _duration.inMilliseconds.toDouble().clamp(0.0, double.infinity);
    final value = _position.inMilliseconds.toDouble().clamp(0.0, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              ),
              iconSize: 40,
              onPressed: () async {
                if (_isPlaying) {
                  await _player.pause();
                } else {
                  await _player.play(DeviceFileSource(widget.filePath));
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: max == 0 ? 0 : value,
                    max: max == 0 ? 1 : max,
                    onChanged: (nv) async {
                      final pos = Duration(milliseconds: nv.round());
                      await _player.seek(pos);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(_fmt(_position)), Text(_fmt(_duration))],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.filePath.split(RegExp(r'[\\/]')).last,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
