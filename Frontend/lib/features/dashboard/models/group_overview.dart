import 'package:equatable/equatable.dart';

class GroupOverview extends Equatable {
  const GroupOverview({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.totalBalance,
  });

  final String id;
  final String name;
  final String? description;
  final List<String> members;
  final double totalBalance;

  factory GroupOverview.fromJson(Map<String, dynamic> json) {
    return GroupOverview(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      members: (json['members'] as List<dynamic>).cast<String>(),
      totalBalance:
          double.tryParse(json['total_balance'].toString()) ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, name, description, members, totalBalance];
}


