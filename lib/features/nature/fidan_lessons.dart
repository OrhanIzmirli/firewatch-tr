part of 'fidan_screen.dart';

class FidanRewardScreen extends StatefulWidget {
  final int xp;
  final bool newApple;
  final int? grewTo;
  final String message;
  final DateTime today;

  /// Set when this finish closed a whole section.
  final String? sectionTitle;

  /// Set when this finish was the very last lesson.
  final bool allDone;
  const FidanRewardScreen({super.key, required this.xp, required this.newApple, required this.grewTo, required this.message, required this.today, this.sectionTitle, this.allDone = false});

  @override
  State<FidanRewardScreen> createState() => _FidanRewardScreenState();
}

class _FidanRewardScreenState extends State<FidanRewardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = NatureStore.instance.progress;
    return FidanTheme(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) => CustomPaint(painter: ConfettiPainter(_c.value)),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            TreeView(
                              stage: treeStage(p),
                              mood: Mood.happy,
                              season: seasonOf(widget.today),
                              apples: applesOf(p).length,
                              flowers: sectionsDone(p).length,
                              size: 280,
                            ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 8),
                            if (widget.allDone)
                              Text(
                                l10n.fidanAllDone,
                                key: const Key('fidanAllDoneReward'),
                                textAlign: TextAlign.center,
                                style: _t(30, weight: FontWeight.w900, color: leafDark),
                              ),
                            Text(
                              l10n.fidanXpGain(widget.xp),
                              key: const Key('fidanXpGain'),
                              textAlign: TextAlign.center,
                              style: _t(52, weight: FontWeight.w900, color: leaf),
                            ),
                            if (widget.newApple)
                              Text(
                                l10n.fidanNewApple,
                                key: const Key('fidanNewApple'),
                                textAlign: TextAlign.center,
                                style: _t(25, weight: FontWeight.w900),
                              ),
                            if (widget.sectionTitle != null)
                              Text(
                                l10n.fidanSectionDone(widget.sectionTitle!),
                                key: const Key('fidanSectionReward'),
                                textAlign: TextAlign.center,
                                style: _t(21, weight: FontWeight.w900, color: leafDark),
                              ),
                            if (widget.grewTo != null)
                              Text(
                                l10n.fidanGrew(stageName(l10n, widget.grewTo!)),
                                textAlign: TextAlign.center,
                                style: _t(21, weight: FontWeight.w900, color: leafDark),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: _t(18, color: inkSoft),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BigGreenButton(l10n.fidanContinue, key: const Key('fidanRewardContinue'), onTap: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A place on the road: a lesson, or the reward at the end of a section.
class _PathPoint {
  final NatureLesson? lesson;
  final NatureSection section;
  final Offset at;
  const _PathPoint(this.lesson, this.section, this.at);

  bool get isReward => lesson == null;
}

class LessonPathScreen extends StatefulWidget {
  final DateTime? today;
  const LessonPathScreen({super.key, this.today});

  @override
  State<LessonPathScreen> createState() => _LessonPathScreenState();
}

class _LessonPathScreenState extends State<LessonPathScreen> {
  final _store = NatureStore.instance;
  ScrollController? _scroll;

  static const _xs = [0.28, 0.72, 0.30, 0.70, 0.34];
  static const _top = 72.0;
  static const _doneBanner = 210.0;
  static const _headerHeight = 112.0;
  static const _gap = 140.0;

  @override
  void initState() {
    super.initState();
    _store.addListener(_changed);
  }

  @override
  void dispose() {
    _store.removeListener(_changed);
    _scroll?.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final p = _store.progress;
    final today = widget.today ?? DateTime.now();
    final allDone = allLessonsDone(p);
    final next = natureLessons.indexWhere((l) => !p.lessons.contains(l.id));
    return FidanTheme(
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final points = <_PathPoint>[];
              final headers = <(NatureSection, double)>[];
              var y = _top + (allDone ? _doneBanner : 0);
              for (final s in natureSections) {
                headers.add((s, y));
                y += _headerHeight;
                for (final stop in [...s.lessons.map<NatureLesson?>((l) => l), null]) {
                  final x = _xs[points.length % _xs.length] * w;
                  points.add(_PathPoint(stop, s, Offset(x, y + 42)));
                  y += _gap;
                }
              }
              final pts = points.map((e) => e.at).toList();
              bool isDone(_PathPoint e) => e.isReward ? e.section.lessons.every((l) => p.lessons.contains(l.id)) : p.lessons.contains(e.lesson!.id);
              final firstOpen = points.indexWhere((e) => !isDone(e));
              final doneUntil = firstOpen == -1 ? points.length - 1 : firstOpen;
              final current = next == -1 ? -1 : points.indexWhere((e) => e.lesson?.id == natureLessons[next].id);
              _scroll ??= ScrollController(initialScrollOffset: current <= 0 ? 0 : (pts[current].dy - box.maxHeight * 0.4).clamp(0.0, y));
              return SingleChildScrollView(
                controller: _scroll,
                child: SizedBox(
                  width: w,
                  height: y + 40,
                  child: Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: _RoadPainter(pts, doneUntil))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 14, 0),
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded, color: ink),
                            ),
                            Expanded(
                              child: Text(l10n.fidanPath, style: _t(22, weight: FontWeight.w900)),
                            ),
                            if (!p.hideStreak) _Pill('🔥 ${currentStreak(p.days, today)}'),
                            const SizedBox(width: 6),
                            _Pill('⭐ ${xpOf(p)}'),
                          ],
                        ),
                      ),
                      if (allDone)
                        Positioned(
                          left: 16,
                          right: 16,
                          top: _top,
                          height: _doneBanner - 16,
                          child: _AllDoneBanner(key: const Key('fidanAllDone'), today: today),
                        ),
                      for (final (s, top) in headers)
                        Positioned(
                          left: 16,
                          right: 16,
                          top: top,
                          height: _headerHeight - 16,
                          child: _SectionHeader(key: Key('natureSection-${s.id}'), section: s, lang: lang, done: s.lessons.where((l) => p.lessons.contains(l.id)).length),
                        ),
                      for (var i = 0; i < points.length; i++) ...[
                        Positioned(
                          left: pts[i].dx - 42,
                          top: pts[i].dy - 42,
                          child: points[i].isReward ? _RewardStop(key: Key('natureSectionReward-${points[i].section.id}'), section: points[i].section, earned: isDone(points[i]), label: l10n.fidanSectionReward) : _stop(points[i].lesson!, p, next, today, l10n, lang),
                        ),
                        Positioned(
                          left: pts[i].dx < w / 2 ? pts[i].dx + 50 : 14,
                          right: pts[i].dx < w / 2 ? 10 : w - pts[i].dx + 50,
                          top: pts[i].dy - 30,
                          child: _label(points[i], p, next, l10n, lang),
                        ),
                        if (!points[i].isReward && p.lessons.contains(points[i].lesson!.id))
                          Positioned(
                            left: pts[i].dx + 20,
                            top: pts[i].dy - 54,
                            child: const Text('🍎', style: TextStyle(fontSize: 24)),
                          ),
                      ],
                      if (current >= 0)
                        Positioned(
                          left: (pts[current].dx - 130).clamp(0.0, w - 84),
                          top: pts[current].dy + 44,
                          child: TreeView(stage: treeStage(p), season: seasonOf(today), mood: Mood.happy, flowers: sectionsDone(p).length, size: 84),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _stop(NatureLesson lesson, NatureProgress p, int next, DateTime today, AppLocalizations l10n, String lang) {
    final done = p.lessons.contains(lesson.id);
    final isNext = next >= 0 && natureLessons[next].id == lesson.id;
    final open = done || isNext;
    return _Stop(
      state: done ? 2 : (isNext ? 1 : 0),
      lessonKey: Key('natureLesson-${lesson.id}'),
      label: lesson.title.of(lang),
      onTap: open
          ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NatureLessonScreen(lesson: lesson, today: today)))
          : () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.fidanLocked)));
            },
    );
  }

  Widget _label(_PathPoint e, NatureProgress p, int next, AppLocalizations l10n, String lang) {
    if (e.isReward) return Text(l10n.fidanSectionReward, maxLines: 2, overflow: TextOverflow.ellipsis, style: _t(16.5, weight: FontWeight.w800, color: const Color(0xFF62785A)));
    final lesson = e.lesson!;
    final done = p.lessons.contains(lesson.id);
    final isNext = next >= 0 && natureLessons[next].id == lesson.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lesson.title.of(lang),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: _t(16.5, weight: FontWeight.w800, color: isNext || done ? ink : const Color(0xFF62785A)),
        ),
        if (done) Text(l10n.fidanReplay, key: Key('natureReplay-${lesson.id}'), style: _t(13.5, weight: FontWeight.w800, color: leafDark)),
      ],
    );
  }
}

