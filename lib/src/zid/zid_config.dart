/// Runtime configuration for Zid merchant integrations.
class ZidConfig {
  final String storeId;
  final bool isSandbox;
  final String primaryColorHex;
  final bool isEnabled;

  const ZidConfig({
    required this.storeId,
    required this.isSandbox,
    required this.primaryColorHex,
    required this.isEnabled,
  });
}

