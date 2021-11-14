part of 'review.dart';

@internal
class ReviewImplementation extends Review {
  final ReviewRepository _reviewRepository;

  ReviewImplementation(
    String? id,
    int rating,
    String comment,
    String authorId,
    String recipientId, [
    ReviewRepository? repository,
  ])  : _reviewRepository = repository ?? ReviewRepository(),
        super._internal(
          id: id,
          rating: rating,
          comment: comment,
          authorId: authorId,
          recipientId: recipientId,
        );

  @override
  Future<void> submit() {
    return _reviewRepository.create(_toJson());
  }

  JsonObject _toJson() => {
        "id": id,
        "rating": rating,
        "comment": comment,
        "authorId": authorId,
        "recipientId": recipientId,
      };
}