class _AllDoneBanner extends StatelessWidget {
  final DateTime today;
  const _AllDoneBanner({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = NatureStore.instance.progress;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFFFF4CF), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFF7C72F), width: 2)),
      child: Row(
        children: [
          TreeView(stage: treeStage(p), season: seasonOf(today), mood: Mood.happy, apples: applesOf(p).length, flowers: sectionsDone(p).length, size: 112),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: Text(l10n.fidanAllDone, maxLines: 3, overflow: TextOverflow.ellipsis, style: _t(22, weight: FontWeight.w900, color: leafDark))),
                const SizedBox(height: 4),
                Flexible(child: Text(l10n.fidanReplayMode(replayXp), maxLines: 4, overflow: TextOverflow.ellipsis, style: _t(14.5, color: inkSoft))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final NatureSection section;
  final String lang;
  final int done;
  const _SectionHeader({super.key, required this.section, required this.lang, required this.done});

  @override
  Widget build(BuildContext context) {
    final color = Color(section.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.55), width: 2)),
      child: Row(
        children: [
          LessonArtView(section.art, size: 58),
          const SizedBox(width: 10),
          Expanded(child: Text(section.title.of(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: _t(18, weight: FontWeight.w900))),
          const SizedBox(width: 8),
          Text('$done/${section.lessons.length}', style: _t(15, weight: FontWeight.w800, color: inkSoft)),
        ],
      ),
    );
  }
}

