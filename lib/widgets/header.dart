import 'package:costly/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HeaderWave extends StatelessWidget {
  const HeaderWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _HeaderWavePainter(),
      ),
    );
  }
}

class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    
    final Rect rect = Rect.fromCircle(
      center: Offset(0.0, 55.0), 
      radius: 180
    );

    final Gradient gradiente = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topRight,
      colors: [
        AppColors.primary,
        AppColors.background,
      ],
      stops: [0.1, 1.0],
    );

    final lapiz = Paint()..shader = gradiente.createShader(rect);

    lapiz.style = PaintingStyle.fill;
    lapiz.strokeWidth = 20;

    final path = Path();

    path.lineTo(0, size.height * 0.33);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.38, size.width * 0.5, size.height * 0.33);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.28, size.width, size.height * 0.33);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, lapiz);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}