abstract class ConnectivityDataSource {
  /// Current connectivity status
  Future<bool> get isConnected;

  /// Watch connectivity status
  Stream<bool> watchIsOffline();
}
