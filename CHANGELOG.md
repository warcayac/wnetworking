## 0.0.1

* Initial release.

## 0.0.2

* Added `ifMapThenMap` parameter to POST/GET methods to have more control on how `body` will be encoded.

## 0.0.3

* `jsonResponse` parameter was removed from GET and POST methods. `jsonDecode` method is automatically applied if `T` is a **Map** or **List** type.

## 0.0.4

* Evaluation of generic data type fixed to determine if `jsonDecode` is applied.
