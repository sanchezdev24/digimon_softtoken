class Config {
  final String keyRequest;
  final String keyResponse;
  final String username;
  final String password;

  Config({
    required this.keyRequest,
    required this.keyResponse,
    required this.username,
    required this.password,
  });

  @override
  String toString() {
    return 'Config(keyRequest: $keyRequest, keyResponse: $keyResponse, username: $username)';
  }
}