class _RewardStop extends StatelessWidget {
  final NatureSection section;
  final bool earned;
  final String label;
  const _RewardStop({super.key, required this.section, required this.earned, required this.label});

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: earned ? Color(section.color) : const Color(0xFFD3DEC8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 5),
      ),
      child: Icon(earned ? Icons.local_florist_rounded : Icons.card_giftcard_rounded, color: Colors.white, size: 42),
    ),
  );
}

class _RoadPainter extends CustomPainter {
  final List<Offset> pts;
  final int doneUntil;
  _RoadPainter(this.pts, this.doneUntil);

  Path _through(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 1; i < p.length; i++) {
      final a = p[i - 1], b = p[i];
      final mid = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, mid, b.dx, mid, b.dx, b.dy);
    }
    return path;
  }

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    c.drawPath(_through(pts), p..color = const Color(0xFFDCEBCB));
    if (doneUntil > 0) c.drawPath(_through(pts.sublist(0, doneUntil + 1)), p..color = const Color(0xFF8FD35F));
  }

  @override
  bool shouldRepaint(_RoadPainter o) => o.doneUntil != doneUntil || o.pts != pts;
}

class _Stop extends StatelessWidget {
  /// 2 done, 1 next, 0 locked.
  final int state;
  final Key? lessonKey;
  final String label;
  final VoidCallback onTap;
  const _Stop({required this.state, this.lessonKey, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      2 => leaf,
      1 => const Color(0xFFFFB627),
      _ => const Color(0xFFD3DEC8),
    };
    final stop = Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: lessonKey,
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: state == 1 ? const [BoxShadow(color: Color(0xCCFFC94D), blurRadius: 30, spreadRadius: 10)] : null,
          ),
          child: Icon(
            switch (state) {
              2 => Icons.replay_rounded,
              1 => Icons.play_arrow_rounded,
              _ => Icons.lock_rounded,
            },
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
    return state == 1 ? stop.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1, end: 1.05, duration: 900.ms, curve: Curves.easeInOut) : stop;
  }
}

class NatureLessonScreen extends StatefulWidget {
  final NatureLesson lesson;
  final DateTime? today;
  const NatureLessonScreen({super.key, required this.lesson, this.today});

  @override
  State<NatureLessonScreen> createState() => _NatureLessonScreenState();
}

class _NatureLessonScreenState extends State<NatureLessonScreen> {
  final _pages = PageController();
  int _step = 0;
  final Set<int> _answered = {};

