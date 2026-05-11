import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const ZaidCvApp());

class AppColors {
  static const bg = Color(0xFF050816);
  static const card = Color(0xFF0D1228);
  static const card2 = Color(0xFF111936);
  static const gold = Color(0xFFF6C453);
  static const cyan = Color(0xFF34D6FF);
  static const purple = Color(0xFF8B5CF6);
  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFFB8C2D8);
}

class ZaidCvApp extends StatelessWidget {
  const ZaidCvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'زيد الريمي | CV',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'sans',
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final scrollController = ScrollController();
  final aboutKey = GlobalKey();
  final servicesKey = GlobalKey();
  final contactKey = GlobalKey();
  late final AnimationController introController;
  bool showIntro = true;

  @override
  void initState() {
    super.initState();
    introController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    introController.forward();
    Future.delayed(const Duration(milliseconds: 3300), () {
      if (mounted) setState(() => showIntro = false);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    introController.dispose();
    super.dispose();
  }

  Future<void> callPhone() async {
    final uri = Uri.parse('tel:770158410');
    await launchUrl(uri);
  }

  void scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: NavHeader(
                  onHome: () => scrollController.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic),
                  onAbout: () => scrollTo(aboutKey),
                  onServices: () => scrollTo(servicesKey),
                  onContact: () => scrollTo(contactKey),
                  onCall: callPhone,
                ),
              ),
              SliverToBoxAdapter(child: HeroSection(onCall: callPhone, onServices: () => scrollTo(servicesKey))),
              SliverToBoxAdapter(key: aboutKey, child: const AboutSection()),
              SliverToBoxAdapter(key: servicesKey, child: const ServicesSection()),
              SliverToBoxAdapter(key: contactKey, child: ContactSection(onCall: callPhone)),
              const SliverToBoxAdapter(child: Footer()),
            ],
          ),
          if (showIntro) IntroOverlay(animation: introController),
        ],
      ),
    );
  }
}

class NavHeader extends SliverPersistentHeaderDelegate {
  final VoidCallback onHome, onAbout, onServices, onContact, onCall;
  NavHeader({required this.onHome, required this.onAbout, required this.onServices, required this.onContact, required this.onCall});

  @override
  double get minExtent => 78;
  @override
  double get maxExtent => 78;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final wide = MediaQuery.sizeOf(context).width > 820;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg.withOpacity(.72),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.08))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Row(
                children: [
                  const Text.rich(TextSpan(text: 'زيد ', style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w900), children: [TextSpan(text: 'الريمي', style: TextStyle(color: AppColors.cyan))])),
                  const Spacer(),
                  if (wide) ...[
                    NavButton('الرئيسية', onHome),
                    NavButton('نبذة', onAbout),
                    NavButton('الخدمات', onServices),
                    NavButton('تواصل', onContact),
                    const SizedBox(width: 12),
                  ],
                  GoldButton(label: 'اتصل الآن', icon: Icons.phone, onTap: onCall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant NavHeader oldDelegate) => false;
}

class NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const NavButton(this.label, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => TextButton(onPressed: onTap, child: Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800)));
}

