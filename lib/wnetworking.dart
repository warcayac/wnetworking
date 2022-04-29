library wnetworking;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:xml2json/xml2json.dart';

import 'src/customized/multipart_list_request.dart' as whttp;
import 'src/http_response_status_codes.dart';

part 'src/socket_service.dart';
part 'src/print_service.dart';
part 'src/http_request_service.dart';
