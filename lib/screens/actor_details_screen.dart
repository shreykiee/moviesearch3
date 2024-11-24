import 'package:flutter/material.dart';
import '../models/actor.dart';
import '../services/api_service.dart';
import '../widgets/movie_list.dart';

class ActorDetailsScreen extends StatefulWidget {
  final Actor actor;

  const ActorDetailsScreen({super.key, required this.actor});

  @override
  State<ActorDetailsScreen> createState() => _ActorDetailsScreenState();
}

class _ActorDetailsScreenState extends State<ActorDetailsScreen> {
  late Future<Map<String, dynamic>> _actorDetails;

  @override
  void initState() {
    super.initState();
    _actorDetails = ApiService().getActorDetails(widget.actor.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'actor-${widget.actor.id}',
                child: widget.actor.imageUrl != null
                    ? Image.network(
                        widget.actor.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.grey),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.actor.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (widget.actor.knownFor != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Known for: ${widget.actor.knownFor}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _actorDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Text('No data available');
                      }

                      final details = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biography',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(details['biography'] ?? 'No biography available'),
                          const SizedBox(height: 16),
                          Text(
                            'Filmography',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          MovieList(movies: details['movies'] ?? []),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}