class HeroSection extends StatelessWidget {
  final VoidCallback onCall, onServices;
  const HeroSection({super.key, required this.onCall, required this.onServices});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 880;
    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height - 78),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 115, child: _HeroText(onCall: onCall, onServices: onServices)), const SizedBox(width: 45), const Expanded(flex: 85, child: ProfileCard())])
              : Column(children: [_HeroText(onCall: onCall, onServices: onServices, centered: true), const SizedBox(height: 35), const ProfileCard()]),
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final VoidCallback onCall, onServices;
  final bool centered;
  const _HeroText({required this.onCall, required this.onServices, this.centered = false});

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      child: Column(
        crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          const Badge(text: '✨ تطوير احترافي'),
          const SizedBox(height: 18),
          Text.rich(
            const TextSpan(text: 'مرحباً، أنا ', children: [TextSpan(text: 'زيد الريمي', style: TextStyle(color: AppColors.gold, shadows: [Shadow(color: Color(0x66F6C453), blurRadius: 28)]))]),
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: MediaQuery.sizeOf(context).width < 450 ? 42 : 70, height: 1.15, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 18),
          Text('مصمم جرافيك | محرر فيديو | فني هواتف ذكية', textAlign: centered ? TextAlign.center : TextAlign.start, style: const TextStyle(color: AppColors.cyan, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text('أجمع بين الحس الفني الدقيق والخبرة التقنية العميقة. متخصص في صناعة الهويات البصرية التجارية، هندسة أوامر الذكاء الاصطناعي لتوليد تصاميم استثنائية، تحرير ومونتاج الفيديو باحترافية، بالإضافة إلى تقديم حلول متكاملة في صيانة وبرمجة الهواتف الذكية.', textAlign: centered ? TextAlign.center : TextAlign.start, style: const TextStyle(color: AppColors.muted, fontSize: 18, height: 2)),
          ),
          const SizedBox(height: 28),
          Wrap(spacing: 14, runSpacing: 12, alignment: centered ? WrapAlignment.center : WrapAlignment.start, children: [GoldButton(label: '770158410', icon: Icons.phone, onTap: onCall), DarkButton(label: 'استعرض الخدمات', onTap: onServices)]),
          const SizedBox(height: 30),
          const StatsGrid(),
        ],
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});
  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      delay: 250,
      child: AnimatedBuilder(
        animation: c,
        builder: (_, child) => Transform.translate(offset: Offset(0, math.sin(c.value * math.pi * 2) * -7), child: child),
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          radius: 34,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: c,
                builder: (_, __) => Container(
                  width: 190,
                  height: 190,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(startAngle: c.value * math.pi * 2, colors: const [AppColors.cyan, AppColors.purple, AppColors.gold, AppColors.cyan]),
                    boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(.32), blurRadius: 35), BoxShadow(color: AppColors.purple.withOpacity(.16), blurRadius: 80)],
                  ),
                  child: ClipOval(child: Image.asset('assets/profile.jpg', fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 22),
              const Text('زيد الريمي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Creative Designer & Smartphone Technician', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 18),
              Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: ['تصميم شعارات','هوية بصرية','مونتاج فيديو','ذكاء اصطناعي','صيانة هواتف','برمجة أجهزة'].map((skill) => SkillChip(skill)).toList()),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 880;
    return SectionWrap(
      child: Column(children: [
        const SectionHead(small: 'من أنا؟', title: 'خبرة تجمع الإبداع بالتقنية', subtitle: 'أقدم حلولاً عملية وجذابة تساعد الأفراد والأنشطة التجارية على الظهور بشكل أفضل.'),
        wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _AboutText()), const SizedBox(width: 25), const Expanded(child: Timeline())]) : Column(children: [_AboutText(), const SizedBox(height: 20), const Timeline()]),
      ]),
    );
  }
}

class _AboutText extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const FadeSlide(child: GlassCard(child: Text('أعمل على تحويل الأفكار إلى تصاميم بصرية مؤثرة، وأهتم بالتفاصيل الصغيرة التي تصنع الفرق. أمتلك خبرة في تصميم الجرافيك، تحرير الفيديو، بناء الهويات التجارية، واستخدام أدوات الذكاء الاصطناعي لصناعة نتائج حديثة ومميزة. كما أقدم خدمات صيانة وبرمجة الهواتف الذكية بحلول دقيقة وموثوقة.', style: TextStyle(color: AppColors.muted, height: 2.1, fontSize: 18))));
}

class Timeline extends StatelessWidget {
  const Timeline({super.key});
  @override
  Widget build(BuildContext context) => const Column(children: [TimelineItem(title: 'الرؤية', text: 'تصميم عصري يخدم الهدف التجاري ويجذب الجمهور.'), TimelineItem(title: 'الأسلوب', text: 'دمج الفن، التقنية، والذكاء الاصطناعي لإنتاج عمل مختلف.'), TimelineItem(title: 'الالتزام', text: 'تنفيذ احترافي، اهتمام بالتفاصيل، وتسليم منظم.')]);
}

