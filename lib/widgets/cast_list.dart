import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/actor_details_screen.dart';
import '../models/actor.dart';

class CastList extends StatelessWidget {
  final List<Map<String, dynamic>> cast;

  const CastList({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final actor = Actor(
            id: cast[index]['id'],
            name: cast[index]['name'],
            imageUrl: cast[index]['imageUrl'],
            knownFor: cast[index]['character'],
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActorDetailsScreen(actor: actor),
                ),
              );
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                children: [
                  if (actor.imageUrl != null)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: actor.imageUrl!,
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
                    actor.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
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