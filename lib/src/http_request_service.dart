part of wnetworking;


// Common MIME types: 
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types


enum X2JConvention {parker, badgerfish, gData}
enum AuthType {
  noAuth,apiKey,bearerToken,basicAuth,
  // digestAuth,oAuth1,oAuth2,hawkAuth,
  // awsSignature,ntlmAuth,akamaiEdgeGrid
}

typedef JMap = Map<String, dynamic>;
typedef LJMap = List<JMap>;


class HttpReqService {
  /* ---------------------------------------------------------------------------- */
  @Deprecated('Use method Get')
  static Future<String?> getRaw(String url, {int okCode = 200}) {
    return http.get(Uri.parse(url))
      .then((response) {
        if (response.statusCode == okCode) {
          return response.body;
        }
        PrintService.showDataNotOK(response);
        return null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  @Deprecated('Use method Get')
  static Future<T?> getJson<T>(String url, {int okCode = 200, String? authBearer, Map<String, String>? headers}) {
    var localHeaders = <String, String>{};
    
    localHeaders['Accept'] = 'application/json';
    localHeaders['Content-Type'] = 'application/json';
    if (authBearer != null) localHeaders['Authorization'] = 'Bearer $authBearer';
    if (headers != null) localHeaders.addAll(headers);

    return http.get(Uri.parse(url), headers: localHeaders)
      .then((response) {
        if (response.statusCode == okCode) {
          return jsonDecode(response.body) as T;
        }
        PrintService.showDataNotOK(response);
        return null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  static Future<T?> getXml2Json<T>(String url, {int okCode = 200, String? authBearer, Map<String, String>? headers, X2JConvention convention = X2JConvention.gData}) {
    var localHeaders = <String, String>{};
    
    localHeaders['Accept'] = 'application/xml';
    localHeaders['Content-Type'] = 'application/json';
    if (authBearer != null) localHeaders['Authorization'] = 'Bearer $authBearer';
    if (headers != null) localHeaders.addAll(headers);

    return http.get(Uri.parse(url))
      .then((response) {
        if (response.statusCode == okCode) {
          var xmlDocument = Xml2Json()..parse(response.body);
          var jsonDocument = convention == X2JConvention.gData
            ? xmlDocument.toGData()
            : convention == X2JConvention.badgerfish
              ? xmlDocument.toBadgerfish()
              : xmlDocument.toParker();
          return jsonDecode(jsonDocument) as T;
        }
        PrintService.showDataNotOK(response);
        return null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  @Deprecated('Use method Post')
  static Future<T?> postFiles<T>(String url, {List<MapEntry<String, String>>? paths, List<MapEntry<String, String>>? fields}) async {
    // var request = http.MultipartRequest('POST', Uri.parse(url));
    // FROM: https://stackoverflow.com/questions/66327288/how-to-set-a-field-with-multi-value-into-a-post-request
    var request = whttp.MultipartListRequest('POST', Uri.parse(url));

    if (paths != null && paths.isNotEmpty) {
      paths.forEach((path) { 
        var file = File.fromUri(Uri.parse(path.value));
        var multipartFile = http.MultipartFile.fromBytes(
          path.key, file.readAsBytesSync(), filename: p.basename(file.path)
        );
        request.files.add(multipartFile);
      });
    }

    if (fields != null && fields.isNotEmpty) {
      // request.fields.addEntries(fields);
      request.fields.addAll(fields);
    }

    return http.Response
      .fromStream(await request.send())
      .then((response) {
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as T;
        }
        PrintService.showDataNotOK(response);
        return null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  static Future<T?> get<T>(String url, {AuthType auth = AuthType.noAuth, Object? authData, Object? body, Map<String, String>? headers, int okCode = 200, bool jsonResponse = true, Map<String, Object>? multipart, bool returnWasOkOnly = false, bool ifMapThenMap = true}) {
    return _baseRequest<T>(
      'GET', url, auth: auth, authData: authData, body: body,
      headers: headers, okCode: okCode, jsonResponse: jsonResponse, 
      multipart: multipart, returnWasOkOnly: returnWasOkOnly,
    );
  }
  /* ---------------------------------------------------------------------------- */
  static Future<T?> post<T>(String url, {AuthType auth = AuthType.noAuth, Object? authData, Object? body, Map<String, String>? headers, int okCode = 200, bool jsonResponse = false, Map<String, Object>? multipart, bool returnWasOkOnly = false, bool ifMapThenMap = true}) {
    return _baseRequest<T>(
      'POST', url, auth: auth, authData: authData, body: body,
      headers: headers, okCode: okCode, jsonResponse: jsonResponse, 
      multipart: multipart, returnWasOkOnly: returnWasOkOnly,
    );
  }
  /* ---------------------------------------------------------------------------- */
  /// ***AuthType.apikey*** => **authData** is MapEntry<String,String>
  /// 
  /// ***AuthType.basicAuth*** => **authData** is MapEntry<String,String>. 
  /// Generally <username,password>
  /// 
  /// ***AuthType.bearerToken*** => **authData** is String
  /// 
  /// ***headers*** = {Content-Type: application/json} by default
  /// 
  /// ***body***, if **multipart** is set then it must be a Map<String,Object>; 
  /// if it is a Map<String,Object> and **multipart** is null, it must be saved by using 
  /// **bodyFields**, otherwise, it is converted to String
  /// 
  /// ***multipart*** generally used to attach files or byte streams. If *value* from 
  /// a MapEntry is a String, *value* must be a full path to an existing local file. 
  /// If *value* from a MapEntry is a Uint8List, *value* is an object existing in memory.
  /// 
  /// If ***returnWasOkOnly*** is true, the future response will be a bool type (that is, 
  /// T must be bool) indicating the Post operation was successfully or not only.
  /// 
  /// If ***jsonResponse*** is true, the future response will be handled as a JSON format
  /// 
  /// ***ifMapThenMap***, by default is true. If **body** is a Map<String, Object> type, 
  /// then **body.map** is used to convert it, else **jsonEncode** is used.
  static Future<T?> _baseRequest<T>(String name, String url, {AuthType auth = AuthType.noAuth, Object? authData, Object? body, Map<String, String>? headers, int okCode = 200, bool jsonResponse = false, Map<String, Object>? multipart, bool returnWasOkOnly = false, bool ifMapThenMap = true}) async {
    var _headers = headers ?? (
      multipart != null 
        ? {'Content-Type': 'application/json'}
        : body == null
          ? {'Content-Type': 'application/json'}
          : body is Map<String,Object>
            ? {'Content-Type': 'application/x-www-form-urlencoded'}
            : body is String
              ? {'Content-Type': 'text/plain'}
              : {} // especificar: image/jpeg,application/javascript,application/xml,text/html
    );

    switch (auth) {
      case AuthType.apiKey:
        if (authData != null && authData is MapEntry<String,String>) {
          _headers[authData.key] = authData.value;
        }
        break;
      case AuthType.basicAuth:
        if (authData != null && authData is MapEntry<String,String>) {
          var token = base64Encode(utf8.encode('${authData.key}:${authData.value}'));
          _headers['Authorization'] = 'Basic ${base64Encode(utf8.encode(token))}';
        }
        break;
      case AuthType.bearerToken:
        if (authData != null && authData is String) {
          _headers['Authorization'] = 'Bearer $authData';
        }
        break;
      default:
    }

    late http.BaseRequest request;

    if (multipart != null) {
      var rq = http.MultipartRequest(name, Uri.parse(url));
      request = rq;
      
      if (body != null) {
        if (body is Map<String,Object>) {
          var _body = body.map((key, value) {
            return MapEntry(key, value is String ? value : json.encode(value));
          });
          rq.fields.addAll(_body);
        } else {
          throw 'Body must be a Map<String,Object> type.';
        }
      }
      
      for (var part in multipart.entries) {
        if (part.value is String) {
          var path = part.value as String;
          if (File(path).existsSync()) {
            var mimeType = lookupMimeType(path);
            rq.files.add(await http.MultipartFile.fromPath(
              part.key, 
              path,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null
            ));
          } else {
            throw 'Path to file is invalid.';
          }
        } else if (part.value is Uint8List) {
          var raw = part.value as Uint8List;
          var mimeType = lookupMimeType('', headerBytes: raw.take(4).toList());
          rq.files.add(http.MultipartFile.fromBytes(
            part.key, 
            raw,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null
          ));
        } else {
          throw 'Type for multipart is not valid.';
        }
      }
      rq.headers.addAll(_headers);
    } else {
      var rq = http.Request(name, Uri.parse(url));
      request = rq;
      if (body != null) {
        if (body is Map<String,Object> && ifMapThenMap)  {
          var _body = body.map((key, value) {
            return MapEntry(key, value is String ? value : json.encode(value));
          });
          rq.bodyFields = _body;
        } else {
          print(body.runtimeType);
          print(body);
          rq.body = json.encode(body);
        }
      }
      rq.headers.addAll(_headers);
      print(rq.body.toString());
    }

    return http.Response
      .fromStream(await request.send())
      .then((response) {
        if (response.statusCode == okCode) {
          return returnWasOkOnly 
            ? true as T
            : (jsonResponse ? jsonDecode(response.body) : response.body) as T;
        }
        PrintService.showDataNotOK(response);
        return returnWasOkOnly ? false as T : null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  static Future<T?> postGraphQL<T>(String url, {Map<String, String>? headers, required String query, JMap? variables, int okCode = 200}) async {
    var request = http.Request('POST', Uri.parse(url));

    request
      ..body = jsonEncode({'query': query, 'variables': variables ?? {}})
      ..headers.addAll(headers ?? {'Content-Type': 'application/json'});

    var response = await request.send();

    if (response.statusCode == okCode) {
      return jsonDecode(await response.stream.bytesToString()) as T;
    }
    PrintService.showDataNotOK(http.Response(
      await response.stream.bytesToString(), 
      response.statusCode,
      reasonPhrase: response.reasonPhrase,
    ));
    return null;
  }
  /* ---------------------------------------------------------------------------- */
  // PUT : Update/Replace
  static Future<T?> putJson<T>(String url, {required Object body, int okCode = 200}) {
    return http.put(
        Uri.parse(url), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(body)
      )
      .then((response) {
        if (response.statusCode == okCode) {
          return jsonDecode(response.body) as T;
        }
        PrintService.showDataNotOK(response);
        return null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  // PATCH : Update/Modify
  static Future<T?> patchJson<T>(String url, {required Object body, int okCode = 200}) {
    return http.patch(
        Uri.parse(url), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(body)
      )
      .then((response) {
        if (response.statusCode == okCode) {
          return jsonDecode(response.body) as T;
        }
        PrintService.showDataNotOK(response);
        return null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  static Future<T?> deleteJson<T>(String url, {int okCode = 200}) {
    return http.delete(
        Uri.parse(url), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      )
      .then((response) {
        final flag = response.statusCode == okCode;

        if (T == bool) return flag as T;
        if (flag) return jsonDecode(response.body) as T;

        PrintService.showDataNotOK(response);
        return null;
      })
      .catchError((err) => PrintService.showError(err));
  }
  /* ---------------------------------------------------------------------------- */
  /// noEmptyResponses : For broadcasts streamed as ndjson, i.e. one JSON object per line.
  static Stream<T> getStream<T>(String url, {int okCode = 200, String? authBearer, Map<String, String>? headers, bool showEmptyResponses = false}) {
    StreamController<T>? _controller;
    final httpClient = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    var localHeaders = <String, String>{};
     
     _controller= StreamController<T>(
       onCancel: () {
         _controller!.close();
        //  print('Controller closed!!!');
       },
     );
    
    localHeaders['Accept'] = 'application/json';
    if (authBearer != null) localHeaders['Authorization'] = 'Bearer $authBearer';
    if (headers != null) localHeaders.addAll(headers);
    request.headers.addAll(localHeaders);

    httpClient
      .send(request)
      .then((response) {
        if (response.statusCode == okCode) {
          StreamSubscription<List<int>>? rawSubscription;
          rawSubscription = response.stream.listen(
            (raw) {
              // print('event called!.... Controller closed? ${_controller!.isClosed}');
              if (!_controller!.isClosed) {
                final data = utf8.decode(raw);
                if (showEmptyResponses || (raw.isNotEmpty && !['\n','\r\n','\r'].contains(data))) {
                  _controller.sink.add(jsonDecode(data) as T);
                }
              } else {
                rawSubscription!.cancel();
              }
            },
            onError: (err) {
              _controller!.close();
              print('Error on listening....');
              PrintService.showError(err);
            },
            onDone: () => _controller!.close(),
            cancelOnError: true,
          );
        } else {
          throw Exception(
            'Status code not valid [${response.statusCode} - ${response.reasonPhrase}]'
          );
          // Véase: https://github.com/dart-lang/sdk/issues/42525
          return null;
        }
      })
      .catchError((err) {
        // https://stackoverflow.com/questions/63425222/can-exceptions-thrown-in-dart-streams-be-handled-by-subscribers-without-closing
        _controller!.sink.addError(Exception());
        _controller.close();
        PrintService.showError(err);
      });
    // print('El controlador es pasado exitosamente');
    return _controller.stream;
  }
  /* ---------------------------------------------------------------------------- */
  /* ---------------------------------------------------------------------------- */
}

      // .asStream()
      // .listen(
      //   (response) {
      //     print('Status Code: ${response.statusCode}...');
      //     response.stream
      //       .listen(
      //         (raw) {
      //           final data = utf8.decode(raw);
      //           if (showEmptyResponses || (raw.isNotEmpty && !['\n','\r\n','\r'].contains(data))) {
      //             _controller.sink.add(json.decode(data) as T);
      //           }
      //         },
      //         onError: (err) {
      //           print('Error on second listening....');
      //           _PrintService.showError(err);
      //         },
      //         onDone: () {
      //           print('Streaming finished.');
      //           _controller.close();
      //         },
      //       );
      //   },
      //   onError: (err) {
      //     print('Error on first listening....');
      //     _PrintService.showError(err);
      //   },
      // );
