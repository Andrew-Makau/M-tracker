import 'package:flutter/material.dart';

/// Global app state provider that manages the live/mock data toggle
class AppState extends ChangeNotifier {
  bool _useLiveData = false;

  bool get useLiveData => _useLiveData;

  void setLiveData(bool value) {
    if (_useLiveData != value) {
      _useLiveData = value;
      notifyListeners();
    }
  }

  void toggleLiveData() {
    _useLiveData = !_useLiveData;
    notifyListeners();
  }
}

/// InheritedWidget wrapper for AppState
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()
        ?.notifier;
  }
}
