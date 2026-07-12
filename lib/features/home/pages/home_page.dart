import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../../common_widgets/diary_elements.dart';
import '../../../db/database_helper.dart';
import '../../../model/diary_model.dart';
import '../../../utils/constant_color.dart';
import '../../entry_page/entry_page.dart';
import '../../lock/pages/security_settings_page.dart';

import '../../../utils/app_prefs.dart';

// ─── Home Page ────────────────────────────────────────────────────────────────

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage>
    with SingleTickerProviderStateMixin {
  List<DiaryEntry> _entries = [];
  int _monthCount = 0;
  bool _loading = true;
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadEntries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSecurityPrompt();
    });
  }

  Future<void> _checkSecurityPrompt() async {
    final pin = await AppPrefs.getPin();
    final hasPrompted = await AppPrefs.hasPromptedPin();

    if ((pin == null || pin.isEmpty) && !hasPrompted) {
      if (!mounted) return;
      await AppPrefs.setHasPromptedPin(true);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Set a PIN?"),
          content: const Text(
            "Would you like to protect your diary with a PIN lock?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("NOT NOW"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecuritySettingsPage(),
                  ),
                );
              },
              child: const Text("SET PIN"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseHelper.instance.getAllEntries();
    final count = await DatabaseHelper.instance.countEntriesThisMonth();
    if (mounted) {
      setState(() {
        _entries = entries;
        _monthCount = count;
        _loading = false;
      });
    }
  }

  Future<void> _goToNewEntry() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EntryPage()),
    );
    if (result == true) _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      body: Stack(
        children: [
          SizedBox.expand(child: CustomPaint(painter: BackgroundLinePainter())),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                SliverToBoxAdapter(child: _buildStatsRow()),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                SliverToBoxAdapter(child: _buildSectionLabel()),
                SliverToBoxAdapter(child: SizedBox(height: 8.h)),

                // ── Loading / empty / entries ──
                if (_loading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(48.r),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3E2723),
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  )
                else if (_entries.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _NoteCard(
                        entry: _entries[i],
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EntryPage(entry: _entries[i]),
                            ),
                          );
                          if (result == true) _loadEntries();
                        },
                      ),
                      childCount: _entries.length,
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          ),

          // ── FAB ──
          Positioned(
            bottom: 36.h,
            right: 24.w,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabAnim,
                curve: Curves.elasticOut,
              ),
              child: _NewEntryButton(onTap: _goToNewEntry),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF9E8E7E),
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Eluthu',
                    style: TextStyle(
                      fontSize: 38.sp,
                      color: const Color(0xFF2C1A0E),
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _DateBadge(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecuritySettingsPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.security_rounded,
                  color: AppColors.primaryAccent.withOpacity(0.4),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            height: 1.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD7B896), Color(0x00D7B896)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          _StatChip(icon: '✍️', value: '${_entries.length}', label: 'total'),
          SizedBox(width: 10.w),
          _StatChip(icon: '📅', value: '$_monthCount', label: 'this month'),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'RECENT PAGES',
            style: TextStyle(
              fontSize: 10.sp,
              letterSpacing: 2.5,
              color: const Color(0xFF9E8E7E),
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 48.h),
      child: Center(
        child: Column(
          children: [
            Text('📖', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 16.h),
            Text(
              'Your diary awaits...',
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                color: const Color(0xFF4A4A4A),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap "New Entry" to write your first page.',
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Georgia',
                color: const Color(0xFF9E9E9E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String icon, value, label;
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0CC),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFD4BFA0), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Georgia',
              color: const Color(0xFF2C1A0E),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF9E8E7E),
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date Badge ───────────────────────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1A0E),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        children: [
          Text(
            '${now.day}',
            style: TextStyle(
              fontSize: 22.sp,
              color: const Color(0xFFFFCC02),
              fontFamily: 'Georgia',
              height: 1.0,
            ),
          ),
          Text(
            months[now.month],
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFFBCAAA4),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Note Card ────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  const _NoteCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 6.h),
      child: GestureDetector(
        onTap: onTap,
        child: Transform.rotate(
          angle: entry.rotation * math.pi / 180 * 0.4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Shadow
              Positioned(
                top: 3.h,
                left: 3.w,
                right: -3.w,
                bottom: -3.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: entry.paperColor,
                  borderRadius: BorderRadius.circular(3.r),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.05),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top red line
                    Container(
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF9A9A).withOpacity(0.6),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(3.r),
                          topRight: Radius.circular(3.r),
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: RuledLinePainter(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(48.w, 14.h, 16.w, 14.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${entry.date}, ${entry.dayName}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFFE53935),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  entry.mood,
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              entry.title,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF1A1A1A),
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              entry.snippet,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF5A5A5A),
                                height: 1.65,
                                fontFamily: 'Georgia',
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tags row
                    if (entry.tags.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(48.w, 0, 16.w, 12.h),
                        child: Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: entry.tags
                              .map((tag) => _TagChip(tag: tag))
                              .toList(),
                        ),
                      )
                    else
                      SizedBox(height: 12.h),
                  ],
                ),
              ),
              // Margin line
              Positioned(
                left: 40.w,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 1,
                  color: const Color(0xFFEF9A9A).withOpacity(0.5),
                ),
              ),
              // Hole punches
              Positioned(left: 12.w, top: 20.h, child: const HolePunch()),
              Positioned(left: 12.w, bottom: 20.h, child: const HolePunch()),
              // Tape strip top
              Positioned(
                top: -6.h,
                left: 55.w + (entry.rotation * 5).abs(),
                child: TapeStrip(
                  color: const Color(0xFFB3E5FC).withOpacity(0.55),
                  child: SizedBox(width: 52.w, height: 14.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tag Chip ─────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC02).withOpacity(0.5),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(fontSize: 10.sp, color: const Color(0xFF4E342E)),
      ),
    );
  }
}

// ─── New Entry FAB ────────────────────────────────────────────────────────────

class _NewEntryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewEntryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: -0.02,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2C1A0E),
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
                Icons.edit_outlined,
                color: const Color(0xFFFFCC02),
                size: 17.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'New Entry',
                style: TextStyle(
                  color: const Color(0xFFFFF9C4),
                  fontSize: 14.sp,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
