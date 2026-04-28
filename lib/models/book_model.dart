class Book {
  final String id;
  final String title;
  final String coverImage;
  final String pdfUrl;
  final double price;
  final String? description;

  Book({
    this.id = '',
    required this.title,
    required this.coverImage,
    required this.pdfUrl,
    required this.price,
    this.description,
  });

  factory Book.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return Book(
      id: id,
      title: data['title']?.toString() ?? '',
      coverImage:
          data['coverImage']?.toString() ?? '',
      pdfUrl:
          data['pdfUrl']?.toString() ?? '',
      price: _parsePrice(data['price']),
      description:
          data['description']?.toString(),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "coverImage": coverImage,
      "pdfUrl": pdfUrl,
      "price": price,
      "description": description,
    };
  }
}