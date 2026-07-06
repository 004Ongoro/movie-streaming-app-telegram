import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/movie_repository.dart';
import '../domain/movie_model.dart';

// Movie repo
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository();
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

// Category
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getCategories();
});

// Movies
final moviesListProvider = FutureProvider<List<MovieModel>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isNotEmpty) {
    return repo.searchMovies(query);
  } else if (category != 'All') {
    return repo.getMoviesByCategory(category);
  } else {
    return repo.getMovies();
  }
});
