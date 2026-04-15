part of '../../../main.dart';

class _FootwearFeedCardData {
  const _FootwearFeedCardData({
    required this.item,
    required this.oldPrice,
    required this.couponPrice,
    required this.discount,
    required this.votes,
    this.promoted = false,
    this.newRank = 0,
  });

  final _DiscoveryItem item;
  final String oldPrice;
  final String couponPrice;
  final String discount;
  final String votes;
  final bool promoted;
  final int newRank;

  _FootwearFeedCardData copyWith({
    _DiscoveryItem? item,
    String? oldPrice,
    String? couponPrice,
    String? discount,
    String? votes,
    bool? promoted,
    int? newRank,
  }) {
    return _FootwearFeedCardData(
      item: item ?? this.item,
      oldPrice: oldPrice ?? this.oldPrice,
      couponPrice: couponPrice ?? this.couponPrice,
      discount: discount ?? this.discount,
      votes: votes ?? this.votes,
      promoted: promoted ?? this.promoted,
      newRank: newRank ?? this.newRank,
    );
  }
}
