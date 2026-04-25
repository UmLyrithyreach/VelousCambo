import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../viewmodel/ride_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/ride/state/ride_state.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final String bikeId;

  const BookingConfirmedScreen({super.key, required this.bikeId});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _onTimerFinished();
      }
    });
  }

  void _onTimerFinished() {
    if (!mounted) return;
    setState(() {
      _isExpired = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unlock window expired'),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideVm = context.watch<RideViewModel>();
    final state = rideVm.state;
    
    // Extract rental from state if active
    final rental = state is RideActive ? state.rental : null;

    final stationName = rental?.stationName ?? 'Station Capitole';
    final displayBikeId = rental?.bikeCode ?? widget.bikeId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 1. Station Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFE91E63), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Station',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star_rounded,
                              size: 16,
                              color:
                                  index < 4 ? Colors.red : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(stationName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Bike ID: #$displayBikeId',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Freshly Fixed by Bike Mechanics',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 40),

              // 2. Large Circular Timer
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: _DashedCirclePainter(
                          color: _secondsRemaining > 5
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ),
                    Text(
                      '$_secondsRemaining',
                      style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF333333)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Walk to your bike now',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // 3. Audible Sound Alert Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        color: Colors.red, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Your bike is making an audible sound. Walk toward it to locate it.',
                        style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 13,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // 4. Action Buttons
              PrimaryButton(
                label: _isExpired ? "Time Expired" : "I've reached my bike",
                onPressed: _isExpired
                    ? null
                    : () {
                        Navigator.pushReplacementNamed(
                            context, '/active-rental');
                      },
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel Booking',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    for (var i = 0; i < 4; i++) {
      canvas.drawArc(
        rect,
        (i * 90 + 10) * (3.14159 / 180),
        70 * (3.14159 / 180),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
