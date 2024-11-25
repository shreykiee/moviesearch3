import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Importing Lottie package
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Favorites')),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lottie animation
                  SizedBox(
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/Animation - 1732549233318.json', // Use your own animation path
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Placeholder text
                  const Text(
                    'Add movies or actors to favorites',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
