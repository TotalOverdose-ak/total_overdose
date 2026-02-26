import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingMicButton extends StatefulWidget {
  final VoidCallback? onMicTap;
  final VoidCallback? onPlaybackTap;

  const FloatingMicButton({super.key, this.onMicTap, this.onPlaybackTap});

  @override
  State<FloatingMicButton> createState() => _FloatingMicButtonState();
}

class _FloatingMicButtonState extends State<FloatingMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleMic() {
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
    widget.onMicTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Voice playback button (smaller, above main FAB)
        if (widget.onPlaybackTap != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.small(
              heroTag: 'playback_fab',
              onPressed: widget.onPlaybackTap,
              backgroundColor: AppColors.sunYellow,
              foregroundColor: AppColors.textDark,
              tooltip: 'Play voice explanation',
              child: const Icon(Icons.volume_up_rounded),
            ),
          ),
        // Main mic FAB
        ScaleTransition(
          scale: _isListening
              ? _pulseAnimation
              : const AlwaysStoppedAnimation(1.0),
          child: FloatingActionButton(
            heroTag: 'mic_fab',
            onPressed: _toggleMic,
            backgroundColor: _isListening
                ? AppColors.riskHigh
                : AppColors.primaryGreen,
            foregroundColor: Colors.white,
            tooltip: _isListening ? 'Tap to stop' : 'Tap to speak',
            child: Icon(
              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _isListening ? 'Listening…' : 'Voice Input',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