  int get _cards => widget.lesson.cards.length;
  int get _total => _cards + widget.lesson.quiz.length;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final store = NatureStore.instance;
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final before = store.progress;
    final replay = before.lessons.contains(widget.lesson.id);
    await (replay ? store.addReplay() : store.finishLesson(widget.lesson.id));
    final after = store.progress;
    final sectionsBefore = sectionsDone(before).map((s) => s.id).toSet();
    final newSection = sectionsDone(after).where((s) => !sectionsBefore.contains(s.id)).firstOrNull;
    final everything = allLessonsDone(after) && !allLessonsDone(before);
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FidanRewardScreen(
          xp: xpOf(after) - xpOf(before),
          newApple: applesOf(after).length > applesOf(before).length,
          grewTo: treeStage(after) > treeStage(before) ? treeStage(after) : null,
          message: everything ? l10n.fidanReplayMode(replayXp) : (replay ? l10n.fidanRewardReplay : l10n.fidanRewardLesson),
          today: widget.today ?? DateTime.now(),
          sectionTitle: newSection?.title.of(lang),
          allDone: everything,
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_step + 1 >= _total) {
      await _finish();
      return;
    }
    await _pages.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  Widget _card(LessonCard c, String lang) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Column(
      children: [
        const SizedBox(height: 22),
        LessonArtView(c.art, size: 180),
        const SizedBox(height: 20),
        Text(
          c.title.of(lang),
          textAlign: TextAlign.center,
          style: _t(27, weight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          c.body.of(lang),
          textAlign: TextAlign.center,
          style: _t(19, color: inkSoft, height: 1.3),
        ),
        const SizedBox(height: 6),
        for (final s in c.sources) _SourceText(s.name, s.url),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final inQuiz = _step >= _cards;
    return FidanTheme(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: inkSoft, size: 28),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(value: (_step + 1) / _total, minHeight: 12, color: leaf, backgroundColor: const Color(0xFFD5EBBD)),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    physics: inQuiz ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                    itemCount: _cards + (inQuiz ? widget.lesson.quiz.length : 1),
                    onPageChanged: (i) => setState(() => _step = i),
                    itemBuilder: (_, i) => i < _cards
                        ? _card(widget.lesson.cards[i], lang)
                        : LessonQuestionView(
                            key: ValueKey('nature-question-$i'),
                            question: widget.lesson.quiz[i - _cards],
                            onAnswered: (_) => setState(() => _answered.add(i)),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                BigGreenButton(_step + 1 >= _total ? l10n.natureFinish : l10n.fidanContinue, key: const Key('natureNext'), onTap: !inQuiz || _answered.contains(_step) ? _next : null),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One question of any kind, with its feedback once it is answered.
class LessonQuestionView extends StatefulWidget {
  final LessonQuestion question;
  final ValueChanged<bool> onAnswered;
  const LessonQuestionView({super.key, required this.question, required this.onAnswered});

  @override
  State<LessonQuestionView> createState() => _LessonQuestionViewState();
}

class _LessonQuestionViewState extends State<LessonQuestionView> {
  bool? _correct;

  void _answer(bool correct) {
    if (_correct != null) return;
    HapticFeedback.lightImpact();
    setState(() => _correct = correct);
    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final q = widget.question;
    final locked = _correct != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          switch (q) {
            QuizQuestion() => _ChoiceBody(question: q, lang: lang, onAnswer: _answer, locked: locked),
            TrueFalseQuestion() => _TrueFalseBody(question: q, lang: lang, onAnswer: _answer, locked: locked),
            OrderQuestion() => _OrderBody(question: q, lang: lang, onAnswer: _answer, locked: locked),
            MatchQuestion() => _MatchBody(question: q, lang: lang, onAnswer: _answer),
          },
          if (_correct != null) ...[
            const SizedBox(height: 12),
            _FeedbackPanel(correct: _correct!, text: q.feedback.of(lang), sources: q.sources),
          ],
        ],
      ),
    );
  }
}

/// A short bounce, Fidan's own reaction and one sentence of explanation.
class _FeedbackPanel extends StatelessWidget {
  final bool correct;
  final String text;
  final List<NatureSource> sources;
  const _FeedbackPanel({required this.correct, required this.text, required this.sources});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = NatureStore.instance.progress;
    final fidan = TreeView(stage: treeStage(p).clamp(1, 5), mood: correct ? Mood.happy : Mood.thirsty, size: 76);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFDDF4C6) : const Color(0xFFFFEBD6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              correct
                  ? fidan.animate().scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut)
                  : fidan.animate().shake(duration: 450.ms, hz: 5),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${correct ? l10n.fidanCorrect : l10n.fidanAlmost} $text',
                  key: const Key('natureFeedback'),
                  style: _t(16.5, weight: FontWeight.w800, color: correct ? leafDark : const Color(0xFF8A4B10)),
                ),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [for (final s in sources) _SourceText(s.name, s.url)],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0, duration: 260.ms, curve: Curves.easeOut);
  }
}

Widget _prompt(String text) => Text(text, style: _t(23, weight: FontWeight.w900));

