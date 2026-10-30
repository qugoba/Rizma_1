import 'package:drift/drift.dart';

import '../enums.dart';

class ContentManifests extends Table {
  IntColumn get grade => integer()();

  IntColumn get sequence => integer()();

  TextColumn get body => text()();

  TextColumn get signature => text().nullable()();

  TextColumn get catalogSha256 => text().nullable()();

  TextColumn get pendingCatalogSha256 => text().nullable()();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {grade};
}

class ContentLessons extends Table {
  TextColumn get lessonId => text()();

  IntColumn get version => integer().withDefault(const Constant(0))();

  IntColumn get contentFormat => integer().withDefault(const Constant(1))();

  TextColumn get files => text().withDefault(const Constant('{}'))();

  TextColumn get videoSha256 => text().nullable()();
  IntColumn get videoSize => integer().nullable()();

  TextColumn get attachments => text().nullable()();

  DateTimeColumn get installedAt => dateTime().nullable()();

  IntColumn get pendingVersion => integer().nullable()();
  IntColumn get pendingContentFormat => integer().nullable()();
  TextColumn get pendingFiles => text().nullable()();
  TextColumn get pendingVideoSha256 => text().nullable()();
  IntColumn get pendingVideoSize => integer().nullable()();
  TextColumn get pendingAttachments => text().nullable()();

  @override
  Set<Column> get primaryKey => {lessonId};
}

class ContentBlobs extends Table {
  TextColumn get sha256 => text()();
  IntColumn get size => integer()();
  TextColumn get kind => textEnum<BlobKind>()();
  DateTimeColumn get verifiedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sha256};
}

class ContentDownloads extends Table {
  TextColumn get sha256 => text()();

  IntColumn get size => integer()();
  TextColumn get kind => textEnum<BlobKind>()();

  IntColumn get priority => integer()();

  IntColumn get received => integer().withDefault(const Constant(0))();

  IntColumn get failures => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sha256};
}
