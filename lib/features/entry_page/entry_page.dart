import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common_widgets/diary_elements.dart';
import '../../db/database_helper.dart';
import '../../model/diary_model.dart';

// ── Date helpers ──────────────────────────────────────────────────────────────

String _monthName(int m) => const [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][m];

String _dayName(int wd) => const [
  '',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][wd];

// ── Entry Page ────────────────────────────────────────────────────────────────

class EntryPage extends StatefulWidget {
  final DiaryEntry? entry;
  const EntryPage({super.key, this.entry});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _tagCtrl;

  late String _mood;
  late List<String> _tags;
  bool _saving = false;

  static const _moods = [
    '😊',
    '😢',
    '😴',
    '🤔',
    '😤',
    '🥰',
    '😎',
    '🌤️',
    '☕',
    '📸',
    '🥖',
    '🌙',
    '🎵',
    '✨',
    '🌸',
    '⚡',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.entry?.snippet ?? '');
    _tagCtrl = TextEditingController();
    _mood = widget.entry?.mood ?? '😊';
    _tags = widget.entry != null ? List.from(widget.entry!.tags) : [];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title for your entry')),
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final entry = DiaryEntry(
      id: widget.entry?.id,
      date: widget.entry?.date ?? '${_monthName(now.month)} ${now.day}',
      dayName: widget.entry?.dayName ?? _dayName(now.weekday),
      title: title,
      snippet: _contentCtrl.text.trim(),
      mood: _mood,
      paperColor: widget.entry?.paperColor ?? DiaryEntry.randomPaperColor(),
      rotation: widget.entry?.rotation ?? DiaryEntry.randomRotation(),
      tags: List.from(_tags),
    );