class TimelineItem extends StatelessWidget {
  final String title, text;
  const TimelineItem({super.key, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: FadeSlide(child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(.055), borderRadius: BorderRadius.circular(20), border: const Border(right: BorderSide(color: AppColors.gold, width: 4))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(text, style: const TextStyle(color: AppColors.muted))]))),
  );
}

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 950 ? 3 : width > 620 ? 2 : 1;
    final services = const [
      ('🎨','تصميم جرافيك','تصميم بوسترات، إعلانات، منشورات سوشيال ميديا، وبطاقات احترافية بأسلوب جذاب.'),
      ('🏷️','هويات بصرية وشعارات','صناعة شعارات وهوية تجارية كاملة تعبر عن نشاطك وتمنحك حضوراً قوياً.'),
      ('🎬','مونتاج وتحرير فيديو','تحرير فيديوهات، ريلز، مقدمات، موشن بسيط، وتحسين المحتوى المرئي للنشر.'),
      ('🤖','هندسة أوامر الذكاء الاصطناعي','كتابة برومبتات احترافية لتوليد صور، شعارات، فيديوهات، وأفكار تصميم متقدمة.'),
      ('📱','صيانة الهواتف الذكية','فحص وصيانة الأعطال، متابعة حالة الجهاز، وتقديم حلول فنية دقيقة.'),
      ('⚙️','برمجة الهواتف','حل مشاكل النظام، التفليش، الإعداد، التحديثات، وتحسين أداء الأجهزة.'),
    ];
    return SectionWrap(
      child: Column(children: [
        const SectionHead(small: 'الخدمات', title: 'ماذا أقدم لك؟', subtitle: 'خدمات متكاملة للإبداع الرقمي والحلول التقنية.'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 22, mainAxisSpacing: 22, childAspectRatio: columns == 1 ? 1.55 : 1.15),
          itemCount: services.length,
          itemBuilder: (_, i) => ServiceCard(icon: services[i].$1, title: services[i].$2, text: services[i].$3, delay: i * 80),
        )
      ]),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String icon, title, text;
  final int delay;
  const ServiceCard({super.key, required this.icon, required this.title, required this.text, required this.delay});
  @override
  Widget build(BuildContext context) => FadeSlide(
    delay: delay,
    child: GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 58, height: 58, decoration: BoxDecoration(color: AppColors.gold.withOpacity(.12), borderRadius: BorderRadius.circular(20)), alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize: 28))),
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.muted, height: 1.8))),
      ]),
    ),
  );
}

class ContactSection extends StatelessWidget {
  final VoidCallback onCall;
  const ContactSection({super.key, required this.onCall});
  @override
  Widget build(BuildContext context) => SectionWrap(
    child: FadeSlide(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(38),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(34), gradient: LinearGradient(colors: [AppColors.gold.withOpacity(.12), AppColors.cyan.withOpacity(.08)]), border: Border.all(color: Colors.white.withOpacity(.12))),
        child: Column(children: [
          const SectionHead(small: 'تواصل معي', title: 'هل تحتاج تصميماً أو خدمة تقنية؟', subtitle: 'اتصل مباشرة للحصول على خدمة احترافية.', compact: true),
          const SizedBox(height: 10),
          Text('770158410', textDirection: TextDirection.ltr, style: TextStyle(fontSize: MediaQuery.sizeOf(context).width < 450 ? 36 : 58, fontWeight: FontWeight.w900, color: AppColors.gold, shadows: [Shadow(color: AppColors.gold.withOpacity(.22), blurRadius: 25)])),
          const SizedBox(height: 16),
          GoldButton(label: 'اتصال مباشر', icon: Icons.phone, onTap: onCall),
        ]),
      ),
    ),
  );
}

class Footer extends StatelessWidget {
  const Footer({super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), alignment: Alignment.center, decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(.08)))), child: const Text('تصميم وتطوير زيد الريمي © جميع الحقوق محفوظة', style: TextStyle(color: AppColors.muted)));
}

class SectionWrap extends StatelessWidget {
  final Widget child;
  const SectionWrap({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 82), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: child)));
}

