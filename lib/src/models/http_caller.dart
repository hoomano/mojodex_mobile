import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/error_notifier.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';

mixin HttpCaller {
  // Logger
  final Logger _logger = Logger('HttpCaller');

  // HTTP client for backend requests
  final _client = http.Client();
  http.Client get client => _client;

  // HTTP client for multipart requests
  final dio = Dio();

  Map<String, String> get _authenticationHeaders => {
        "Authorization": User().tokenBackendPython!,
      };

  Map<String, dynamic> get _necessaryData => {
        "datetime": DateTime.now().toIso8601String(),
        "version": dotenv.env['VERSION']!,
        "platform": "mobile"
      };

  String _getUrl(String service, String? params) {
    String url = "${dotenv.env['BACKEND_URI']}/$service";
    if (params != null) url += "?$params";
    _logger.fine(url);
    return url;
  }

  String _addRequiredParams(String params) {
    for (String data in _necessaryData.keys) {
      params = _addParamIfNotExist(params, data, _necessaryData[data]);
    }
    return params;
  }

  Map<String, dynamic> _addRequiredDataKeys(Map<String, dynamic> body) {
    for (String data in _necessaryData.keys) {
      body[data] = _necessaryData[data];
    }
    return body;
  }

  String _addParamIfNotExist(String params, String key, String value) {
    if (!params.startsWith("$key=") & !params.contains("&$key=")) {
      params += "${params.isEmpty ? '' : '&'}$key=$value";
    }
    return params;
  }

  void _unauthorized() {
    _logger.info("Unauthorized, relogin required");
    User().logout();
  }

  void _requestError(String service, http.Response response, bool silentError) {
    _logger.shout(
        "Error in $service: ${response.reasonPhrase} - ${response.body}");
    if (!silentError) {
      ErrorNotifier()
          .errorController
          .add(response.reasonPhrase ?? "Unknown error");
    }
    return;
  }

  void _requestException(String service, Object e, bool silentError) {
    _logger.shout("Error in $service exception: $e");
    if (!silentError) {
      ErrorNotifier().errorController.add(e.toString());
    }
    throw e;
  }

  bool _manageAnswer(String service, var response, bool silentError) {
    int statusCode = response.statusCode;
    _logger.fine("$service: $statusCode");
    if (statusCode == 403) {
      _unauthorized();
      return false;
    } else if (statusCode != 200) {
      _requestError(service, response, silentError);
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>?> get(
      {required String service,
      required String params,
      bool requestAuth = true,
      int timeout = 45}) async {
    http.Response? response = await _getCall(
        service: service,
        params: params,
        timeout: timeout,
        requestAuth: requestAuth);
    if (response == null) return null;
    Map<String, dynamic> body = json.decode(response.body);
    return body;
  }

  Future<http.Response?> getBytes(
      {required String service,
      required String params,
      bool requestAuth = true,
      int timeout = 45,
      bool getBodyBytes = false}) async {
    http.Response? response = await _getCall(
        service: service,
        params: params,
        timeout: timeout,
        requestAuth: requestAuth);
    if (response == null) return null;
    return response;
  }

  Future<http.Response?> _getCall(
      {required String service,
      required String params,
      required bool requestAuth,
      int timeout = 45,
      bool silentError = false}) async {
    try {
      params = _addRequiredParams(params);
      String url = _getUrl(service, params);
      Map<String, String>? headers =
          requestAuth ? _authenticationHeaders : null;
      http.Response response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(Duration(seconds: timeout));

      bool success = _manageAnswer(service, response, silentError);
      if (!success) return null;
      return response;
    } catch (e) {
      _requestException(service, e, silentError);
      return null;
    }
  }

  Future<Map<String, dynamic>?> post(
      {required String service,
      required Map<String, dynamic> body,
      String? params,
      int timeout = 45,
      bool authenticated = true,
      bool silentError = false,
      bool returnError = false}) async {
    try {
      String url = _getUrl(service, params);
      body = _addRequiredDataKeys(body);
      // headers = _authenticationHeaders + 'Content-Type': 'application/json'
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (authenticated) {
        headers.addAll(_authenticationHeaders);
      }
      var response = await _client
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: timeout));
      bool success = _manageAnswer(service, response, silentError);
      if (!success && !returnError) {
        return null;
      }
      return json.decode(response.body);
    } catch (e) {
      _requestException(service, e, silentError);
      return null;
    }
  }

  Future<Map<String, dynamic>?> put(
      {required String service,
      required Map<String, dynamic> body,
      String? params,
      int timeout = 45,
      bool authenticated = true,
      bool silentError = false,
      bool returnError = false}) async {
    try {
      String url = _getUrl(service, params);
      body = _addRequiredDataKeys(body);
      // headers = _headers + 'Content-Type': 'application/json'
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (authenticated) {
        headers.addAll(_authenticationHeaders);
      }
      var response = await _client
          .put(Uri.parse(url), body: jsonEncode(body), headers: headers)
          .timeout(Duration(seconds: timeout));
      bool success = _manageAnswer(service, response, silentError);
      if (!success && !returnError) {
        return null;
      }
      return json.decode(response.body);
    } catch (e) {
      _requestException(service, e, silentError);
      return null;
    }
  }

  Future<Map<String, dynamic>?> delete(
      {required String service,
      required String params,
      int timeout = 45,
      bool silentError = false}) async {
    try {
      params = _addRequiredParams(params);
      String url = _getUrl(service, params);

      http.Response response = await _client
          .delete(Uri.parse(url), headers: _authenticationHeaders)
          .timeout(Duration(seconds: timeout));

      bool success = _manageAnswer(service, response, silentError);
      if (!success) return null;
      return json.decode(response.body);
    } catch (e) {
      _requestException(service, e, silentError);
      return null;
    }
  }

  Future<Map<String, dynamic>?> putMultipart(
      {required String service,
      required Map<String, dynamic> formData,
      String? filePath,
      String? text,
      String? params,
      int timeout = 25,
      bool silentError = false,
      bool returnError = false}) async {
    try {
      String url = _getUrl(service, params);

      formData = _addRequiredDataKeys(formData);

      if (filePath != null) {
        formData['file'] = await MultipartFile.fromFile(filePath);
      }
      if (text != null) {
        formData['text'] = text;
      }

      // timeout depends on file length - values are in seconds
      int? fileLength = (formData['file'] as MultipartFile?)?.length;
      if (fileLength != null) {
        timeout = 15 + fileLength ~/ 5000;
        if (timeout > 70) timeout = 70;
      }

      Response response = await dio.put(url,
          data: FormData.fromMap(formData),
          options: Options(
              sendTimeout: Duration(seconds: timeout),
              receiveTimeout: Duration(seconds: timeout),
              headers: _authenticationHeaders));

      bool success = _manageAnswer(service, response, silentError);
      if (!success && !returnError) return null;

      return response.data;
    } catch (e) {
      _requestException(service, e, silentError);
      return null;
    }
  }

  Future<Map<String, dynamic>?> postMultipart(
      {required String service,
      required Map<String, dynamic> formData,
      String? filePath,
      String? text,
      String? params,
      int timeout = 25,
      bool silentError = false}) async {
    try {
      String url = _getUrl(service, params);

      formData = _addRequiredDataKeys(formData);

      if (filePath != null) {
        formData['file'] = await MultipartFile.fromFile(filePath);
      }
      if (text != null) {
        formData['text'] = text;
      }

      // timeout depends on file length - values are in seconds
      int? fileLength = (formData['file'] as MultipartFile?)?.length;
      if (fileLength != null) {
        timeout = 15 + fileLength ~/ 5000;
        if (timeout > 70) timeout = 70;
      }

      Response response = await dio.post(url,
          data: FormData.fromMap(formData),
          options: Options(
              sendTimeout: Duration(seconds: timeout),
              receiveTimeout: Duration(seconds: timeout),
              headers: _authenticationHeaders));

      bool success = _manageAnswer(service, response, silentError);
      if (!success) return null;

      return response.data;
    } catch (e) {
      _requestException(service, e, silentError);
      return null;
    }
  }
}