Widget _help(String text) => Padding(
  padding: const EdgeInsets.only(top: 4, bottom: 10),
  child: Text(text, style: _t(14.5, color: inkSoft)),
);

const _wrongRed = Color(0xFFE5392F);

BoxDecoration _answerBox({required bool right, required bool wrong, bool picked = false}) => BoxDecoration(
  color: right ? const Color(0xFFDDF4C6) : (wrong ? const Color(0xFFFFE0DB) : Colors.white),
  border: Border.all(color: right ? leaf : (wrong ? _wrongRed : (picked ? const Color(0xFFFFB627) : const Color(0xFFDDE8D2))), width: picked ? 3 : 2),
  borderRadius: BorderRadius.circular(18),
);

class _ChoiceBody extends StatefulWidget {
  final QuizQuestion question;
  final String lang;
  final ValueChanged<bool> onAnswer;
  final bool locked;
  const _ChoiceBody({required this.question, required this.lang, required this.onAnswer, required this.locked});

  @override
  State<_ChoiceBody> createState() => _ChoiceBodyState();
}

class _ChoiceBodyState extends State<_ChoiceBody> {
  int? _chosen;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final order = optionOrder(q);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _prompt(q.question.of(widget.lang)),
        const SizedBox(height: 14),
        for (final (shown, option) in order.indexed) _option(shown, option),
      ],
    );
  }

  Widget _option(int shown, int option) {
    final q = widget.question;
    final answered = _chosen != null;
    final right = answered && option == q.correct;
    final wrong = answered && option == _chosen && option != q.correct;
    Widget box = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('natureOption-$shown'),
          borderRadius: BorderRadius.circular(18),
          onTap: answered || widget.locked
              ? null
              : () {
                  setState(() => _chosen = option);
                  widget.onAnswer(option == q.correct);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: _answerBox(right: right, wrong: wrong),
            child: Row(
              children: [
                Expanded(
                  child: Text(q.options[option].of(widget.lang), style: _t(17, weight: FontWeight.w700, color: right ? leafDark : inkSoft)),
                ),
                if (right) const Icon(Icons.check_circle_rounded, color: leaf, size: 26),
                if (wrong) const Icon(Icons.cancel_rounded, color: _wrongRed, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
    if (wrong) box = box.animate().shake(duration: 400.ms, hz: 6);
    if (right) box = box.animate().scaleXY(begin: 0.96, end: 1, duration: 260.ms, curve: Curves.easeOutBack);
    return box;
  }
}

class _TrueFalseBody extends StatefulWidget {
  final TrueFalseQuestion question;
  final String lang;
  final ValueChanged<bool> onAnswer;
  final bool locked;
  const _TrueFalseBody({required this.question, required this.lang, required this.onAnswer, required this.locked});

  @override
  State<_TrueFalseBody> createState() => _TrueFalseBodyState();
}

class _TrueFalseBodyState extends State<_TrueFalseBody> {
  bool? _chosen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = widget.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: LessonArtView(q.art, size: 150)),
        const SizedBox(height: 14),
        Text(q.statement.of(widget.lang), textAlign: TextAlign.center, style: _t(21, weight: FontWeight.w900)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _button(l10n.fidanTrue, true, const Key('natureTrue'))),
            const SizedBox(width: 10),
            Expanded(child: _button(l10n.fidanFalse, false, const Key('natureFalse'))),
          ],
        ),
      ],
    );
  }

  Widget _button(String text, bool value, Key key) {
    final q = widget.question;
    final answered = _chosen != null;
    final right = answered && value == q.isTrue;
    final wrong = answered && value == _chosen && value != q.isTrue;
    Widget box = Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(18),
        onTap: answered || widget.locked
            ? null
            : () {
                setState(() => _chosen = value);
                widget.onAnswer(value == q.isTrue);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: _answerBox(right: right, wrong: wrong),
          child: Text(text, textAlign: TextAlign.center, style: _t(18, weight: FontWeight.w800, color: right ? leafDark : ink)),
        ),
      ),
    );
    if (wrong) box = box.animate().shake(duration: 400.ms, hz: 6);
    if (right) box = box.animate().scaleXY(begin: 0.96, end: 1, duration: 260.ms, curve: Curves.easeOutBack);
    return box;
  }
}

class _OrderBody extends StatefulWidget {
  final OrderQuestion question;
  final String lang;
  final ValueChanged<bool> onAnswer;
  final bool locked;
  const _OrderBody({required this.question, required this.lang, required this.onAnswer, required this.locked});

  @override
  State<_OrderBody> createState() => _OrderBodyState();
}

