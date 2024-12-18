import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/actor_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(bottom: 5, left: 16, right: 16, top: 90),
            color: theme.scaffoldBackgroundColor,
            child: TextField(
              onChanged: (value) {
                context.read<MovieProvider>().searchMoviesAndActors(value);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surface, // Theme-aware background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        theme.colorScheme.primary, // Primary color for outline
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme
                        .secondary, // Secondary color for enabled state
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        theme.colorScheme.primary, // Primary color when focused
                    width: 2,
                  ),
                ),
                prefixIcon:
                    Icon(Icons.search, color: theme.colorScheme.primary),
                hintText: 'Search...',
                hintStyle:
                    TextStyle(color: theme.hintColor), // Theme-aware hint color
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                Consumer<MovieProvider>(
                  builder: (context, movieProvider, child) {
                    if (movieProvider.isLoading) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    // When no search input or results
                    if (movieProvider.movies.isEmpty &&
                        movieProvider.actors.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          // Center the content vertically
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Center horizontally
                            children: [
                              // Lottie animation
                              SizedBox(
                                height: 200,
                                child: Lottie.asset(
                                  'assets/animations/Animation - 1732546509473.json',
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Placeholder text
                              const Text(
                                'Search for a movie or actor',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Display movies and actors
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        if (movieProvider.movies.isNotEmpty) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: movieProvider.movies.length,
                            itemBuilder: (context, index) {
                              return MovieCard(
                                  movie: movieProvider.movies[index]);
                            },
                          ),
                        ],
                        if (movieProvider.actors.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Actors',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: movieProvider.actors.length,
                            itemBuilder: (context, index) {
                              return ActorCard(
                                  actor: movieProvider.actors[index]);
                            },
                          ),
                        ],
                      ]),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
