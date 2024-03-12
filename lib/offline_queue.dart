import 'dart:async';

class OfflineQueue {
  static final OfflineQueue _instance = OfflineQueue._internal();

  factory OfflineQueue() => _instance;

  OfflineQueue._internal();

  final List<Future<bool>> _queue = [];
  bool _isProcessing = false;

  void addToQueue(Future<bool> action) {
    _queue.add(action);
    print("QUEUEEEEeeeeeeeeeeeee IS ${_queue}");
  }

  Future<void> processQueue() async {
    print("QUEUEEEE IS ${_queue}");
    if (!_isProcessing) {
      _isProcessing = true;
      while (_queue.isNotEmpty) {
        final action = _queue.removeAt(0);
        await action;
      }
      _isProcessing = false;
    }
  }
}
