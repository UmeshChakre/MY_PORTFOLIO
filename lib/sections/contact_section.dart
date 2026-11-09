import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/portfolio_data.dart';
import '../platform/browser.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';
import '../ui/sketchy.dart';
import 'common.dart';

/// "Send Message.txt" - a Notepad-style contact window.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    const details = _ContactDetails();
    const form = _MessageForm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Notepad's menu bar (decorative).
        SelectionContainer.disabled(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
            child: Wrap(
              children: [
                for (final m in ['File', 'Edit', 'Format', 'View', 'Help'])
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(m, style: PaintText.chrome),
                  ),
              ],
            ),
          ),
        ),
        Bevel(
          style: BevelStyle.field,
          color: PaintColors.white,
          padding: EdgeInsets.all(compact ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HandHeading(
                "Let's Work Together",
                seed: 61,
                style: PaintText.heading.copyWith(fontSize: compact ? 28 : 36),
              ),
              const SizedBox(height: 8),
              const Text(
                'Got an app idea, a Flutter SDK that needs building, or a '
                'flaky offline sync to tame? Drop me a line.',
                style: PaintText.body,
              ),
              const SizedBox(height: 22),
              if (compact) ...[
                details,
                const SizedBox(height: 26),
                form,
              ] else
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: details),
                    SizedBox(width: 36),
                    Expanded(flex: 5, child: form),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DetailRow(
          icon: 'pin',
          label: 'Location',
          value: Portfolio.location,
        ),
        _DetailRow(
          icon: 'phone',
          label: 'Phone',
          value: Portfolio.phone,
          onTap: () => Browser.open('tel:${Portfolio.phoneIntl}'),
        ),
        _DetailRow(
          icon: 'mail',
          label: 'Email',
          value: Portfolio.email,
          onTap: () => Browser.email(Portfolio.email),
        ),
        _DetailRow(
          icon: 'linkedin',
          label: 'LinkedIn',
          value: Portfolio.linkedinShort,
          onTap: () => Browser.open(Portfolio.socials[1].url),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget text = Text(
      value,
      style: PaintText.body.copyWith(
        color: onTap == null ? PaintColors.ink : PaintColors.blue,
        decoration: onTap == null ? null : TextDecoration.underline,
        decorationColor: PaintColors.blue,
      ),
    );
    if (onTap != null) {
      text = Semantics(
        link: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(onTap: onTap, child: text),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: PixelIcon(icon, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [PixelLabel(label), text],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageForm extends StatefulWidget {
  const _MessageForm();

  @override
  State<_MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<_MessageForm> {
  final _name = TextEditingController();
  final _message = TextEditingController();
  bool _missing = false;

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    super.dispose();
  }

  void _send() {
    final name = _name.text.trim();
    final message = _message.text.trim();
    if (message.isEmpty) {
      setState(() => _missing = true);
      return;
    }
    setState(() => _missing = false);
    Browser.email(
      Portfolio.email,
      subject: name.isEmpty ? 'Hello from your portfolio' : 'Hello from $name',
      body: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SketchyBox(
      seed: 88,
      fill: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PixelLabel('Your name'),
          const SizedBox(height: 4),
          _RetroField(controller: _name, hint: 'Jane from Acme Inc.'),
          const SizedBox(height: 14),
          const PixelLabel('Your message'),
          const SizedBox(height: 4),
          _RetroField(
            controller: _message,
            hint: 'Hi Umesh, I need an offline-first app that...',
            lines: 5,
          ),
          if (_missing)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Oops - the message is empty!',
                style: PaintText.small.copyWith(color: PaintColors.red),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              RetroButton(
                semanticLabel: 'Send message by email',
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onPressed: _send,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PixelIcon('mail', size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Send',
                      style: PaintText.chrome.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Opens your email app.',
                  style: PaintText.small.copyWith(color: PaintColors.darkGrey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RetroField extends StatelessWidget {
  const _RetroField({
    required this.controller,
    required this.hint,
    this.lines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Bevel(
      style: BevelStyle.field,
      color: PaintColors.white,
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines,
        style: PaintText.body,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(8),
          hintText: hint,
          hintStyle: PaintText.body.copyWith(color: const Color(0xFFA0A0A0)),
        ),
      ),
    );
  }
}
