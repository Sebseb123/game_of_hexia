import 'package:game_of_hexia/src/models/resource_type.dart';

class BankOfResource {
  final Map<ResourceType, int> _bankOfResources = {};

  BankOfResource() {
    _bankOfResources[ResourceType.wood] = 19;
    _bankOfResources[ResourceType.cattle] = 19;
    _bankOfResources[ResourceType.stone] = 19;
    _bankOfResources[ResourceType.fish] = 19;
    _bankOfResources[ResourceType.iron] = 19;
  }

  Map<ResourceType, int> get resources => Map.unmodifiable(_bankOfResources);

  int getAmount(ResourceType resource) {
    return _bankOfResources[resource] ?? 0;
  }


  int getResource(ResourceType resourceType, {int amount = 1}) {

    // später Exception?
    if (amount <= 0) return 0;
    // später Exception?
    if (resourceType == ResourceType.empty) return 0;

    final availableAmount  = _bankOfResources[resourceType] ?? 0;
    if(availableAmount <= amount) {
      _bankOfResources[resourceType] = 0;
      return availableAmount;
    }
    _bankOfResources[resourceType] = availableAmount - amount;
    return amount;
  }

}
