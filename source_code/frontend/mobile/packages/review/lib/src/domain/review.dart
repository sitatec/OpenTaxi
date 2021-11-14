import 'package:data_access/data_access.dart';

part 'review_implementation.dart';

abstract class Review {
  final String? id;
  final int rating;
  final String comment;
  final String authorId;
  final String recipientId;

  Review._internal({
    this.id,
    required this.rating,
    required this.comment,
    required this.authorId,
    required this.recipientId,
  });

  factory Review({
    String? id,
    required int rating,
    required String comment,
    required String authorId,
    required String recipientId,
  }) =>
      ReviewImplementation(id, rating, comment, authorId, recipientId);

  Future<void> submit();
}
