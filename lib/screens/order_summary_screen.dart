import 'package:flutter/material.dart';

import '../models/placed_order.dart';
import '../theme/app_theme.dart';
import '../widgets/async_body_states.dart';
import '../widgets/placed_order_card.dart';
import '../services/order_repository.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: _OrdersFromFirestoreBody(r: r),
        ),
      ),
    );
  }
}

class _OrdersFromFirestoreBody extends StatelessWidget {
  final R r;

  const _OrdersFromFirestoreBody({required this.r});

  @override
  Widget build(BuildContext context) {
    final orders = OrderRepository();
    return StreamBuilder<List<PlacedOrder>>(
      stream: orders.streamOrdersForUser(OrderRepository.localOrdersUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return StreamLoadingBody(r: r);
        }
        if (snapshot.hasError) {
          return StreamErrorBody(
            r: r,
            message: '${snapshot.error}',
            hint: 'Check Firestore rules allow read on orders.',
          );
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return StreamEmptyBody(
            r: r,
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            subtitle: 'Placed orders appear here',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            r.dp(16),
            r.dp(12),
            r.dp(16),
            r.dp(24),
          ),
          itemCount: orders.length,
          separatorBuilder: (_, _) => SizedBox(height: r.dp(10)),
          itemBuilder: (context, i) {
            return PlacedOrderCard(order: orders[i], r: r);
          },
        );
      },
    );
  }
}