class _OrderBodyState extends State<_OrderBody> {
  late List<int> _order = stepOrder(widget.question);
  bool _checked = false;

  void _move(int from, int to) => setState(() => _order = movedItem(_order, from, to));

  void _check() {
    final right = isInOrder(_order);
    setState(() {
      _checked = true;
      _order = List<int>.generate(_order.length, (i) => i);
    });
    widget.onAnswer(right);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = widget.question;
    final last = _order.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _prompt(q.prompt.of(widget.lang)),
        _help(l10n.fidanOrderHelp),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _order.length,
          onReorderItem: (from, to) {
            if (!_checked) _move(from, to);
          },
          itemBuilder: (_, i) {
            final step = _order[i];
            return Padding(
              key: ValueKey('natureStep-$step'),
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                  decoration: _answerBox(right: _checked, wrong: false),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: _lightGreen, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: _t(15, weight: FontWeight.w900, color: leafDark)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(q.steps[step].of(widget.lang), key: Key('natureStepText-$step'), style: _t(16.5, weight: FontWeight.w700)))),
                      if (!_checked) ...[
                        IconButton(key: Key('natureUp-$i'), visualDensity: VisualDensity.compact, tooltip: l10n.fidanMoveUp, onPressed: i == 0 ? null : () => _move(i, i - 1), icon: const Icon(Icons.keyboard_arrow_up_rounded, color: leafDark)),
                        IconButton(key: Key('natureDown-$i'), visualDensity: VisualDensity.compact, tooltip: l10n.fidanMoveDown, onPressed: i == last ? null : () => _move(i, i + 1), icon: const Icon(Icons.keyboard_arrow_down_rounded, color: leafDark)),
                        ReorderableDragStartListener(
                          index: i,
                          child: Padding(padding: const EdgeInsets.fromLTRB(2, 8, 10, 8), child: Icon(Icons.drag_handle_rounded, key: Key('natureDrag-$i'), color: inkSoft)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (!_checked && !widget.locked) ...[
          const SizedBox(height: 6),
          BigGreenButton(l10n.fidanCheck, key: const Key('natureCheck'), onTap: _check),
        ],
      ],
    );
  }
}

class _MatchBody extends StatefulWidget {
  final MatchQuestion question;
  final String lang;
  final ValueChanged<bool> onAnswer;
  const _MatchBody({required this.question, required this.lang, required this.onAnswer});

  @override
  State<_MatchBody> createState() => _MatchBodyState();
}

class _MatchBodyState extends State<_MatchBody> {
  int? _picked;
  int? _wrongRight;
  int _mistakes = 0;
  final Set<int> _matched = {};

  void _tapRight(int j) {
    final left = _picked;
    if (left == null || _matched.contains(j)) return;
    if (left == j) {
      HapticFeedback.selectionClick();
      setState(() {
        _matched.add(j);
        _picked = null;
        _wrongRight = null;
      });
      if (_matched.length == widget.question.pairs.length) widget.onAnswer(_mistakes == 0);
    } else {
      setState(() {
        _mistakes++;
        _wrongRight = j;
      });
    }
  }

  Widget _tile(String text, Key key, {required bool matched, required bool picked, required bool wrong, required VoidCallback? onTap}) {
    Widget tile = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 66),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: _answerBox(right: matched, wrong: wrong, picked: picked),
            child: Text(text, textAlign: TextAlign.center, style: _t(15, weight: FontWeight.w700, color: matched ? leafDark : ink)),
          ),
        ),
      ),
    );
    if (wrong) tile = tile.animate(key: ValueKey(_mistakes)).shake(duration: 350.ms, hz: 6);
    return tile;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = widget.question;
    final right = matchOrder(q);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _prompt(q.prompt.of(widget.lang)),
        _help(l10n.fidanMatchHelp),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < q.pairs.length; i++)
                    _tile(
                      q.pairs[i].$1.of(widget.lang),
                      Key('natureMatchLeft-$i'),
                      matched: _matched.contains(i),
                      picked: _picked == i,
                      wrong: false,
                      onTap: _matched.contains(i) ? null : () => setState(() { _picked = i; _wrongRight = null; }),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  for (final j in right)
                    _tile(
                      q.pairs[j].$2.of(widget.lang),
                      Key('natureMatchRight-$j'),
                      matched: _matched.contains(j),
                      picked: false,
                      wrong: _wrongRight == j,
                      onTap: _matched.contains(j) ? null : () => _tapRight(j),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