    if (widget.entry == null) {
      await DatabaseHelper.instance.insertEntry(entry);
    } else {
      await DatabaseHelper.instance.updateEntry(entry);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    if (widget.entry?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7F0E6),
        title: const Text(
          'Delete Entry?',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteEntry(widget.entry!.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  void _addTag() {
    final t = _tagCtrl.text.trim().replaceAll('#', '');
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() {
        _tags.add(t);
        _tagCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = widget.entry != null
        ? '${widget.entry!.date},  ${widget.entry!.dayName}'
        : '${_monthName(now.month)} ${now.day},  ${_dayName(now.weekday)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      body: Stack(
        children: [
          SizedBox.expand(child: CustomPaint(painter: BackgroundLinePainter())),
          SafeArea(
            child: Column(
              children: [
                _appBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TapeStrip(
                          color: const Color(0xFFFFCC02).withOpacity(0.55),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            child: Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 12.sp,
                                letterSpacing: 1,
                                color: const Color(0xFF4E342E),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        _titleCard(),
                        SizedBox(height: 18.h),

                        _moodPicker(),
                        SizedBox(height: 18.h),

                        _contentCard(),
                        SizedBox(height: 18.h),

                        _tagsSection(),
                        SizedBox(height: 36.h),

                        _saveButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1A0E),
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xFFF5EDD6),
                    size: 13.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: const Color(0xFFF5EDD6),
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.entry != null) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _delete,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE53935).withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: const Color(0xFFE53935),
                  size: 18.sp,
                ),
              ),
            ),
          ],
          const Spacer(),
          Transform.rotate(
            angle: -0.02,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1A0E),
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                widget.entry == null ? 'New Entry' : 'Edit Entry',
                style: TextStyle(
                  color: const Color(0xFFFFCC02),
                  fontSize: 16.sp,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleCard() {
    return Transform.rotate(
      angle: -0.005,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 4,
            left: 4,
            right: -4,
            bottom: -4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(3.r),
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
            child: CustomPaint(
              painter: RuledLinePainter(
                startY: 36,
                spacing: 24,
                color: const Color(0xFF90CAF9).withOpacity(0.35),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(48.w, 14.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFFE53935),
                        letterSpacing: 1,
                      ),
                    ),
                    TextField(
                      controller: _titleCtrl,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What happened today...',
                        hintStyle: TextStyle(
                          color: const Color(0xFFBCAAA4),
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 20.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 40.w,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: const Color(0xFFEF9A9A).withOpacity(0.5),
            ),
          ),
          Positioned(left: 12.w, top: 16.h, child: const HolePunch()),
        ],
      ),
    );
  }

  Widget _moodPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TapeStrip(
          color: const Color(0xFF80CBC4).withOpacity(0.45),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            child: Text(
              'Mood  —  tap to pick',
              style: TextStyle(
                fontSize: 11.sp,
                letterSpacing: 1.5,
                color: const Color(0xFF37474F),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _moods.map((m) {
            final sel = m == _mood;
            return GestureDetector(
              onTap: () => setState(() => _mood = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF2C1A0E)
                      : const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(2.r),
                  border: Border.all(
                    color: sel
                        ? const Color(0xFFFFCC02)
                        : const Color(0xFFBCAAA4).withOpacity(0.4),
                    width: sel ? 1.5 : 0.5,
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Text(m, style: TextStyle(fontSize: 22.sp)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _contentCard() {
    return Transform.rotate(
      angle: 0.004,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 4,
            left: 4,
            right: -4,
            bottom: -4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(3.r),
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
            child: CustomPaint(
              painter: RuledLinePainter(
                startY: 36,
                spacing: 24,
                color: const Color(0xFF90CAF9).withOpacity(0.35),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(48.w, 14.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's thoughts",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFFE53935),
                        letterSpacing: 1,
                      ),
                    ),
                    TextField(
                      controller: _contentCtrl,
                      maxLines: 7,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Georgia',
                        color: const Color(0xFF4A4A4A),
                        height: 1.7,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Pour your heart out...',
                        hintStyle: TextStyle(
                          color: const Color(0xFFBCAAA4),
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 40.w,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: const Color(0xFFEF9A9A).withOpacity(0.5),
            ),
          ),
          Positioned(left: 12.w, top: 16.h, child: const HolePunch()),
          Positioned(left: 12.w, bottom: 16.h, child: const HolePunch()),
        ],
      ),
    );
  }

  Widget _tagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TapeStrip(
          color: const Color(0xFFFFCC02).withOpacity(0.55),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            child: Text(
              'Tags',
              style: TextStyle(
                fontSize: 11.sp,
                letterSpacing: 1.5,
                color: const Color(0xFF4E342E),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  border: Border.all(
                    color: const Color(0xFFBCAAA4).withOpacity(0.5),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: TextField(
                  controller: _tagCtrl,
                  onSubmitted: (_) => _addTag(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Georgia',
                    color: const Color(0xFF4E342E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'nature, morning...',
                    hintStyle: TextStyle(
                      color: const Color(0xFFBCAAA4),
                      fontStyle: FontStyle.italic,
                      fontSize: 13.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    border: InputBorder.none,
                    prefixText: '# ',
                    prefixStyle: TextStyle(
                      color: const Color(0xFFE53935),
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _addTag,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1A0E),
                  borderRadius: BorderRadius.circular(2.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: const Color(0xFFFFCC02),
                    fontSize: 13.sp,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _tags
                .map(
                  (t) => GestureDetector(
                    onTap: () => setState(() => _tags.remove(t)),
                    child: TapeStrip(
                      color: const Color(0xFFFFCC02).withOpacity(0.6),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#$t',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF4E342E),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.close,
                              size: 12.sp,
                              color: const Color(0xFF9E8E7E),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _saveButton() {
    return Center(
      child: GestureDetector(
        onTap: _saving ? null : _save,
        child: Transform.rotate(
          angle: -0.02,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: _saving
                  ? const Color(0xFF6D4C41)
                  : const Color(0xFF2C1A0E),
              borderRadius: BorderRadius.circular(3.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _saving
                      ? Icons.hourglass_empty_rounded
                      : (widget.entry == null
                            ? Icons.bookmark_add_outlined
                            : Icons.save_as_outlined),
                  color: const Color(0xFFFFCC02),
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  _saving
                      ? 'Saving...'
                      : (widget.entry == null ? 'Save Entry' : 'Update Entry'),
                  style: TextStyle(
                    color: const Color(0xFFFFF9C4),
                    fontSize: 16.sp,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
