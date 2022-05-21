## 0.1.0

* Initial release.

## 0.2.0

* Added `ifMapThenMap` parameter to POST/GET methods to have more control on how `body` will be encoded.

## 0.3.0

* `jsonResponse` parameter was removed from GET and POST methods. `jsonDecode` method is automatically applied if `T` is a **Map** or **List** type.

## 0.3.1

* Evaluation of generic data type fixed to determine if `jsonDecode` is applied.

## 0.4.0

* Added `limiTime` parameter to POST/GET methods. It's the timeout for the request.
* Removed deprecated message for `postFiles` method.
