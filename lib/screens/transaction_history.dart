import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/wallet_state_service.dart';
import '../services/utils.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final WalletStateService _walletService = WalletStateService();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'All';
  bool _isLoading = false;

  final List<String> _filterOptions = [
    'All',
    'Send Money',
    'Received Money',
    'Bill Payment',
    'Withdrawal',
    'Top Up',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more transactions when reaching bottom
      _loadMoreTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _walletService.refreshTransactions();
    } catch (e) {
      UIUtils.showSnackBar(
        context,
        'Failed to load transactions: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    // Implement pagination logic here
    UIUtils.showSnackBar(
      context,
      'Loading more transactions...',
    );
  }

  List<TransactionModel> _getFilteredTransactions() {
    final transactions = _walletService.transactions;

    if (_selectedFilter == 'All') {
      return transactions;
    }

    return transactions.where((transaction) {
      switch (_selectedFilter) {
        case 'Send Money':
          return transaction.type == TransactionType.send;
        case 'Received Money':
          return transaction.type == TransactionType.receive;
        case 'Bill Payment':
          return transaction.type == TransactionType.payBill;
        case 'Withdrawal':
          return transaction.type == TransactionType.withdraw;
        case 'Top Up':
          return transaction.type == TransactionType.topUp;
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return AnimationUtils.fadeIn(
            delay: index * 0.1,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    UIUtils.hapticFeedback();
                  }
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF1E88E5).withOpacity(0.1),
                checkmarkColor: const Color(0xFF1E88E5),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1E88E5)
                      : const Color(0xFF718096),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color:
                      isSelected ? const Color(0xFF1E88E5) : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionsList() {
    final filteredTransactions = _getFilteredTransactions();

    if (_isLoading && filteredTransactions.isEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          childCount: 10,
        ),
      );
    }

    if (filteredTransactions.isEmpty) {
      return SliverFillRemaining(
        child: AnimationUtils.fadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No transactions found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilter == 'All'
                    ? 'Start using your wallet to see transactions here'
                    : 'No $_selectedFilter transactions found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < filteredTransactions.length) {
            final transaction = filteredTransactions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: AnimationUtils.fadeInUp(
                delay: index * 0.05,
                child: TransactionCard(transaction: transaction),
              ),
            );
          } else {
            // Loading indicator at the bottom
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
        childCount: filteredTransactions.length + (_isLoading ? 1 : 0),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: AnimationUtils.fadeInLeft(
              child: const Text(
                'Transaction History',
                style: TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            leading: AnimationUtils.fadeInLeft(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            actions: [
              AnimationUtils.fadeInRight(
                child: IconButton(
                  onPressed: () {
                    // Show search functionality
                    UIUtils.showSnackBar(
                      context,
                      'Search functionality coming soon',
                    );
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildFilterChips(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Transactions List
          _buildTransactionsList(),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}
