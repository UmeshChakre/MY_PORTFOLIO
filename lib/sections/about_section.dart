import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../desk/retro_window.dart';
import '../theme/paint_theme.dart';
import '../ui/sketchy.dart';
import 'common.dart';

const _chipColors = [
  Color(0xFFFFF59D),
  Color(0xFFB3E5FC),
  Color(0xFFC8E6C9),
  Color(0xFFF8BBD0),
  Color(0xFFFFE0B2),
  Color(0xFFD1C4E9),
];

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CanvasBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HandHeading('About Me', seed: 11),
          const SizedBox(height: 14),
          for (var i = 0; i < Portfolio.about.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ScribbleBullet(
                seed: i,
                child: Highlighted(Portfolio.about[i]),
              ),
            ),
          const SizedBox(height: 14),
          const PixelLabel('My toolbox'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < Portfolio.skills.length; i++)
                SketchyBox(
                  seed: 100 + i,
                  fill: _chipColors[i % _chipColors.length],
                  strokeWidth: 1.3,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Text(Portfolio.skills[i], style: PaintText.small),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const PixelLabel('I speak'),
          const SizedBox(height: 4),
          const Text(Portfolio.languages, style: PaintText.body),
          const SizedBox(height: 22),
          const DownloadCvButton(),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CanvasBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HandHeading(
            'Work Experience',
            seed: 21,
            underline: PaintColors.electricBlue,
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < Portfolio.experience.length; i++)
            _TimelineEntry(
              job: Portfolio.experience[i],
              seed: i,
              last: i == Portfolio.experience.length - 1,
            ),
          const SizedBox(height: 18),
          const PixelLabel('Side project'),
          const SizedBox(height: 10),
          SketchyBox(
            seed: 77,
            fill: const Color(0xFFFFFDE7),
            shadow: true,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Portfolio.sideProject.name,
                  style: PaintText.heading.copyWith(fontSize: 20),
                ),
                Text(
                  Portfolio.sideProject.tech,
                  style: PaintText.small.copyWith(color: PaintColors.blue),
                ),
                const SizedBox(height: 6),
                Text(Portfolio.sideProject.description, style: PaintText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.job,
    required this.seed,
    required this.last,
  });

  final Job job;
  final int seed;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: CustomPaint(painter: _TimelinePainter(seed, last)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 4 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.role,
                    style: PaintText.heading.copyWith(fontSize: 21),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${job.company}, ${job.place}',
                        style: PaintText.body.copyWith(color: PaintColors.blue),
                      ),
                      Container(
                        color: const Color(0xFFFFF176),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          job.period,
                          style: PaintText.chrome.copyWith(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < job.points.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ScribbleBullet(
                        dash: true,
                        seed: seed * 10 + i,
                        color: PaintColors.darkGrey,
                        child: Text(job.points[i], style: PaintText.body),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter(this.seed, this.last);

  final int seed;
  final bool last;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final pen = Paint()
      ..color = PaintColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const dotCenter = Offset(13, 16);
    if (!last) {
      final line = Path();
      Sketch.line(
        line,
        Offset(x, 30),
        Offset(x, size.height + 4),
        math.Random(seed),
        rough: 1.2,
      );
      canvas.drawPath(line, pen);
    }
    canvas.drawPath(
      Sketch.ellipse(
        Rect.fromCenter(center: dotCenter, width: 18, height: 18),
        seed + 5,
      ),
      pen,
    );
    canvas.drawCircle(
      dotCenter,
      4.5,
      Paint()..color = PaintColors.palette[16 + seed % 6],
    );
  }

  @override
  bool shouldRepaint(_TimelinePainter old) => false;
}

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CanvasBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HandHeading(
            'Education',
            seed: 31,
            underline: Color(0xFF00B000),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < Portfolio.education.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            ScribbleBullet(
              seed: 40 + i,
              color: const Color(0xFF00A000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Portfolio.education[i].degree,
                    style: PaintText.heading.copyWith(fontSize: 20),
                  ),
                  Text(
                    Portfolio.education[i].name,
                    style: PaintText.body.copyWith(color: PaintColors.blue),
                  ),
                  Text(
                    Portfolio.education[i].period,
                    style: PaintText.chrome.copyWith(
                      fontSize: 18,
                      color: PaintColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
