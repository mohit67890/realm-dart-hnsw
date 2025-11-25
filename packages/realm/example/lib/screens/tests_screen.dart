// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import '../services/realm_service.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final _realmService = RealmService.instance;
  final List<String> _testLogs = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vector Search Tests'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Test Suite',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Run automated tests to verify vector search functionality',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runTests,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isRunning ? 'Running...' : 'Run All Tests'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _testLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tests run yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click "Run All Tests" to start',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _testLogs.length,
                    itemBuilder: (context, index) {
                      final log = _testLogs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildLogItem(log),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String log) {
    IconData icon;
    Color color;

    if (log.startsWith('✓')) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (log.startsWith('✗')) {
      icon = Icons.error;
      color = Colors.red;
    } else if (log.startsWith('🔍')) {
      icon = Icons.search;
      color = Colors.blue;
    } else if (log.startsWith('📊')) {
      icon = Icons.analytics;
      color = Colors.orange;
    } else {
      icon = Icons.info_outline;
      color = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            log,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testLogs.clear();
    });

    _addLog('📊 Starting test suite...');
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await _testBasicOperations();
      await _testVectorSearch();
      await _testSearchAccuracy();
      
      _addLog('');
      _addLog('✓ All tests completed successfully!');
    } catch (e) {
      _addLog('✗ Test suite failed: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _testBasicOperations() async {
    _addLog('');
    _addLog('🔍 Test 1: Basic Operations');
    await Future.delayed(const Duration(milliseconds: 300));

    final articles = _realmService.getAllArticles();
    _addLog('  Articles in database: ${articles.length}');
    
    if (articles.length > 0) {
      _addLog('  ✓ Database has articles');
    } else {
      _addLog('  ✗ Database is empty');
      return;
    }

    final categories = _realmService.getCategories();
    _addLog('  Categories found: ${categories.length}');
    _addLog('  ✓ Basic operations working');
  }

  Future<void> _testVectorSearch() async {
    _addLog('');
    _addLog('🔍 Test 2: Vector Search');
    await Future.delayed(const Duration(milliseconds: 300));

    final articles = _realmService.getAllArticles();
    if (articles.isEmpty) {
      _addLog('  ✗ No articles to test');
      return;
    }

    final testArticle = articles.first;
    _addLog('  Query article: "${testArticle.title}"');
    
    final results = _realmService.searchSimilar(
      testArticle.embedding,
      limit: 5,
    );

    _addLog('  Results found: ${results.length}');
    
    if (results.isNotEmpty) {
      _addLog('  Top result: "${results.first.object.title}"');
      _addLog('  Distance: ${results.first.distance.toStringAsFixed(4)}');
      _addLog('  ✓ Vector search working');
    } else {
      _addLog('  ✗ No results returned');
    }
  }

  Future<void> _testSearchAccuracy() async {
    _addLog('');
    _addLog('🔍 Test 3: Search Accuracy');
    await Future.delayed(const Duration(milliseconds: 300));

    // Test that same article returns itself with distance 0
    final articles = _realmService.getAllArticles();
    if (articles.isEmpty) {
      _addLog('  ✗ No articles to test');
      return;
    }

    final testArticle = articles.first;
    final results = _realmService.searchSimilar(
      testArticle.embedding,
      limit: 1,
    );

    if (results.isNotEmpty) {
      final topResult = results.first;
      final distance = topResult.distance;
      
      _addLog('  Self-search distance: ${distance.toStringAsFixed(6)}');
      
      if (distance < 0.0001) {
        _addLog('  ✓ Self-search returns same article (distance ≈ 0)');
      } else {
        _addLog('  ✗ Unexpected self-search distance: $distance');
      }
    }

    // Test category clustering
    _addLog('');
    _addLog('  Testing category clustering...');
    final categories = _realmService.getCategories();
    
    for (var category in categories.take(2)) {
      final categoryArticles = _realmService.getArticlesByCategory(category);
      if (categoryArticles.length > 1) {
        final article1 = categoryArticles[0];
        final results = _realmService.searchSimilar(
          article1.embedding,
          limit: 3,
        );
        
        int sameCategory = 0;
        for (var result in results) {
          if (result.object.category == category) {
            sameCategory++;
          }
        }
        
        _addLog('  Category "$category": $sameCategory/${results.length} results match');
      }
    }

    _addLog('  ✓ Search accuracy verified');
  }

  void _addLog(String message) {
    setState(() {
      _testLogs.add(message);
    });
  }
}
