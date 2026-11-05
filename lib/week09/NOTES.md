# Notes

## Level 1: Lift it up

Total in the badge: 2 constructors touched (`BooksScreen`, `CartBadge`) in 3 files: `main.dart`, `books_screen.dart`, `cart_badge.dart`.

One tap on Add: 7 lines in the console (1 `BooksScreen build` + 6 `row`).

## Level 2: A model with no widgets

`main()` before `runApp` printed `1 items, 3100 ₸`. `cart.items.add(books[0])` threw `Unsupported operation: Cannot add to an unmodifiable list`.

## Level 3: Provider errors

Loud (`context.watch<Cart>().add(b)` in `onPressed`):

```
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false);
```

Silent (`context.read<Cart>().count` in the badge): no error, the badge stays at `0` forever.

## Level 4: Rebuilds of the badge

Three presses on `+` in the cart:

- `context.watch<Cart>().count`: `badge build` ×3
- `context.select<Cart, int>((c) => c.count)`: `badge build` ×0
- Remove a book with `select`: `badge build` ×1
- `context.watch<Cart>()` moved up into `BooksScreen.build`: 18 row rebuilds (6 rows × 3)

## Where does it live?

- Cart: provided. Books screen, badge and Cart screen all need it on different routes.
- Search text in the Books AppBar: ephemeral. Only the Books screen uses it to filter its list.
- Total expanded or collapsed: ephemeral. Only the total widget on the Cart screen cares.
- Theme mode: lifted (or provided) above `MaterialApp`. It is read by `MaterialApp` and changed by a switch deep down.
