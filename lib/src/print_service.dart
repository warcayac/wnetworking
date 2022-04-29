part of wnetworking;


class PrintService {
  /* ---------------------------------------------------------------------------- */
  static void showDataNotOK(http.Response response) {
    final line = '-' * 80;
    print(line);
    print('STATUS_CODE : ${response.statusCode} - ${getHttpStatusCodeDesc(response.statusCode)}');
    print('DATA_RETURNED: ${response.body}');
    print(line);
  }
  /* ---------------------------------------------------------------------------- */
  static void showDataNotOKSimple(int code) {
    final line = '-' * 80;
    print(line);
    print('STATUS_CODE : $code - ${getHttpStatusCodeDesc(code)}');
    print(line);
  }
  /* ---------------------------------------------------------------------------- */
  static dynamic showError(err) {
    final line = '-' * 80;
    print(line);
    print('ERROR_CATCHED : $err');
    print(line);
    return null;
  }
}
