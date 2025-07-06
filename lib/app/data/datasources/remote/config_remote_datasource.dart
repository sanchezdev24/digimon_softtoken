import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../../domain/entities/config.dart';

class ConfigRemoteDatasource {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<Config> getConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();

      return Config(
        keyRequest: _remoteConfig.getString('key_request'),
        keyResponse: _remoteConfig.getString('key_response'),
        username: _remoteConfig.getString('username'),
        password: _remoteConfig.getString('password'),
      );
    } catch (e) {
      // Return default values if remote config fails
      return Config(
        keyRequest: '8ab8305c9e074ea1283abded33064415',
        keyResponse: '44724c66b53e3eae3445ffc941ccabf3',
        username: 'SoftToken-Strat',
        password: 'db2aee8dac1fb3ad1fa6ba3dbd7622e0',
      );
    }
  }
}