import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
        centerTitle: true, // Center the AppBar title
        title: const Text('Search History'),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie animation
                  SizedBox(
                    height: 200,
                    child: Lottie.asset(
                        'assets/animations/Animation - 1732546509473.json'),
                  ),
                  const SizedBox(height: 20),
                  // Placeholder text
                  const Text(
                    'Search for movies',
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
