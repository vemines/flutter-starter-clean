import 'package:algoliasearch/algoliasearch_lite.dart';

abstract class AlgoliaService {
  Future<SearchResponse> searchIndex({
    required String indexName,
    required String query,
    required int hitsPerPage,
    required int page,
  });
}

class AlgoliaServiceImpl implements AlgoliaService {
  final SearchClient searchClient;

  AlgoliaServiceImpl({required this.searchClient});

  @override
  Future<SearchResponse> searchIndex({
    required String indexName,
    required String query,
    required int hitsPerPage,
    required int page,
  }) async {
    final queryHits = SearchForHits(
      indexName: indexName,
      query: query,
      hitsPerPage: hitsPerPage,
      page: page,
    );

    final response = await searchClient.searchIndex(request: queryHits);
    return response;
  }
}
