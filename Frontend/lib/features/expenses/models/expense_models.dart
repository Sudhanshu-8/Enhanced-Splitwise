import 'package:equatable/equatable.dart';

class ExpenseParticipant extends Equatable {
  const ExpenseParticipant({
    required this.participantId,
    required this.share,
  });

  final String participantId;
  final double share;

  Map<String, dynamic> toJson() => {
        'participant_id': participantId,
        'share': share,
      };

  @override
  List<Object?> get props => [participantId, share];
}

class ExpenseDraft extends Equatable {
  const ExpenseDraft({
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.occurredAt,
    this.category,
    this.notes,
    this.receiptUrl,
    required this.split,
  });

  final String groupId;
  final String title;
  final double amount;
  final String paidBy;
  final DateTime occurredAt;
  final String? category;
  final String? notes;
  final String? receiptUrl;
  final List<ExpenseParticipant> split;

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'title': title,
        'amount': amount,
        'paid_by': paidBy,
        'category': category,
        'notes': notes,
        'receipt_url': receiptUrl,
        'occurred_at': occurredAt.toIso8601String(),
        'split': split.map((participant) => participant.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        groupId,
        title,
        amount,
        paidBy,
        category,
        notes,
        receiptUrl,
        occurredAt,
        split,
      ];
}

class ReceiptSuggestion extends Equatable {
  const ReceiptSuggestion({
    this.merchant,
    this.date,
    this.total,
    this.currency,
    this.items = const [],
    this.rawText,
  });

  final String? merchant;
  final String? date;
  final double? total;
  final String? currency;
  final List<Map<String, String>> items;
  final String? rawText;

  factory ReceiptSuggestion.fromJson(Map<String, dynamic> json) {
    return ReceiptSuggestion(
      merchant: json['merchant'] as String?,
      date: json['date'] as String?,
      total: json['total'] != null
          ? double.tryParse(json['total'].toString())
          : null,
      currency: json['currency'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                (item) => (item as Map).map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              )
              .toList() ??
          const [],
      rawText: json['raw_text'] as String?,
    );
  }

  @override
  List<Object?> get props => [merchant, date, total, currency, items, rawText];
}


