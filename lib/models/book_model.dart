class Book {
  final String id;
  final String title;
  final String coverImage;
  final String pdfUrl;
  final double price;

  Book({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.pdfUrl,
    required this.price,
  });

  factory Book.fromFirestore(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      coverImage: data['coverImage'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}