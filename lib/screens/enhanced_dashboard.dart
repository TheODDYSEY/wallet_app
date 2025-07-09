import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/wallet_state_service.dart';
import '../services/utils.dart';
import '../widgets/transaction_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/balance_card.dart';
import 'sendmoney.dart';
import 'paybill.dart';
import 'withdraw.dart';
import 'transaction_history.dart';

class EnhancedDashboard extends StatefulWidget {
  const EnhancedDashboard({super.key});

  @override
  State<EnhancedDashboard> createState() => _EnhancedDashboardState();
}

class _EnhancedDashboardState extends State<EnhancedDashboard>
    with TickerProviderStateMixin {
  final WalletStateService _walletService = WalletStateService();
  final PageController _pageController = PageController();

  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();

    // Listen to wallet service changes
    _walletService.addListener(_onWalletStateChanged);
  }

  void _initAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  void _onWalletStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isRefreshing = true;
    });

    _refreshController.forward();

    try {
      await _walletService.refreshData();
    } catch (e) {
      UIUtils.showSnackBar(
        context,
        'Failed to refresh data: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
      _refreshController.reset();
    }
  }

  Future<void> _onRefresh() async {
    UIUtils.hapticFeedback();
    await _loadData();
  }

  void _navigateToSendMoney() {
    Navigator.of(context).push(
      UIUtils.createRoute(const SendMoneyScreen()),
    );
  }

  void _navigateToPayBill() {
    Navigator.of(context).push(
      UIUtils.createRoute(const PayBillScreen()),
    );
  }

  void _navigateToWithdraw() {
    Navigator.of(context).push(
      UIUtils.createRoute(const WithdrawScreen()),
    );
  }

  void _navigateToTransactionHistory() {
    Navigator.of(context).push(
      UIUtils.createRoute(const TransactionHistoryScreen()),
    );
  }

  Widget _buildShimmerCard({
    required double height,
    double? width,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    if (_walletService.isLoading && _walletService.wallet == null) {
      return AnimationUtils.fadeIn(
        child: _buildShimmerCard(height: 180),
      );
    }

    return AnimationUtils.fadeInUp(
      child: BalanceCard(
        balance: _walletService.balance,
        formattedBalance: _walletService.formattedBalance,
        onRefresh: _onRefresh,
        isRefreshing: _isRefreshing,
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.send,
        'label': 'Send Money',
        'color': const Color(0xFF4CAF50),
        'onTap': _navigateToSendMoney,
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Pay Bills',
        'color': const Color(0xFF2196F3),
        'onTap': _navigateToPayBill,
      },
      {
        'icon': Icons.atm,
        'label': 'Withdraw',
        'color': const Color(0xFFFF9800),
        'onTap': _navigateToWithdraw,
      },
      {
        'icon': Icons.history,
        'label': 'History',
        'color': const Color(0xFF9C27B0),
        'onTap': _navigateToTransactionHistory,
      },
    ];

    return AnimationUtils.fadeInUp(
      delay: 0.2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;

                return AnimationUtils.fadeIn(
                  delay: 0.1 * index,
                  child: QuickActionButton(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    color: action['color'] as Color,
                    onTap: action['onTap'] as VoidCallback,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingAnalytics() {
    if (_walletService.isLoading) {
      return AnimationUtils.fadeIn(
        child: _buildShimmerCard(height: 200),
      );
    }

    final totalSpent = _walletService.getTotalSpentThisMonth();
    final totalReceived = _walletService.getTotalReceivedThisMonth();

    return AnimationUtils.fadeInUp(
      delay: 0.4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spent',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        UIUtils.formatCurrency(totalSpent),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53E3E),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Received',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        UIUtils.formatCurrency(totalReceived),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF38A169),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (totalSpent > 0 || totalReceived > 0) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (totalSpent > 0)
                        PieChartSectionData(
                          value: totalSpent,
                          color: const Color(0xFFE53E3E),
                          title: 'Spent',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (totalReceived > 0)
                        PieChartSectionData(
                          value: totalReceived,
                          color: const Color(0xFF38A169),
                          title: 'Received',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_walletService.isLoading && _walletService.transactions.isEmpty) {
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildShimmerCard(height: 80),
          ),
        ),
      );
    }

    final recentTransactions = _walletService.getRecentTransactions(limit: 5);

    if (recentTransactions.isEmpty) {
      return AnimationUtils.fadeIn(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your transaction history will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AnimationUtils.fadeInUp(
      delay: 0.6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                GestureDetector(
                  onTap: _navigateToTransactionHistory,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...AnimationUtils.staggeredList(
              children: recentTransactions
                  .map((transaction) =>
                      TransactionCard(transaction: transaction))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _pageController.dispose();
    _walletService.removeListener(_onWalletStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: AnimationUtils.fadeInLeft(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _walletService.currentUser?.firstName ?? 'User',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          AnimationUtils.fadeInRight(
            child: IconButton(
              onPressed: _onRefresh,
              icon: AnimatedBuilder(
                animation: _refreshAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _refreshAnimation.value * 2 * 3.14159,
                    child: const Icon(
                      Icons.refresh,
                      color: Color(0xFF2D3748),
                    ),
                  );
                },
              ),
            ),
          ),
          AnimationUtils.fadeInRight(
            delay: 0.1,
            child: IconButton(
              onPressed: () {
                // Navigate to notifications
              },
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF1E88E5),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildBalanceSection(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildSpendingAnalytics(),
              const SizedBox(height: 20),
              _buildRecentTransactions(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
