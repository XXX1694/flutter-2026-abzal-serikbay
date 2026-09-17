import 'models.dart';

class Library {
  final List<LibraryItem> items = <LibraryItem>[];

  late final DateTime openedAt;

  String? _cachedReport;

  void add(LibraryItem item) => items.add(item);

  void open() => openedAt = DateTime.now();

  Iterable<Book> get books => items.whereType<Book>();

  Book? findByTitle(String title) {
    for (final book in books) {
      if (book.title.toLowerCase() == title.toLowerCase()) return book;
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  String descriptionOf(String title) {
    final book = findByTitle(title);
    if (book == null) return 'no such book';

    final text = book.description;
    if (text == null) return 'no description';
    return text;
  }

  List<String> get allTitles => books.map((b) => b.title).toList();

  List<Book> get publishedAfter2010 =>
      books.where((b) => b.year > 2010).toList();

  // fold and not reduce: reduce throws on an empty library and keeps the
  // element type, while fold starts from an int seed of its own.
  double get averagePages => books.isEmpty
      ? 0.0
      : books.fold<int>(0, (sum, b) => sum + b.pages) / books.length;

  Map<String, int> get booksPerAuthor => books.fold<Map<String, int>>(
    <String, int>{},
    (acc, b) => acc..update(b.author.name, (n) => n + 1, ifAbsent: () => 1),
  );

  Set<String> get authorNames => books.map((b) => b.author.name).toSet();

  Set<Genre> get genres => books.map((b) => b.genre).toSet();

  List<String> get displayList => <String>[
    'CATALOGUE',
    for (final book in books) '${book.title} (${book.year})',
    ...authorNames,
    if (books.any((b) => b.pages == 0)) '(incomplete data)',
  ];

  String get report => _cachedReport ??= displayList.join('\n');
}
