import 'package:flutter/material.dart';
import 'package:finance_app/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  List<({String q, String a})> _faqs(AppLocalizations l10n) => [
    (q: l10n.faqQ1, a: l10n.faqA1),
    (q: l10n.faqQ2, a: l10n.faqA2),
    (q: l10n.faqQ3, a: l10n.faqA3),
    (q: l10n.faqQ4, a: l10n.faqA4),
    (q: l10n.faqQ5, a: l10n.faqA5),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final faqs = _faqs(l10n);
    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: kTextPrimary, size: 18),
                  ),
                  Text(
                    l10n.helpAndSupport,
                    style: appDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: kAccentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kAccent.withOpacity(0.35),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: const Icon(Icons.support_agent_rounded,
                      size: 34, color: Colors.white),
                ),
              ),
              const SizedBox(height: 48),
              _SectionLabel(l10n.frequentlyAskedQuestions),
              const SizedBox(height: 10),
              GlassCard(
                padding: EdgeInsets.zero,
                radius: 20,
                child: Column(
                  children: [
                    for (int i = 0; i < faqs.length; i++)
                      _FaqTile(
                        question: faqs[i].q,
                        answer: faqs[i].a,
                        isLast: i == faqs.length - 1,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: appBody(
            fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted, letterSpacing: 0.4),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kAccentBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kAccentLight, size: 20),
      ),
      title: Text(title,
          style: appBody(fontWeight: FontWeight.w600, fontSize: 15, color: kTextPrimary)),
      subtitle: Text(value, style: appBody(fontSize: 12.5, color: kTextMuted)),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLast;

  const _FaqTile({required this.question, required this.answer, this.isLast = false});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: widget.isLast ? null : const Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: appBody(
                          fontWeight: FontWeight.w600, fontSize: 14, color: kTextPrimary),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: kTextMuted, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: appBody(fontSize: 13, color: kTextSecondary, height: 1.5),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}