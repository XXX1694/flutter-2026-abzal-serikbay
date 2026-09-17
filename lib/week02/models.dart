abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  bool get isOld => year < 2000;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title" ($year)';
}

class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => country == null ? name : '$name ($country)';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  final String label;

  const Genre(this.label);

  factory Genre.fromString(String? raw) {
    final value = raw;
    if (value == null) return Genre.unknown;

    return Genre.values.firstWhere(
      (g) => g.name.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => Genre.unknown,
    );
  }
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  const Book.missing()
    : pages = 0,
      author = const Author(name: 'Unknown Author'),
      genre = Genre.unknown,
      description = null,
      super(title: 'Unknown Title', year: 0);

  factory Book.fromJson(Map<String, dynamic> json) {
    final rawAuthor = json['author'] as String?;
    final author = Author(
      name: rawAuthor == null || rawAuthor.isEmpty
          ? 'Unknown Author'
          : rawAuthor,
      country: json['country'] as String?,
    );

    return Book(
      title: json['title'] as String? ?? 'Untitled',
      year: (json['year'] as num?)?.toInt() ?? 0,
      pages: (json['pages'] as num?)?.toInt() ?? 0,
      author: author,
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }

  bool get isLong => pages > 400;

  @override
  String describe() =>
      '$title ($year) by $author - ${genre.label}, $pages p.'
      '${description == null ? '' : ' - $description'}';

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String toString() =>
      'Book(title: "$title", year: $year, pages: $pages, '
      'author: $author, genre: ${genre.label}, isLong: $isLong)';
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() => '$title #$issue ($year) - magazine';

  @override
  String toString() => 'Magazine(title: "$title", year: $year, issue: $issue)';
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({this.title = 'Lost item', this.year = 0});

  @override
  String describe() => '$title - a record with no item behind it';

  @override
  bool get isOld => true;

  @override
  String toString() => 'Ghost(title: "$title")';
}
