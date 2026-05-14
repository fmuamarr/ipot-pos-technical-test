import 'package:flutter_test/flutter_test.dart';
import 'package:ipot_pos/domain/entities/order_entity.dart';

void main() {
  group('OrderStatus.fromString', () {
    test('parses known status strings', () {
      expect(OrderStatusExtension.fromString('pending'), OrderStatus.pending);
      expect(
        OrderStatusExtension.fromString('confirmed'),
        OrderStatus.confirmed,
      );
      expect(
        OrderStatusExtension.fromString('preparing'),
        OrderStatus.preparing,
      );
      expect(OrderStatusExtension.fromString('ready'), OrderStatus.ready);
      expect(OrderStatusExtension.fromString('served'), OrderStatus.served);
    });

    test('returns unknown for unrecognized strings', () {
      expect(OrderStatusExtension.fromString('cancelled'), OrderStatus.unknown);
      expect(OrderStatusExtension.fromString(''), OrderStatus.unknown);
    });

    test('is case-insensitive', () {
      expect(OrderStatusExtension.fromString('PENDING'), OrderStatus.pending);
      expect(
        OrderStatusExtension.fromString('Preparing'),
        OrderStatus.preparing,
      );
    });
  });

  group('OrderStatus.displayName', () {
    test('returns correct display names', () {
      expect(OrderStatus.pending.displayName, equals('Pending'));
      expect(OrderStatus.confirmed.displayName, equals('Confirmed'));
      expect(OrderStatus.preparing.displayName, equals('Preparing'));
      expect(OrderStatus.ready.displayName, equals('Ready'));
      expect(OrderStatus.served.displayName, equals('Served'));
      expect(OrderStatus.unknown.displayName, equals('Unknown'));
    });
  });

  group('OrderEntity', () {
    test('constructs with required fields', () {
      const entity = OrderEntity(
        id: 'ORD-001',
        tableId: 'T001',
        status: OrderStatus.pending,
      );
      expect(entity.id, equals('ORD-001'));
      expect(entity.tableId, equals('T001'));
      expect(entity.status, equals(OrderStatus.pending));
      expect(entity.estimatedTime, isNull);
    });

    test('constructs with optional fields', () {
      final now = DateTime.now();
      final entity = OrderEntity(
        id: 'ORD-002',
        tableId: 'T002',
        status: OrderStatus.preparing,
        estimatedTime: '15 minutes',
        createdAt: now,
      );
      expect(entity.estimatedTime, equals('15 minutes'));
      expect(entity.createdAt, equals(now));
    });
  });
}
