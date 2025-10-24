Map<String, String> buildHeaders({Map<String, String>? extraHeaders}) {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  if (extraHeaders != null) {
    headers.addAll(extraHeaders);
  }

  return headers;
}
