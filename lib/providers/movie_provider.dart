import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../models/actor.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> _movies = [];
  List<Actor> _actors = [];
  List<Movie> _favorites = [];
  bool _isLoading = false;

  List<Movie> get movies => _movies;
  List<Actor> get actors => _actors;
  List<Movie> get favorites => _favorites;
  bool get isLoading => _isLoading;

  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  final String _baseUrl = 'https://imdb8.p.rapidapi.com';

  Future<void> searchMoviesAndActors(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auto-complete?q=$query'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'imdb8.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _movies = [];
        _actors = [];

        for (var item in data['d']) {
          if (item['qid'] == 'movie' || item['qid'] == 'tvSeries') {
            _movies.add(Movie.fromJson(item));
          } else if (item['qid'] == 'name') {
            _actors.add(Actor.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(Movie movie) async {
    final isExist = _favorites.contains(movie);
    if (isExist) {
      _favorites.remove(movie);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _favorites.map((movie) => movie.toJson()).toList(),
    );
    await prefs.setString('favorites', encodedData);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('favorites');

    if (favoritesString != null) {
      final List<dynamic> decodedData = json.decode(favoritesString);
      _favorites = decodedData.map((item) => Movie.fromJson(item)).toList();
      notifyListeners();
    }
  }
}
