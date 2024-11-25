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
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          theme.colorScheme.background, // Ensure the background matches theme
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: textTheme.titleLarge?.copyWith(
                  color: isDarkMode
                      ? Colors.white // In dark mode, use white text
                      : Colors.black, // In light mode, use black text
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: 'movie-${widget.movie.id}',
                child: widget.movie.imageUrl != null
                    ? Image.network(
                        widget.movie.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(color: theme.dividerColor),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<Map<String, dynamic>>(
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
                      Row(
                        children: [
                          if (widget.movie.year != null)
                            Chip(
                              label: Text(
                                widget.movie.year!,
                                style: TextStyle(
                                  color: theme.cardColor,
                                ),
                              ),
                              backgroundColor: theme.primaryColorLight,
                            ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              details['rating'] ?? 'N/A',
                              style: TextStyle(
                                color: theme.cardColor,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (details['plot'] != null)
                        _buildSection(
                          context,
                          title: '',
                          content: details['plot'],
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ),
                      // const SizedBox(height: 16),
                      // if (details['trailer'] != null)
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         'Trailer',
                      //         style: textTheme.titleLarge?.copyWith(
                      //           fontWeight: FontWeight.bold,
                      //           color: isDarkMode ? Colors.white : Colors.black,
                      //         ),
                      //       ),
                      //       const SizedBox(height: 8),
                      //       VideoPlayerWidget(controller: _controller!),
                      //     ],
                      //   ),

                      const SizedBox(height: 16),
                      if (details['genres'] != null)
                        _buildSection(
                          context,
                          title: 'Genres',
                          contentWidget: Wrap(
                            spacing: 8.0,
                            children: details['genres']
                                .map<Widget>(
                                  (genre) => Chip(
                                    label: Text(
                                      genre,
                                      style: TextStyle(
                                        color: theme.cardColor,
                                      ),
                                    ),
                                    backgroundColor: theme.primaryColorLight,
                                  ),
                                )
                                .toList(),
                          ),
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ),
                      const SizedBox(height: 16),
                      if (details['cast'] != null)
                        _buildSection(
                          context,
                          title: 'Cast',
                          contentWidget: CastList(cast: details['cast']),
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ),
                      const SizedBox(height: 16),
                      if (details['awards'] != null)
                        _buildSection(
                          context,
                          title: 'Awards',
                          content:
                              'Oscar Wins: ${details['awards']['oscarWins']}\n'
                              'Oscar Nominations: ${details['awards']['oscarNominations']}\n'
                              'Total Wins: ${details['awards']['totalWins']}\n'
                              'Total Nominations: ${details['awards']['totalNominations']}',
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ),
                      const SizedBox(height: 16),
                      if (details['reviews'] != null)
                        _buildSection(
                          context,
                          title: 'Reviews',
                          contentWidget: SingleChildScrollView(
                            child: Column(
                              children:
                                  details['reviews'].map<Widget>((review) {
                                return ListTile(
                                  title: Text(
                                      review['quote'] ?? 'No quote available',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                  subtitle: Text(
                                      '${review['reviewer']} (${review['site']})',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                  trailing: Text('${review['score']}',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                );
                              }).toList(),
                            ),
                          ),
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ),
                      const SizedBox(height: 16),
                      if (details['boxOffice'] != null)
                        _buildSection(
                          context,
                          title: 'Box Office',
                          content: 'Budget: ${details['boxOffice']['budget']}\n'
                              'Opening Weekend: ${details['boxOffice']['openingWeekend']}\n'
                              'Domestic Gross: ${details['boxOffice']['domesticGross']}\n'
                              'Worldwide Gross: ${details['boxOffice']['worldwideGross']}',
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ),
                      const SizedBox(height: 16),
                      if (details['ratings'] != null)
                        _buildSection(
                          context,
                          title: 'Ratings',
                          content:
                              'Metascore: ${details['ratings']['metascore']}\n'
                              'Review Count: ${details['ratings']['reviewCount']}\n'
                              'Top Ranking: ${details['ratings']['topRanking']}',
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ),
                      const SizedBox(height: 16),
                      _buildAdditionalDetails(details, textTheme, isDarkMode),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    String? content,
    Widget? contentWidget,
    required TextTheme textTheme,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity, // Makes the card take all available width
      margin:
          const EdgeInsets.symmetric(vertical: 2.0), // Adds space between cards
      child: Card(
        elevation: 4.0, // Adds shadow effect to make it look like a card
        color: isDarkMode
            ? Colors.black54
            : Colors.white, // Card color based on theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              content != null
                  ? Text(
                      content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    )
                  : contentWidget ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails(
      Map<String, dynamic> details, TextTheme textTheme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Language: ${details['language'] ?? 'N/A'}',
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Country: ${details['country'] ?? 'N/A'}',
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
