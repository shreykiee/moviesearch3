import 'package:flutter/material.dart';
import 'package:movie_search_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.movies.isEmpty) {
            return const Center(
              child: Text('Search for movies'),
            );
          }

          return ListView.builder(
            itemCount: movieProvider.movies.length,
            itemBuilder: (context, index) {
              return MovieCard(movie: movieProvider.movies[index]);
            },
          );
        },
      ),
    );
  }
}
