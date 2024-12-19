import 'dart:async';
import 'package:flutter/material.dart';

import '../../domain/models/capsule_status.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final CapsuleStatus status;

  const CountdownTimer({
    Key? key,
    required this.targetTime,
    required this.status,
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> 
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _remainingTime;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateRemainingTime() {
    setState(() {
      _remainingTime = widget.targetTime.difference(DateTime.now());
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
  }

  Color _getTimerColor() {
    if (_remainingTime.isNegative) {
      return Colors.red;
    } else if (_remainingTime.inDays <= 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '已过期';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '$days 天 $hours 小时';
    } else if (hours > 0) {
      return '$hours 小时 $minutes 分钟';
    } else if (minutes > 0) {
      return '$minutes 分钟 $seconds 秒';
    } else {
      return '$seconds 秒';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTimerColor();
    final timerText = _formatDuration(_remainingTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerLabel(context, color),
          _buildTimerValue(context, timerText, color),
        ],
      ),
    );
  }

  Widget _buildTimerLabel(BuildContext context, Color color) {
    String label;
    switch (widget.status) {
      case CapsuleStatus.draft:
      case CapsuleStatus.scheduled:
        label = '距离开启';
        break;
      case CapsuleStatus.active:
        label = '距离关闭';
        break;
      case CapsuleStatus.expired:
      case CapsuleStatus.archived:
        label = '已结束';
        break;
    }

    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTimerValue(BuildContext context, String timerText, Color color) {
    return ScaleTransition(
      scale: _animation,
      child: Text(
        timerText,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
