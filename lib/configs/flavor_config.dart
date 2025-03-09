class FlavorConfig {
  final String name;
  final bool enableSaveLog;

  FlavorConfig({required this.name, required this.enableSaveLog});

  // Helper methods
  // String get someThing => someValue + someValue2;
}

class FlavorValues {
  static final dev = FlavorConfig(name: 'Developer', enableSaveLog: true);

  static final staging = FlavorConfig(name: 'Staging', enableSaveLog: true);

  static final prod = FlavorConfig(name: 'Production', enableSaveLog: false);
}
