import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.favorites.isEmpty) {
            return const Center(
              child: Text('No favorites yet'),
            );
          }

          return ListView.builder(
            itemCount: movieProvider.favorites.length,
            itemBuilder: (context, index) {
              return MovieCard(movie: movieProvider.favorites[index]);
            },
          );
        },
      ),
    );
  }
}