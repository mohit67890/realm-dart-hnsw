// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_flutter_vector_db/realm_vector_db.dart';

part 'article.realm.dart';

@RealmModel()
class _Article {
  @PrimaryKey()
  late String id;

  late String title;
  late String content;
  late String category;
  late List<double> embedding;
  late DateTime createdAt;
}
