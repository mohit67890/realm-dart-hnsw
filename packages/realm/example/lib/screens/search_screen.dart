// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import '../models/article.dart';
import '../services/realm_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _realmService = RealmService.instance;
  List<Article> _sourceArticles = [];
  Article? _selectedArticle;
  List<VectorSearchResult<Article>>? _searchResults;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _sourceArticles = _realmService.getAllArticles();
  }

  void _performSearch(Article article) async {
    setState(() {
      _selectedArticle = article;
      _isSearching = true;
      _searchResults = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final results = _realmService.searchSimilar(
      article.embedding,
      limit: 5,
    );

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semantic Search'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildSourceList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceList() {
    final categories = _realmService.getCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select an Article',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find similar articles',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final articles = _realmService.getArticlesByCategory(category);
              return ExpansionTile(
                title: Text(category),
                leading: Icon(_getCategoryIcon(category)),
                initiallyExpanded: index == 0,
                children: articles.map((article) {
                  final isSelected = _selectedArticle?.id == article.id;
                  return ListTile(
                    selected: isSelected,
                    title: Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      article.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _performSearch(article),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle)
                        : null,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_selectedArticle == null) {
      return _buildEmptyState(
        icon: Icons.touch_app,
        title: 'Select an Article',
        message: 'Choose an article from the list to find similar content',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Text(
                    'Query Article',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(_selectedArticle!.category),
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedArticle!.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedArticle!.content,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No Results',
        message: 'No similar articles found',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final result = _searchResults![index];
        final article = result.object;
        final similarity = (1 - result.distance) * 100; // Convert distance to similarity %

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSimilarityColor(similarity).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${similarity.toStringAsFixed(1)}% match',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getSimilarityColor(similarity),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(article.category),
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    if (index == 0)
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Distance: ${result.distance.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'AI & ML':
        return Icons.psychology;
      case 'Mobile Dev':
        return Icons.phone_android;
      case 'Web Dev':
        return Icons.web;
      case 'Databases':
        return Icons.storage;
      case 'Cloud':
        return Icons.cloud;
      default:
        return Icons.article;
    }
  }

  Color _getSimilarityColor(double similarity) {
    if (similarity >= 90) return Colors.green;
    if (similarity >= 70) return Colors.blue;
    if (similarity >= 50) return Colors.orange;
    return Colors.red;
  }
}
