import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library()..open();

  for (final json in rawBooks) {
    library.add(Book.fromJson(json));
  }
  library.add(const Magazine(title: 'Dart Weekly', year: 2024, issue: 42));

  print('Opened at ${library.openedAt}');

  for (final item in library.items) {
    print('${item.describe()} [old: ${item.isOld}]');
  }
  const ghost = Ghost(title: 'Broken Record (card only)');
  print('${ghost.describe()} [old: ${ghost.isOld}]');

  final first = library.books.first;
  print(first.borrowLabel());

  print('Refactoring: ${library.findByTitle('Refactoring')}');
  print('No Such Book: ${library.findByTitle('No Such Book')}');
  print('Country of Clean Code: ${library.countryOf('Clean Code')}');
  print('Country of Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Description of Clean Code: ${library.descriptionOf('Clean Code')}');

  print('Titles: ${library.allTitles}');
  print(
    'After 2010: ${library.publishedAfter2010.map((b) => b.title).toList()}',
  );
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.booksPerAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genres.map((g) => g.label).toSet()}');
  print(library.report);

  final books = library.books.toList();
  print('Stats: ${statsOf(books)}');
  print('Stats of empty: ${statsOf(const <Book>[])}');

  for (final state in <ShelfState>[
    const Empty(),
    Ready(books),
    const Broken('shelf 3 collapsed'),
  ]) {
    print(describe(state));
  }

  print(first.copyWith(year: 2025, description: 'anniversary print'));
  print(const Book.missing());
}
