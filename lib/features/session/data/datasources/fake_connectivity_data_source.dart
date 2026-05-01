import 'package:rxdart/rxdart.dart';
import 'connectivity_data_source.dart';

class FakeConnectivityDataSource implements ConnectivityDataSource {
  final _controller = BehaviorSubject<bool>.seeded(true);

  @override
  Stream<bool> watchIsOffline() => _controller.stream.map((c) => !c);

  @override
  Future<bool> get isConnected async => true;

  void setConnected(bool connected) {
    _controller.add(connected);
  }

  void dispose() {
    _controller.close();
  }
}
