## Approach Taken

**Architecture — Provider + Repository pattern**

The app follows a clean separation of concerns across four layers:

- **Models** (`Product`, `OrderItem`, `PlacedOrder`) are plain Dart classes with `fromJson`/`fromDoc` factory constructors and a `toMap()` serialiser. `Product.priceForCustomerType()` centralises the dealer discount logic (15% off base price).

- **Repositories** (`ProductRepository`, `OrderRepository`) isolate all Firestore access. Products are fetched once as a `Future`; orders use a real-time `Stream` so the Orders screen updates live. A hardcoded `localOrdersUid = 'local_device'` scopes all orders to the device without requiring authentication.

- **Provider** (`OrderProvider`, a `ChangeNotifier`) holds in-memory cart state. `setCustomerType()` rebuilds every `OrderItem` in place so prices reprice instantly when the type toggles. `addItem()` returns a nullable error string instead of throwing, letting the UI surface MOQ violations gracefully.

- **Screens & Widgets** consume the provider via `context.watch` / `context.read`. Feedback uses a `MaterialBanner` (`showTopMessage`) that auto-dismisses after 3 seconds — no `SnackBar` overlap issues. The barcode scanner pauses the camera on detection, looks up the product by barcode in Firestore, and lets the user add it directly to the cart.

**Responsive layout** is handled by a custom `R` class (computed from `MediaQuery`) that scales all `dp`/`sp` values, switches grid columns at 600 px, and caps content width on tablets/desktop via `ResponsiveBody`.



---

## Challenges Faced

None.


---

> **Note:** `google-services.json` is intentionally committed to this repository for Firebase connection testing purposes.
