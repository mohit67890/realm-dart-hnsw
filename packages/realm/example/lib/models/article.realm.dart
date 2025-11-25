// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Article extends _Article with RealmEntity, RealmObjectBase, RealmObject {
  Article(
    String id,
    String title,
    String content,
    String category,
    DateTime createdAt, {
    Iterable<double> embedding = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'content', content);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set<RealmList<double>>(
        this, 'embedding', RealmList<double>(embedding));
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  Article._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get content => RealmObjectBase.get<String>(this, 'content') as String;
  @override
  set content(String value) => RealmObjectBase.set(this, 'content', value);

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  RealmList<double> get embedding =>
      RealmObjectBase.get<double>(this, 'embedding') as RealmList<double>;
  @override
  set embedding(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  Stream<RealmObjectChanges<Article>> get changes =>
      RealmObjectBase.getChanges<Article>(this);

  @override
  Stream<RealmObjectChanges<Article>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Article>(this, keyPaths);

  @override
  Article freeze() => RealmObjectBase.freezeObject<Article>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'content': content.toEJson(),
      'category': category.toEJson(),
      'embedding': embedding.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Article value) => value.toEJson();
  static Article _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'content': EJsonValue content,
        'category': EJsonValue category,
        'createdAt': EJsonValue createdAt,
      } =>
        Article(
          fromEJson(id),
          fromEJson(title),
          fromEJson(content),
          fromEJson(category),
          fromEJson(createdAt),
          embedding: fromEJson(ejson['embedding']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Article._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Article, 'Article', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('content', RealmPropertyType.string),
      SchemaProperty('category', RealmPropertyType.string),
      SchemaProperty('embedding', RealmPropertyType.double,
          collectionType: RealmCollectionType.list),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
