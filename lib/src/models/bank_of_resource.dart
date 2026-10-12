import 'package:game_of_hexia/src/models/resource_type.dart';

/// Tracks a bank initialized with 19 cards of each resource type.
class BankOfResource {
  final Map<ResourceType, int> _bankOfResources = {};

  BankOfResource() {
    _bankOfResources[ResourceType.wood] = 19;
    _bankOfResources[ResourceType.cattle] = 19;
    _bankOfResources[ResourceType.stone] = 19;
    _bankOfResources[ResourceType.fish] = 19;
    _bankOfResources[ResourceType.iron] = 19;
  }

  /// An unmodifiable snapshot of the current stock.
  Map<ResourceType, int> get resources => Map.unmodifiable(_bankOfResources);

  int getAmount(ResourceType resource) {
    return _bankOfResources[resource] ?? 0;
  }

  /// Removes up to [amount] cards of [resourceType].
  ///
  /// Returns the number removed, or zero for an invalid request.
  int getResource(ResourceType resourceType, {int amount = 1}) {
    if (amount <= 0) return 0;
    if (resourceType == ResourceType.empty) return 0;

    final availableAmount = _bankOfResources[resourceType] ?? 0;
    if (availableAmount <= amount) {
      _bankOfResources[resourceType] = 0;
      return availableAmount;
    }
    _bankOfResources[resourceType] = availableAmount - amount;
    return amount;
  }
}
