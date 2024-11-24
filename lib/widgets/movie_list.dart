import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../screens/movie_details_screen.dart';

class MovieList extends StatelessWidget {
  final List<Map<String, dynamic>> movies;

  const MovieList({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = Movie(
            id: movies[index]['id'],
            title: movies[index]['title'],
            imageUrl: movies[index]['imageUrl'],
            year: movies[index]['year'],
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(movie: movie),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                children: [
                  if (movie.imageUrl != null)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: movie.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    movie.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (movie.year != null)
                    Text(
                      movie.year!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}