import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/couple_action_card.dart';
import '../widgets/anniversary_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  static const List<_CardData> _actions = [
    _CardData(
      icon: Icons.photo_library_rounded,
      label: 'Our Photos',
      subtitle: 'Shared memories',
      gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      badge: '24',
    ),
    _CardData(
      icon: Icons.calendar_today_rounded,
      label: 'Date Night',
      subtitle: 'Plan your next date',
      gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    _CardData(
      icon: Icons.favorite_rounded,
      label: 'Love Notes',
      subtitle: 'Sweet messages',
      gradient: [Color(0xFFE91E8C), Color(0xFFF48FB1)],
      badge: '3 new',
    ),
    _CardData(
      icon: Icons.stars_rounded,
      label: 'Bucket List',
      subtitle: 'Dreams to chase',
      gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
      badge: '12',
    ),
    _CardData(
      icon: Icons.music_note_rounded,
      label: 'Our Songs',
      subtitle: 'Your soundtrack',
      gradient: [Color(0xFFFC5C7D), Color(0xFF6A3093)],
    ),
    _CardData(
      icon: Icons.restaurant_menu_rounded,
      label: 'Food Diary',
      subtitle: 'Places you\'ve been',
      gradient: [Color(0xFFF7971E), Color(0xFFFFD200)],
    ),
    _CardData(
      icon: Icons.map_rounded,
      label: 'Travel Map',
      subtitle: 'Adventures together',
      gradient: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    ),
    _CardData(
      icon: Icons.celebration_rounded,
      label: 'Milestones',
      subtitle: 'Your special moments',
      gradient: [Color(0xFFDA22FF), Color(0xFF9733EE)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Love';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(displayName, auth),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: AnniversaryBanner()
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final card = _actions[index];
                  return CoupleActionCard(
                    icon: card.icon,
                    label: card.label,
                    subtitle: card.subtitle,
                    gradient: LinearGradient(
                      colors: card.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    badge: card.badge,
                    index: index,
                    onTap: () => _onCardTap(context, card.label),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 100 + index * 80),
                        duration: 400.ms,
                      )
                      .slideY(begin: 0.3, end: 0)
                      .scale(begin: const Offset(0.9, 0.9));
                },
                childCount: _actions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String displayName, AuthProvider auth) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFFE91E8C),
                    Color(0xFF7C4DFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment(
                    0.5 + _headerController.value * 0.3,
                    1.0,
                  ),
                ),
              ),
              child: child,
            );
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $displayName 👋',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ).animate().fadeIn(duration: 600.ms),
                          const SizedBox(height: 4),
                          const Text(
                            'Your Couple Space',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 600.ms),
                        ],
                      ),
                      Row(
                        children: [
                          _buildAvatarStack(auth),
                          const SizedBox(width: 8),
                          _buildSignOutButton(auth),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildAvatarStack(AuthProvider auth) {
    return GestureDetector(
      onTap: () => _showProfileSheet(context, auth),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white30,
            child: Icon(
              Icons.person_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 24,
            ),
          ),
          Positioned(
            right: -10,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white10,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: GestureDetector(
        onTap: () async {
          final confirm = await _showSignOutDialog(context);
          if (confirm == true) {
            await auth.signOut();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _onCardTap(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('$label — coming soon! 💕'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProfileSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ProfileSheet(auth: auth),
    );
  }

  Future<bool?> _showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  final AuthProvider auth;
  const _ProfileSheet({required this.auth});

  @override
  Widget build(BuildContext context) {
    final user = auth.user;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.primaryLight,
            child: Text(
              (user?.displayName?.isNotEmpty == true
                      ? user!.displayName![0]
                      : user?.email?[0] ?? 'U')
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppTheme.primary),
            title: const Text('Edit Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading:
                const Icon(Icons.settings_rounded, color: AppTheme.primary),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final String? badge;

  const _CardData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    this.badge,
  });
}
