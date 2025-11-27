// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_flutter_vector_db/realm_vector_db.dart';
import '../models/article.dart';

class RealmService {
  static RealmService? _instance;
  late Realm _realm;

  RealmService._() {
    final config = Configuration.local(
      [Article.schema],
      schemaVersion: 1,
      shouldDeleteIfMigrationNeeded: true,
    );
    _realm = Realm(config);
  }

  static RealmService get instance {
    _instance ??= RealmService._();
    return _instance!;
  }

  Realm get realm => _realm;

  // Initialize with sample data
  Future<void> initializeSampleData() async {
    if (_realm.all<Article>().isNotEmpty) {
      return; // Already initialized
    }

    final sampleArticles = [
      {
        'id': 'ai-1',
        'title': 'Introduction to Machine Learning',
        'content': 'Machine learning is a subset of artificial intelligence that enables systems to learn and improve from experience. It uses algorithms to identify patterns in data.',
        'category': 'AI & ML',
        'embedding': [0.9, 0.8, 0.1, 0.2, 0.15],
      },
      {
        'id': 'ai-2',
        'title': 'Deep Learning Neural Networks',
        'content': 'Neural networks are computing systems inspired by biological neural networks. Deep learning uses multiple layers to progressively extract higher-level features.',
        'category': 'AI & ML',
        'embedding': [0.85, 0.82, 0.12, 0.18, 0.14],
      },
      {
        'id': 'ai-3',
        'title': 'Natural Language Processing Guide',
        'content': 'NLP enables computers to understand, interpret and generate human language. Applications include chatbots, translation, and sentiment analysis.',
        'category': 'AI & ML',
        'embedding': [0.88, 0.79, 0.15, 0.19, 0.16],
      },
      {
        'id': 'mobile-1',
        'title': 'Flutter Cross-Platform Development',
        'content': 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase using Dart.',
        'category': 'Mobile Dev',
        'embedding': [0.2, 0.15, 0.9, 0.85, 0.12],
      },
      {
        'id': 'mobile-2',
        'title': 'iOS App Development with Swift',
        'content': 'Swift is a powerful programming language for iOS, macOS, watchOS, and tvOS. It provides modern features for building robust and efficient apps.',
        'category': 'Mobile Dev',
        'embedding': [0.18, 0.12, 0.88, 0.87, 0.11],
      },
      {
        'id': 'mobile-3',
        'title': 'Android Kotlin Best Practices',
        'content': 'Kotlin is the preferred language for Android development. It offers concise syntax, null safety, and seamless Java interoperability.',
        'category': 'Mobile Dev',
        'embedding': [0.19, 0.14, 0.89, 0.86, 0.13],
      },
      {
        'id': 'web-1',
        'title': 'React Modern Web Development',
        'content': 'React is a JavaScript library for building user interfaces. It uses a component-based architecture and virtual DOM for efficient rendering.',
        'category': 'Web Dev',
        'embedding': [0.12, 0.2, 0.15, 0.18, 0.9],
      },
      {
        'id': 'web-2',
        'title': 'Vue.js Progressive Framework',
        'content': 'Vue.js is a progressive framework for building user interfaces. It is designed to be incrementally adoptable and integrates well with other libraries.',
        'category': 'Web Dev',
        'embedding': [0.13, 0.19, 0.16, 0.17, 0.88],
      },
      {
        'id': 'web-3',
        'title': 'Node.js Backend Development',
        'content': 'Node.js is a JavaScript runtime built on Chrome\'s V8 engine. It enables building scalable network applications with event-driven, non-blocking I/O.',
        'category': 'Web Dev',
        'embedding': [0.14, 0.21, 0.14, 0.19, 0.89],
      },
      {
        'id': 'db-1',
        'title': 'MongoDB NoSQL Database Guide',
        'content': 'MongoDB is a document-oriented NoSQL database. It stores data in flexible, JSON-like documents and scales horizontally across servers.',
        'category': 'Databases',
        'embedding': [0.15, 0.9, 0.2, 0.85, 0.18],
      },
      {
        'id': 'db-2',
        'title': 'PostgreSQL Relational Database',
        'content': 'PostgreSQL is a powerful open-source relational database. It supports advanced data types, full ACID compliance, and complex queries.',
        'category': 'Databases',
        'embedding': [0.16, 0.88, 0.19, 0.86, 0.17],
      },
      {
        'id': 'db-3',
        'title': 'Redis In-Memory Data Store',
        'content': 'Redis is an in-memory data structure store used as a database, cache, and message broker. It supports various data structures like strings, hashes, and lists.',
        'category': 'Databases',
        'embedding': [0.17, 0.89, 0.21, 0.84, 0.19],
      },
      {
        'id': 'cloud-1',
        'title': 'AWS Cloud Computing Platform',
        'content': 'Amazon Web Services provides on-demand cloud computing platforms and APIs. Services include compute, storage, databases, and machine learning.',
        'category': 'Cloud',
        'embedding': [0.85, 0.18, 0.82, 0.2, 0.15],
      },
      {
        'id': 'cloud-2',
        'title': 'Docker Container Technology',
        'content': 'Docker enables packaging applications into containers. Containers are lightweight, standalone executables that include everything needed to run software.',
        'category': 'Cloud',
        'embedding': [0.86, 0.19, 0.83, 0.19, 0.16],
      },
      {
        'id': 'cloud-3',
        'title': 'Kubernetes Orchestration',
        'content': 'Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications across clusters.',
        'category': 'Cloud',
        'embedding': [0.84, 0.17, 0.84, 0.21, 0.14],
      },
    ];

    _realm.write(() {
      for (var data in sampleArticles) {
        _realm.add(Article(
          data['id'] as String,
          data['title'] as String,
          data['content'] as String,
          data['category'] as String,
          DateTime.now(),
          embedding: (data['embedding'] as List).cast<double>(),
        ));
      }
    });
  }

  // Create vector index
  Future<void> createVectorIndex() async {
    if (_realm.hasVectorIndex<Article>('embedding')) {
      return; // Index already exists
    }

    _realm.write(() {
      _realm.createVectorIndex<Article>(
        'embedding',
        metric: VectorDistanceMetric.cosine,
        m: 16,
        efConstruction: 200,
      );
    });
  }

  // Search similar articles
  List<VectorSearchResult<Article>> searchSimilar(
    List<double> queryEmbedding, {
    int limit = 5,
  }) {
    final results = _realm.vectorSearchKnn<Article>(
      'embedding',
      queryVector: queryEmbedding,
      k: limit,
    );
    return results.toList();
  }

  // Get all categories
  List<String> getCategories() {
    final articles = _realm.all<Article>();
    final categories = <String>{};
    for (var article in articles) {
      categories.add(article.category);
    }
    return categories.toList()..sort();
  }

  // Get articles by category
  List<Article> getArticlesByCategory(String category) {
    return _realm.all<Article>().query('category == \$0', [category]).toList();
  }

  // Get all articles
  List<Article> getAllArticles() {
    return _realm.all<Article>().toList();
  }

  // Add new article
  void addArticle(Article article) {
    _realm.write(() {
      _realm.add(article);
    });
  }

  // Delete article
  void deleteArticle(Article article) {
    _realm.write(() {
      _realm.delete(article);
    });
  }

  // Clear all data
  void clearAllData() {
    _realm.write(() {
      if (_realm.hasVectorIndex<Article>('embedding')) {
        _realm.removeVectorIndex<Article>('embedding');
      }
      _realm.deleteAll<Article>();
    });
  }

  void dispose() {
    _realm.close();
  }
}
