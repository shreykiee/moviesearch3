import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/cast_list.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<Map<String, dynamic>> _movieDetails;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _movieDetails = ApiService().getMovieDetails(widget.movie.id);
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoId = await ApiService().getMovieTrailerId(widget.movie.id);
    if (videoId != null) {
      final videoUrl = Uri.parse('https://www.imdb.com/video/$videoId');
      _controller = VideoPlayerController.networkUrl(videoUrl)
        ..initialize().then((_) {
          setState(() {});
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
                tag: 'movie-${widget.movie.id}',
                child: widget.movie.imageUrl != null
                    ? Image.network(
                        widget.movie.imageUrl!,
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
                    widget.movie.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (widget.movie.year != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.year!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_controller != null)
                    VideoPlayerWidget(controller: _controller!),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _movieDetails,
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
                            'Plot',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(details['plot'] ?? 'No plot available'),
                          const SizedBox(height: 16),
                          Text(
                            'Cast',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          CastList(cast: details['cast'] ?? []),
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
