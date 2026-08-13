import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/index_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/domain/entities/index_entity.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late IndexRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    repository = IndexRepositoryImpl(mockApiClient);
  });

  RequestOptions options(String path) => RequestOptions(path: path);

  group('IndexRepositoryImpl.indexItem', () {
    test('POSTs to /index and returns the entity from the response', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {
              'success': true,
              'message': 'ok',
              'items': [
                {'id': 'item-1', 'data': {'title': 'Example Product'}},
              ],
            },
            statusCode: 200,
            requestOptions: options('/index'),
          ));

      final item = IndexEntity(id: 'item-1', data: {'title': 'Example Product'});
      final result = await repository.indexItem(item);

      expect(result.id, 'item-1');
      expect(result.data['title'], 'Example Product');

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
      )).captured;
      expect(captured[0], '/index');
      expect(captured[1], {
        'items': [
          {'id': 'item-1', 'data': {'title': 'Example Product'}},
        ],
      });
    });

    test('throws when the response reports failure', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {'success': false, 'message': 'quota exceeded'},
            statusCode: 200,
            requestOptions: options('/index'),
          ));

      await expectLater(
        repository.indexItem(IndexEntity(id: 'item-1', data: const {})),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('IndexRepositoryImpl.indexBatch', () {
    test('POSTs to /index/batch with every item', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {
              'success': true,
              'message': 'ok',
              'items': [
                {'id': '1', 'data': {'title': 'A'}},
                {'id': '2', 'data': {'title': 'B'}},
              ],
            },
            statusCode: 200,
            requestOptions: options('/index/batch'),
          ));

      final items = [
        IndexEntity(id: '1', data: {'title': 'A'}),
        IndexEntity(id: '2', data: {'title': 'B'}),
      ];
      final result = await repository.indexBatch(items);

      expect(result.length, 2);
      expect(result.map((e) => e.id), ['1', '2']);

      verify(mockApiClient.post(
        '/index/batch',
        data: {
          'items': [
            {'id': '1', 'data': {'title': 'A'}},
            {'id': '2', 'data': {'title': 'B'}},
          ],
        },
      )).called(1);
    });
  });

  group('IndexRepositoryImpl.updateItem', () {
    test('PUTs to /index/{id} with operation "update"', () async {
      when(mockApiClient.put(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {
              'success': true,
              'message': 'ok',
              'items': [
                {'id': 'item-1', 'data': {'title': 'Updated'}},
              ],
            },
            statusCode: 200,
            requestOptions: options('/index/item-1'),
          ));

      final result = await repository.updateItem(
        IndexEntity(id: 'item-1', data: {'title': 'Updated'}),
      );

      expect(result.data['title'], 'Updated');

      verify(mockApiClient.put(
        '/index/item-1',
        data: {
          'items': [
            {'id': 'item-1', 'data': {'title': 'Updated'}},
          ],
          'operation': 'update',
        },
      )).called(1);
    });
  });

  group('IndexRepositoryImpl.deleteItem', () {
    test('DELETEs /index/{id}', () async {
      when(mockApiClient.delete(any)).thenAnswer(
        (_) async => Response<dynamic>(
          data: null,
          statusCode: 200,
          requestOptions: options('/index/item-1'),
        ),
      );

      await repository.deleteItem('item-1');

      verify(mockApiClient.delete('/index/item-1')).called(1);
    });

    test('propagates errors from the API client', () async {
      when(mockApiClient.delete(any)).thenThrow(Exception('not found'));

      await expectLater(
        repository.deleteItem('missing'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
