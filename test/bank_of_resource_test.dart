import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/models/bank_of_resource.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

void main() {
  test('starts with 19 cards of every resource type', () {
    final bank = BankOfResource();

    for (final resource in ResourceType.values) {
      if (resource == ResourceType.empty) continue;
      expect(bank.getAmount(resource), 19);
    }
    expect(bank.getAmount(ResourceType.empty), 0);
  });

  test('returns the available amount without making the stock negative', () {
    final bank = BankOfResource();

    expect(bank.getResource(ResourceType.wood, amount: 18), 18);
    expect(bank.getAmount(ResourceType.wood), 1);
    expect(bank.getResource(ResourceType.wood, amount: 2), 1);
    expect(bank.getAmount(ResourceType.wood), 0);
    expect(bank.getResource(ResourceType.wood), 0);
  });

  test('rejects invalid resource requests', () {
    final bank = BankOfResource();

    expect(bank.getResource(ResourceType.wood, amount: -1), 0);
    expect(bank.getResource(ResourceType.empty), 0);
    expect(bank.getAmount(ResourceType.wood), 19);
    expect(bank.resources.containsKey(ResourceType.empty), isFalse);
  });
}
