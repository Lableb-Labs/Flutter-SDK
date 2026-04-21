import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/index_repository_impl.dart';
import 'dart:convert';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late IndexRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    when(mockApiClient.apiKeyIndex).thenReturn('index-key');
    repository = IndexRepositoryImpl(mockApiClient);
  });

  group('IndexRepositoryImpl', () {
    final requestOptions = RequestOptions(path: '/documents');

    test('uploadDocuments sends correct payload', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {},
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final documents = [
        {'id': '1', 'title': 'Doc 1'},
        {'id': '2', 'title': 'Doc 2'},
      ];

      await repository.uploadDocuments(documents);

      verify(mockApiClient.post(
        '/documents',
        data: jsonEncode(documents),
        queryParameters: {'apikey': 'index-key'},
      )).called(1);
    });

    test('removeDocuments sends correct payload', () async {
      when(mockApiClient.delete(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {},
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final documentIds = ['1', '2'];

      await repository.removeDocuments(documentIds);

      verify(mockApiClient.delete(
        '/documents',
        data: jsonEncode(documentIds),
        queryParameters: {'apikey': 'index-key'},
      )).called(1);
    });
  });
}
