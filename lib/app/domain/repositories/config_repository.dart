import '../entities/config.dart';

abstract class ConfigRepository {
  Future<Config> getConfig();
}