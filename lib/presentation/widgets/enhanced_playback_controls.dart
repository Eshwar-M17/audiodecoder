import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class EnhancedPlaybackControls extends StatefulWidget {
  final String filePath;
  const EnhancedPlaybackControls({super.key, required this.filePath});

  @override
  State<EnhancedPlaybackControls> createState() =>
      _EnhancedPlaybackControlsState();
}

class _EnhancedPlaybackControlsState extends State<EnhancedPlaybackControls> {
  late final AudioPlayer _player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _volume = 1.0;

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
  }

  @override
  void didUpdateWidget(covariant EnhancedPlaybackControls oldWidget) {
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
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final max = _duration.inMilliseconds.toDouble().clamp(0.0, double.infinity);
    final value = _position.inMilliseconds.toDouble().clamp(0.0, max);

    return Card(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time indicators and progress bar
            Row(
              children: [
                Text(
                  _fmt(_position),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  _fmt(_duration),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF4A90E2),
                inactiveTrackColor: const Color(0xFF404040),
                thumbColor: const Color(0xFF4A90E2),
                overlayColor: const Color(0xFF4A90E2).withOpacity(0.2),
              ),
              child: Slider(
                value: max == 0 ? 0 : value,
                max: max == 0 ? 1 : max,
                onChanged: (nv) async {
                  final pos = Duration(milliseconds: nv.round());
                  await _player.seek(pos);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Play button and volume control
            Row(
              children: [
                // Play button
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A90E2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () async {
                      if (_isPlaying) {
                        await _player.pause();
                      } else {
                        await _player.play(DeviceFileSource(widget.filePath));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Volume control
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF20B2AA),
                            inactiveTrackColor: const Color(0xFF404040),
                            thumbColor: const Color(0xFF20B2AA),
                            overlayColor: const Color(
                              0xFF20B2AA,
                            ).withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _volume,
                            onChanged: (value) async {
                              setState(() {
                                _volume = value;
                              });
                              await _player.setVolume(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
