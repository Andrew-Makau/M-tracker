import 'package:flutter/material.dart';
import 'loading_transaction_card.dart';

class LoadingList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  const LoadingList({super.key, this.itemCount = 6, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => LoadingTransactionCard(height: itemHeight),
    );
  }
}
