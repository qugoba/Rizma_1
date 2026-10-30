// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_dao.dart';

// ignore_for_file: type=lint
mixin _$ContentDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContentManifestsTable get contentManifests =>
      attachedDatabase.contentManifests;
  $ContentLessonsTable get contentLessons => attachedDatabase.contentLessons;
  $ContentBlobsTable get contentBlobs => attachedDatabase.contentBlobs;
  $ContentDownloadsTable get contentDownloads =>
      attachedDatabase.contentDownloads;
  ContentDaoManager get managers => ContentDaoManager(this);
}

class ContentDaoManager {
  final _$ContentDaoMixin _db;
  ContentDaoManager(this._db);
  $$ContentManifestsTableTableManager get contentManifests =>
      $$ContentManifestsTableTableManager(
        _db.attachedDatabase,
        _db.contentManifests,
      );
  $$ContentLessonsTableTableManager get contentLessons =>
      $$ContentLessonsTableTableManager(
        _db.attachedDatabase,
        _db.contentLessons,
      );
  $$ContentBlobsTableTableManager get contentBlobs =>
      $$ContentBlobsTableTableManager(_db.attachedDatabase, _db.contentBlobs);
  $$ContentDownloadsTableTableManager get contentDownloads =>
      $$ContentDownloadsTableTableManager(
        _db.attachedDatabase,
        _db.contentDownloads,
      );
}
