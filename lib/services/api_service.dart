import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  final String _baseUrl = 'https://imdb8.p.rapidapi.com';

  // Batch API calls with rate limit handling
  Future<List<http.Response>> _fetchInBatches(
      List<Map<String, dynamic>> endpointsWithParams,
      {int batchSize = 5,
      int delayMs = 200}) async {
    List<http.Response> responses = [];
    for (int i = 0; i < endpointsWithParams.length; i += batchSize) {
      // Create a batch of API calls
      var batch = endpointsWithParams.sublist(
          i,
          (i + batchSize) < endpointsWithParams.length
              ? i + batchSize
              : endpointsWithParams.length);

      // Send API calls concurrently
      List<Future<http.Response>> futures = batch.map((endpointWithParam) {
        final endpoint = endpointWithParam['endpoint'] as String;
        final params = endpointWithParam['params'] as Map<String, String>;
        return _get(endpoint, params);
      }).toList();

      // Wait for all API calls in the batch to complete
      var batchResponses = await Future.wait(futures);

      // Add batch responses to the overall responses list
      responses.addAll(batchResponses);

      // Delay to respect rate limit
      if (batchResponses.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    return responses;
  }

  // Fetch movie details
  Future<Map<String, dynamic>> getMovieDetails(String movieId) async {
    try {
      final endpoints = [
        {
          'endpoint': '/title/v2/get-plot',
          'params': {'tconst': movieId}
        },
        {
          'endpoint': '/title/v2/get-top-cast-and-crew',
          'params': {'tconst': movieId}
        },
        {
          'endpoint': '/title/v2/get-genres',
          'params': {'tconst': movieId}
        },
        {
          'endpoint': '/title/v2/get-awards-summary',
          'params': {'tconst': movieId}
        },
        {
          'endpoint': '/title/v2/get-critics-review-summary',
          'params': {'tconst': movieId}
        },
        {
          'endpoint': '/title/v2/get-box-office-summary',
          'params': {'tconst': movieId}
        },
        {
          'endpoint': '/title/v2/get-ratings',
          'params': {'tconst': movieId}
        },
      ];

      final responses = await _fetchInBatches(endpoints);
      final plot = _safeDecode(responses[0]);
      final cast = _safeDecode(responses[1]);
      final genres = _safeDecode(responses[2]);
      final awards = _safeDecode(responses[3]);
      final reviews = _safeDecode(responses[4]);
      final boxOffice = _safeDecode(responses[5]);
      final ratings = _safeDecode(responses[6]);

      return {
        'plot': plot['data']?['title']?['plot']?['plotText']?['plainText'] ??
            'Plot not available',
        'cast': _parseCast(cast),
        'genres': _parseGenres(genres),
        'awards': _parseAwards(awards),
        'reviews': _parseReviews(reviews),
        'boxOffice': _parseBoxOffice(boxOffice),
        'ratings': _parseRatings(ratings),
      };
    } catch (e) {
      print('Error fetching movie details: $e');
      return _errorFallback();
    }
  }

  // Fetch actor details
  Future<Map<String, dynamic>> getActorDetails(String actorId) async {
    try {
      final endpoints = [
        {
          'endpoint': '/actors/v2/get-bio',
          'params': {'nconst': actorId}
        },
        {
          'endpoint': '/actors/v2/get-know-for',
          'params': {'nconst': actorId}
        },
      ];

      final responses = await _fetchInBatches(endpoints);
      final bio = _safeDecode(responses[0]);
      final knownFor = _safeDecode(responses[1]);

      return {
        'biography': bio['data']?['name']?['bio']?['text']?['plainText'] ??
            'Biography not available',
        'movies': _parseKnownFor(knownFor),
      };
    } catch (e) {
      print('Error fetching actor details: $e');
      return {
        'biography': 'Error fetching biography',
        'movies': [],
      };
    }
  }

  // General GET request
  Future<http.Response> _get(
      String endpoint, Map<String, String> params) async {
    final uri =
        Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);
    return await http.get(
      uri,
      headers: {
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': 'imdb8.p.rapidapi.com',
      },
    );
  }

  // Safe JSON decoding
  dynamic _safeDecode(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      print('Error decoding JSON: $e');
      return {};
    }
  }

  // Error fallback for movie details
  Map<String, dynamic> _errorFallback() => {
        'plot': 'Error fetching plot',
        'cast': [],
        'genres': [],
        'awards': {},
        'reviews': [],
        'boxOffice': {},
        'ratings': {},
      };

  // Parsing helpers
  List<Map<String, dynamic>> _parseCast(Map<String, dynamic> data) {
    final credits =
        data['data']?['title']?['principalCredits']?[2]?['credits'] ?? [];
    // Ensure that credits is a List and map it properly
    if (credits is List) {
      return credits
          .map<Map<String, dynamic>>((credit) => {
                'id': credit['name']?['id'] ?? 'Unknown',
                'name': credit['name']?['nameText']?['text'] ?? 'Unknown',
                'imageUrl': credit['name']?['primaryImage']?['url'],
                'character': credit['characters']?.first?['name'] ?? 'Unknown',
              })
          .toList();
    } else {
      return [];
    }
  }

  List<String> _parseGenres(Map<String, dynamic> data) {
    final genres = data['data']?['title']?['titleGenres']?['genres'] ?? [];
    // Ensure that genres is a List
    if (genres is List) {
      return genres
          .map<String>((genre) => genre['genre']?['text'] ?? 'Unknown')
          .toList();
    } else {
      return [];
    }
  }

  Map<String, dynamic> _parseAwards(dynamic data) {
    final awards = data['data']?['title'] ?? {};
    return {
      'oscarWins': awards['prestigiousAwardSummary']?['wins'] ?? 0,
      'oscarNominations':
          awards['prestigiousAwardSummary']?['nominations'] ?? 0,
      'totalWins': awards['totalWins']?['total'] ?? 0,
      'totalNominations': awards['totalNominations']?['total'] ?? 0,
    };
  }

  List<Map<String, dynamic>> _parseReviews(Map<String, dynamic> data) {
    final reviews =
        data['data']?['title']?['metacritic']?['reviews']?['edges'] ?? [];

    // Check if reviews are null or empty and return an empty list if so
    if (reviews is! List) {
      return [];
    }

    return reviews.map<Map<String, dynamic>>((review) {
      return {
        'quote': review['node']?['quote']?['value'] ?? 'No quote available',
        'reviewer': review['node']?['reviewer'] ?? 'Anonymous',
        'score': review['node']?['score'] ?? 'N/A',
        'site': review['node']?['site'] ?? 'N/A',
        'url': review['node']?['url'] ?? '',
      };
    }).toList();
  }

  Map<String, dynamic> _parseBoxOffice(dynamic data) {
    final title = data['data']?['title'] ?? {};
    return {
      'budget': title['budget']?['totalBudget']?['amount'] ?? 'N/A',
      'openingWeekend': title['openingWeekendGrosses']?['edges']?.first?['node']
              ?['gross']?['total']?['amount'] ??
          'N/A',
      'domesticGross': title['domesticGross']?['total']?['amount'] ?? 'N/A',
      'worldwideGross': title['worldwideGross']?['total']?['amount'] ?? 'N/A',
    };
  }

  List<Map<String, dynamic>> _parseKnownFor(dynamic data) {
    final movies = data['data']['name']['knownFor']['edges'] ?? [];
    // Ensure that movies is a List and map it properly
    if (movies is List) {
      return movies
          .map<Map<String, dynamic>>((movie) => {
                'id': movie['node']['title']['id'],
                'title': movie['node']['title']['titleText']['text'],
                'imageUrl': movie['node']['title']['primaryImage']?['url'],
                'year':
                    movie['node']['title']['releaseYear']?['year']?.toString(),
              })
          .toList();
    } else {
      return [];
    }
  }

  Map<String, dynamic> _parseRatings(Map<String, dynamic> data) {
    final ratings = data['data']?['title'] ?? {};
    return {
      'imdb': ratings['rating']?['average']?.toString() ?? 'N/A',
      'metacritic': ratings['metacritic']?['score']?.toString() ?? 'N/A',
      'rottenTomatoes':
          ratings['rottenTomatoes']?['score']?.toString() ?? 'N/A',
    };
  }
}
