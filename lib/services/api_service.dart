import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  final String _baseUrl = 'https://imdb8.p.rapidapi.com';

  Future<Map<String, dynamic>> getMovieDetails(String movieId) async {
    final responses = await Future.wait([
      _get('/title/v2/get-plot', {'tconst': movieId}),
      _get('/title/v2/get-top-cast-and-crew', {'tconst': movieId}),
      _get('/title/v2/get-genres', {'tconst': movieId}),
    ]);

    final plot = json.decode(responses[0].body);
    final cast = json.decode(responses[1].body);
    final genres = json.decode(responses[2].body);

    return {
      'plot': plot['data']['title']['plot']['plotText']['plainText'],
      'cast': _parseCast(cast),
      'genres': _parseGenres(genres),
    };
  }

  Future<Map<String, dynamic>> getActorDetails(String actorId) async {
    try {
      final responses = await Future.wait([
        _get('/actors/v2/get-bio', {'nconst': actorId}),
        _get('/actors/v2/get-know-for', {'nconst': actorId}),
      ]);

      final bio = json.decode(responses[0].body);
      final knownFor = json.decode(responses[1].body);

      final biography = bio['data']?['name']?['bio']?['text']?['plainText'] ??
          'Biography not available';
      final movies = _parseKnownFor(knownFor);

      return {
        'biography': biography,
        'movies': movies, // Properly typed list
      };
    } catch (e, stackTrace) {
      print('Error fetching actor details: $e');
      print('Stack trace: $stackTrace');
      return {
        'biography': 'Error fetching biography',
        'movies':
            <Map<String, dynamic>>[], // Return empty list if an error occurs
      };
    }
  }

  Future<String?> getMovieTrailerId(String movieId) async {
    try {
      // Make the API request
      final response = await _get(
        '/title/v2/get-',
        // change later to /title/v2/get-auto-start-hero-video-ids
        {'tconst': movieId},
      );

      // Decode the JSON response
      final data = json.decode(response.body);

      // Safely navigate through the response structure
      final edges = data['data']?['title']?['primaryVideos']?['edges'];
      if (edges != null && edges.isNotEmpty) {
        return edges[0]['node']['id'] as String?;
      } else {
        print('No video ID found for movie ID: $movieId');
        return null;
      }
    } catch (e) {
      // Handle and log any errors
      print('Error fetching video ID for movie ID: $movieId. Error: $e');
      return null;
    }
  }

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

  List<Map<String, dynamic>> _parseCast(Map<String, dynamic> data) {
    final credits = data['data']['title']['principalCredits'][2]['credits'];
    return List<Map<String, dynamic>>.from(
      credits.map((credit) => {
            'id': credit['name']['id'],
            'name': credit['name']['nameText']['text'],
            'imageUrl': credit['name']['primaryImage']?['url'],
            'character': credit['characters'][0]['name'],
          }),
    );
  }

  List<String> _parseGenres(Map<String, dynamic> data) {
    final genres = data['data']['title']['titleGenres']['genres'];
    return List<String>.from(
      genres.map((genre) => genre['genre']['text']),
    );
  }

  List<Map<String, dynamic>> _parseKnownFor(Map<String, dynamic> data) {
    final movies = data['data']['name']['knownFor']['edges'];
    return List<Map<String, dynamic>>.from(
      movies.map((movie) => {
            'id': movie['node']['title']['id'],
            'title': movie['node']['title']['titleText']['text'],
            'imageUrl': movie['node']['title']['primaryImage']?['url'],
            'year': movie['node']['title']['releaseYear']?['year']?.toString(),
          }),
    );
  }
}
