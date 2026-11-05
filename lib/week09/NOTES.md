# Notes

## Level 1: Lift it up

Total in the badge: 2 constructors touched (`BooksScreen`, `CartBadge`) in 3 files: `main.dart`, `books_screen.dart`, `cart_badge.dart`.

One tap on Add: 7 lines in the console (1 `BooksScreen build` + 6 `row`).

## Level 2: A model with no widgets

`main()` before `runApp` printed `1 items, 3100 ₸`. `cart.items.add(books[0])` threw `Unsupported operation: Cannot add to an unmodifiable list`.