class SectionHead extends StatelessWidget {
  final String small, title, subtitle;
  final bool compact;
  const SectionHead({super.key, required this.small, required this.title, required this.subtitle, this.compact = false});
  @override
  Widget build(BuildContext context) => FadeSlide(child: Padding(padding: EdgeInsets.only(bottom: compact ? 10 : 42), child: Column(children: [Text(small, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 8), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 17))])));
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 650;
    final items = const [('6+','سنوات خبرة تقنية وإبداعية'), ('AI','هندسة أوامر وتصاميم ذكية'), ('360°','تصميم، فيديو، صيانة وبرمجة')];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: narrow ? 1 : 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: narrow ? 4.2 : 1.6,
        children: items.map((e) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.09))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(e.$1, style: const TextStyle(fontSize: 28, color: AppColors.gold, fontWeight: FontWeight.w900)), Text(e.$2, style: const TextStyle(color: AppColors.muted, fontSize: 13))]))).toList(),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const GoldButton({super.key, required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, color: const Color(0xFF08111F), size: 18),
    label: Text(label, style: const TextStyle(color: Color(0xFF08111F), fontWeight: FontWeight.w900)),
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), elevation: 12),
  );
}

class DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const DarkButton({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), side: BorderSide(color: Colors.white.withOpacity(.12)), backgroundColor: Colors.white.withOpacity(.08)), child: Text(label, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900)));
}

class Badge extends StatelessWidget {
  final String text;
  const Badge({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), decoration: BoxDecoration(color: AppColors.cyan.withOpacity(.10), borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.cyan.withOpacity(.24))), child: Text(text, style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w800)));
}

class SkillChip extends StatelessWidget {
  final String label;
  const SkillChip(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withOpacity(.08))), child: Text(label, style: const TextStyle(color: Color(0xFFDCE7FF), fontWeight: FontWeight.w700)));
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  const GlassCard({super.key, required this.child, this.radius = 30, this.padding = const EdgeInsets.all(32)});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withOpacity(.075), Colors.white.withOpacity(.035)]),
      border: Border.all(color: Colors.white.withOpacity(.10)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.28), blurRadius: 55, offset: const Offset(0, 22))],
    ),
    child: child,
  );
}

class FadeSlide extends StatefulWidget {
  final Widget child;
  final int delay;
  const FadeSlide({super.key, required this.child, this.delay = 0});
  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
  late final Animation<double> fade = CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
  @override
  void initState() { super.initState(); Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) c.forward(); }); }
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: fade, builder: (_, child) => Opacity(opacity: fade.value, child: Transform.translate(offset: Offset(0, (1 - fade.value) * 35), child: child)), child: widget.child);
}

class IntroOverlay extends StatelessWidget {
  final AnimationController animation;
  const IntroOverlay({super.key, required this.animation});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final fadeOut = animation.value > .78 ? 1 - ((animation.value - .78) / .22).clamp(0.0, 1.0) : 1.0;
        return Opacity(
          opacity: fadeOut,
          child: Container(
            color: AppColors.bg,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Transform.scale(
                  scale: Curves.easeOutBack.transform(animation.value.clamp(0, .38) / .38),
                  child: Stack(alignment: Alignment.center, children: [
                    Transform.rotate(angle: animation.value * math.pi * 5, child: Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, border: Border(top: const BorderSide(color: AppColors.gold, width: 2), bottom: const BorderSide(color: AppColors.cyan, width: 2), left: BorderSide(color: AppColors.gold.withOpacity(.2), width: 2), right: BorderSide(color: AppColors.cyan.withOpacity(.2), width: 2)), boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(.22), blurRadius: 45)]))),
                    const Text('تصميم وتطوير\nزيد الريمي', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 24, height: 1.7, fontWeight: FontWeight.w900, shadows: [Shadow(color: Color(0x88F6C453), blurRadius: 25)])),
                  ]),
                ),
                const SizedBox(height: 25),
                Opacity(opacity: .55 + math.sin(animation.value * math.pi * 8) * .25, child: const Text('CREATIVE • TECH • AI', textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.muted, letterSpacing: 2))),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.infinite, painter: BackgroundPainter());
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()..shader = const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF182153), AppColors.bg, Color(0xFF2A134F)]).createShader(rect);
    canvas.drawRect(rect, bgPaint);
    final gridPaint = Paint()..color = Colors.white.withOpacity(.018)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 42) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint); }
    for (double y = 0; y < size.height; y += 42) { canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
