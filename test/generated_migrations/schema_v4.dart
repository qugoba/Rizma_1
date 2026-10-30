// dart format width=80
// ignore_for_file: type=lint,unused_import
import 'package:drift/drift.dart';

class Profiles extends Table with TableInfo<Profiles, ProfilesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Profiles(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (grade BETWEEN 1 AND 12)',
  );
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> studentCode = GeneratedColumn<String>(
    'student_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  late final GeneratedColumn<String> classCode = GeneratedColumn<String>(
    'class_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> equipped = GeneratedColumn<String>(
    'equipped',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> lastActiveAt = GeneratedColumn<int>(
    'last_active_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    grade,
    color,
    pinHash,
    pinSalt,
    studentCode,
    classCode,
    equipped,
    createdAt,
    lastActiveAt,
    revision,
    localVersion,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfilesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfilesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      ),
      studentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_code'],
      )!,
      classCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_code'],
      ),
      equipped: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipped'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_active_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Profiles createAlias(String alias) {
    return Profiles(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class ProfilesData extends DataClass implements Insertable<ProfilesData> {
  final String id;
  final String name;
  final int grade;
  final String color;
  final String? pinHash;
  final String? pinSalt;
  final String studentCode;
  final String? classCode;
  final String equipped;
  final int createdAt;
  final int lastActiveAt;
  final int revision;
  final int localVersion;
  final int? syncedAt;
  const ProfilesData({
    required this.id,
    required this.name,
    required this.grade,
    required this.color,
    this.pinHash,
    this.pinSalt,
    required this.studentCode,
    this.classCode,
    required this.equipped,
    required this.createdAt,
    required this.lastActiveAt,
    required this.revision,
    required this.localVersion,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['grade'] = Variable<int>(grade);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    if (!nullToAbsent || pinSalt != null) {
      map['pin_salt'] = Variable<String>(pinSalt);
    }
    map['student_code'] = Variable<String>(studentCode);
    if (!nullToAbsent || classCode != null) {
      map['class_code'] = Variable<String>(classCode);
    }
    map['equipped'] = Variable<String>(equipped);
    map['created_at'] = Variable<int>(createdAt);
    map['last_active_at'] = Variable<int>(lastActiveAt);
    map['revision'] = Variable<int>(revision);
    map['local_version'] = Variable<int>(localVersion);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      grade: Value(grade),
      color: Value(color),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      pinSalt: pinSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinSalt),
      studentCode: Value(studentCode),
      classCode: classCode == null && nullToAbsent
          ? const Value.absent()
          : Value(classCode),
      equipped: Value(equipped),
      createdAt: Value(createdAt),
      lastActiveAt: Value(lastActiveAt),
      revision: Value(revision),
      localVersion: Value(localVersion),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory ProfilesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfilesData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      grade: serializer.fromJson<int>(json['grade']),
      color: serializer.fromJson<String>(json['color']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      pinSalt: serializer.fromJson<String?>(json['pinSalt']),
      studentCode: serializer.fromJson<String>(json['studentCode']),
      classCode: serializer.fromJson<String?>(json['classCode']),
      equipped: serializer.fromJson<String>(json['equipped']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastActiveAt: serializer.fromJson<int>(json['lastActiveAt']),
      revision: serializer.fromJson<int>(json['revision']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'grade': serializer.toJson<int>(grade),
      'color': serializer.toJson<String>(color),
      'pinHash': serializer.toJson<String?>(pinHash),
      'pinSalt': serializer.toJson<String?>(pinSalt),
      'studentCode': serializer.toJson<String>(studentCode),
      'classCode': serializer.toJson<String?>(classCode),
      'equipped': serializer.toJson<String>(equipped),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastActiveAt': serializer.toJson<int>(lastActiveAt),
      'revision': serializer.toJson<int>(revision),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  ProfilesData copyWith({
    String? id,
    String? name,
    int? grade,
    String? color,
    Value<String?> pinHash = const Value.absent(),
    Value<String?> pinSalt = const Value.absent(),
    String? studentCode,
    Value<String?> classCode = const Value.absent(),
    String? equipped,
    int? createdAt,
    int? lastActiveAt,
    int? revision,
    int? localVersion,
    Value<int?> syncedAt = const Value.absent(),
  }) => ProfilesData(
    id: id ?? this.id,
    name: name ?? this.name,
    grade: grade ?? this.grade,
    color: color ?? this.color,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    pinSalt: pinSalt.present ? pinSalt.value : this.pinSalt,
    studentCode: studentCode ?? this.studentCode,
    classCode: classCode.present ? classCode.value : this.classCode,
    equipped: equipped ?? this.equipped,
    createdAt: createdAt ?? this.createdAt,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    revision: revision ?? this.revision,
    localVersion: localVersion ?? this.localVersion,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ProfilesData copyWithCompanion(ProfilesCompanion data) {
    return ProfilesData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      grade: data.grade.present ? data.grade.value : this.grade,
      color: data.color.present ? data.color.value : this.color,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      studentCode: data.studentCode.present
          ? data.studentCode.value
          : this.studentCode,
      classCode: data.classCode.present ? data.classCode.value : this.classCode,
      equipped: data.equipped.present ? data.equipped.value : this.equipped,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('grade: $grade, ')
          ..write('color: $color, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('studentCode: $studentCode, ')
          ..write('classCode: $classCode, ')
          ..write('equipped: $equipped, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('revision: $revision, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    grade,
    color,
    pinHash,
    pinSalt,
    studentCode,
    classCode,
    equipped,
    createdAt,
    lastActiveAt,
    revision,
    localVersion,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfilesData &&
          other.id == this.id &&
          other.name == this.name &&
          other.grade == this.grade &&
          other.color == this.color &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.studentCode == this.studentCode &&
          other.classCode == this.classCode &&
          other.equipped == this.equipped &&
          other.createdAt == this.createdAt &&
          other.lastActiveAt == this.lastActiveAt &&
          other.revision == this.revision &&
          other.localVersion == this.localVersion &&
          other.syncedAt == this.syncedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfilesData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> grade;
  final Value<String> color;
  final Value<String?> pinHash;
  final Value<String?> pinSalt;
  final Value<String> studentCode;
  final Value<String?> classCode;
  final Value<String> equipped;
  final Value<int> createdAt;
  final Value<int> lastActiveAt;
  final Value<int> revision;
  final Value<int> localVersion;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.grade = const Value.absent(),
    this.color = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.studentCode = const Value.absent(),
    this.classCode = const Value.absent(),
    this.equipped = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String name,
    required int grade,
    required String color,
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    required String studentCode,
    this.classCode = const Value.absent(),
    this.equipped = const Value.absent(),
    required int createdAt,
    required int lastActiveAt,
    this.revision = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       grade = Value(grade),
       color = Value(color),
       studentCode = Value(studentCode),
       createdAt = Value(createdAt),
       lastActiveAt = Value(lastActiveAt);
  static Insertable<ProfilesData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? grade,
    Expression<String>? color,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<String>? studentCode,
    Expression<String>? classCode,
    Expression<String>? equipped,
    Expression<int>? createdAt,
    Expression<int>? lastActiveAt,
    Expression<int>? revision,
    Expression<int>? localVersion,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (grade != null) 'grade': grade,
      if (color != null) 'color': color,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (studentCode != null) 'student_code': studentCode,
      if (classCode != null) 'class_code': classCode,
      if (equipped != null) 'equipped': equipped,
      if (createdAt != null) 'created_at': createdAt,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (revision != null) 'revision': revision,
      if (localVersion != null) 'local_version': localVersion,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? grade,
    Value<String>? color,
    Value<String?>? pinHash,
    Value<String?>? pinSalt,
    Value<String>? studentCode,
    Value<String?>? classCode,
    Value<String>? equipped,
    Value<int>? createdAt,
    Value<int>? lastActiveAt,
    Value<int>? revision,
    Value<int>? localVersion,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      color: color ?? this.color,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      studentCode: studentCode ?? this.studentCode,
      classCode: classCode ?? this.classCode,
      equipped: equipped ?? this.equipped,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      revision: revision ?? this.revision,
      localVersion: localVersion ?? this.localVersion,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (studentCode.present) {
      map['student_code'] = Variable<String>(studentCode.value);
    }
    if (classCode.present) {
      map['class_code'] = Variable<String>(classCode.value);
    }
    if (equipped.present) {
      map['equipped'] = Variable<String>(equipped.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<int>(lastActiveAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('grade: $grade, ')
          ..write('color: $color, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('studentCode: $studentCode, ')
          ..write('classCode: $classCode, ')
          ..write('equipped: $equipped, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('revision: $revision, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LessonProgress extends Table
    with TableInfo<LessonProgress, LessonProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LessonProgress(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.0',
    defaultValue: const CustomExpression('0.0'),
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    lessonId,
    status,
    progress,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, lessonId};
  @override
  LessonProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  LessonProgress createAlias(String alias) {
    return LessonProgress(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, lesson_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LessonProgressData extends DataClass
    implements Insertable<LessonProgressData> {
  final String profileId;
  final String lessonId;
  final String status;
  final double progress;
  final int updatedAt;
  const LessonProgressData({
    required this.profileId,
    required this.lessonId,
    required this.status,
    required this.progress,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LessonProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressCompanion(
      profileId: Value(profileId),
      lessonId: Value(lessonId),
      status: Value(status),
      progress: Value(progress),
      updatedAt: Value(updatedAt),
    );
  }

  factory LessonProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressData(
      profileId: serializer.fromJson<String>(json['profileId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'lessonId': serializer.toJson<String>(lessonId),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LessonProgressData copyWith({
    String? profileId,
    String? lessonId,
    String? status,
    double? progress,
    int? updatedAt,
  }) => LessonProgressData(
    profileId: profileId ?? this.profileId,
    lessonId: lessonId ?? this.lessonId,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LessonProgressData copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressData(')
          ..write('profileId: $profileId, ')
          ..write('lessonId: $lessonId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileId, lessonId, status, progress, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressData &&
          other.profileId == this.profileId &&
          other.lessonId == this.lessonId &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.updatedAt == this.updatedAt);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressData> {
  final Value<String> profileId;
  final Value<String> lessonId;
  final Value<String> status;
  final Value<double> progress;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LessonProgressCompanion({
    this.profileId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressCompanion.insert({
    required String profileId,
    required String lessonId,
    required String status,
    this.progress = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       lessonId = Value(lessonId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<LessonProgressData> custom({
    Expression<String>? profileId,
    Expression<String>? lessonId,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressCompanion copyWith({
    Value<String>? profileId,
    Value<String>? lessonId,
    Value<String>? status,
    Value<double>? progress,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LessonProgressCompanion(
      profileId: profileId ?? this.profileId,
      lessonId: lessonId ?? this.lessonId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressCompanion(')
          ..write('profileId: $profileId, ')
          ..write('lessonId: $lessonId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LessonPartProgress extends Table
    with TableInfo<LessonPartProgress, LessonPartProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LessonPartProgress(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> part = GeneratedColumn<String>(
    'part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    lessonId,
    part,
    completedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_part_progress';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, lessonId, part};
  @override
  LessonPartProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonPartProgressData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      part: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  LessonPartProgress createAlias(String alias) {
    return LessonPartProgress(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, lesson_id, part)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LessonPartProgressData extends DataClass
    implements Insertable<LessonPartProgressData> {
  final String profileId;
  final String lessonId;
  final String part;
  final int completedAt;
  final int? syncedAt;
  const LessonPartProgressData({
    required this.profileId,
    required this.lessonId,
    required this.part,
    required this.completedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['part'] = Variable<String>(part);
    map['completed_at'] = Variable<int>(completedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  LessonPartProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonPartProgressCompanion(
      profileId: Value(profileId),
      lessonId: Value(lessonId),
      part: Value(part),
      completedAt: Value(completedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LessonPartProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonPartProgressData(
      profileId: serializer.fromJson<String>(json['profileId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      part: serializer.fromJson<String>(json['part']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'lessonId': serializer.toJson<String>(lessonId),
      'part': serializer.toJson<String>(part),
      'completedAt': serializer.toJson<int>(completedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  LessonPartProgressData copyWith({
    String? profileId,
    String? lessonId,
    String? part,
    int? completedAt,
    Value<int?> syncedAt = const Value.absent(),
  }) => LessonPartProgressData(
    profileId: profileId ?? this.profileId,
    lessonId: lessonId ?? this.lessonId,
    part: part ?? this.part,
    completedAt: completedAt ?? this.completedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LessonPartProgressData copyWithCompanion(LessonPartProgressCompanion data) {
    return LessonPartProgressData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      part: data.part.present ? data.part.value : this.part,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonPartProgressData(')
          ..write('profileId: $profileId, ')
          ..write('lessonId: $lessonId, ')
          ..write('part: $part, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileId, lessonId, part, completedAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonPartProgressData &&
          other.profileId == this.profileId &&
          other.lessonId == this.lessonId &&
          other.part == this.part &&
          other.completedAt == this.completedAt &&
          other.syncedAt == this.syncedAt);
}

class LessonPartProgressCompanion
    extends UpdateCompanion<LessonPartProgressData> {
  final Value<String> profileId;
  final Value<String> lessonId;
  final Value<String> part;
  final Value<int> completedAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const LessonPartProgressCompanion({
    this.profileId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.part = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonPartProgressCompanion.insert({
    required String profileId,
    required String lessonId,
    required String part,
    required int completedAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       lessonId = Value(lessonId),
       part = Value(part),
       completedAt = Value(completedAt);
  static Insertable<LessonPartProgressData> custom({
    Expression<String>? profileId,
    Expression<String>? lessonId,
    Expression<String>? part,
    Expression<int>? completedAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (part != null) 'part': part,
      if (completedAt != null) 'completed_at': completedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonPartProgressCompanion copyWith({
    Value<String>? profileId,
    Value<String>? lessonId,
    Value<String>? part,
    Value<int>? completedAt,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return LessonPartProgressCompanion(
      profileId: profileId ?? this.profileId,
      lessonId: lessonId ?? this.lessonId,
      part: part ?? this.part,
      completedAt: completedAt ?? this.completedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (part.present) {
      map['part'] = Variable<String>(part.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonPartProgressCompanion(')
          ..write('profileId: $profileId, ')
          ..write('lessonId: $lessonId, ')
          ..write('part: $part, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class OwnedItems extends Table with TableInfo<OwnedItems, OwnedItemsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  OwnedItems(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> acquiredAt = GeneratedColumn<int>(
    'acquired_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    itemId,
    cost,
    acquiredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_items';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, itemId};
  @override
  OwnedItemsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedItemsData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acquired_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  OwnedItems createAlias(String alias) {
    return OwnedItems(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, item_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class OwnedItemsData extends DataClass implements Insertable<OwnedItemsData> {
  final String profileId;
  final String itemId;
  final int cost;
  final int acquiredAt;
  final int? syncedAt;
  const OwnedItemsData({
    required this.profileId,
    required this.itemId,
    required this.cost,
    required this.acquiredAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['item_id'] = Variable<String>(itemId);
    map['cost'] = Variable<int>(cost);
    map['acquired_at'] = Variable<int>(acquiredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  OwnedItemsCompanion toCompanion(bool nullToAbsent) {
    return OwnedItemsCompanion(
      profileId: Value(profileId),
      itemId: Value(itemId),
      cost: Value(cost),
      acquiredAt: Value(acquiredAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory OwnedItemsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedItemsData(
      profileId: serializer.fromJson<String>(json['profileId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      cost: serializer.fromJson<int>(json['cost']),
      acquiredAt: serializer.fromJson<int>(json['acquiredAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'itemId': serializer.toJson<String>(itemId),
      'cost': serializer.toJson<int>(cost),
      'acquiredAt': serializer.toJson<int>(acquiredAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  OwnedItemsData copyWith({
    String? profileId,
    String? itemId,
    int? cost,
    int? acquiredAt,
    Value<int?> syncedAt = const Value.absent(),
  }) => OwnedItemsData(
    profileId: profileId ?? this.profileId,
    itemId: itemId ?? this.itemId,
    cost: cost ?? this.cost,
    acquiredAt: acquiredAt ?? this.acquiredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  OwnedItemsData copyWithCompanion(OwnedItemsCompanion data) {
    return OwnedItemsData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      cost: data.cost.present ? data.cost.value : this.cost,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsData(')
          ..write('profileId: $profileId, ')
          ..write('itemId: $itemId, ')
          ..write('cost: $cost, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileId, itemId, cost, acquiredAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedItemsData &&
          other.profileId == this.profileId &&
          other.itemId == this.itemId &&
          other.cost == this.cost &&
          other.acquiredAt == this.acquiredAt &&
          other.syncedAt == this.syncedAt);
}

class OwnedItemsCompanion extends UpdateCompanion<OwnedItemsData> {
  final Value<String> profileId;
  final Value<String> itemId;
  final Value<int> cost;
  final Value<int> acquiredAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const OwnedItemsCompanion({
    this.profileId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.cost = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedItemsCompanion.insert({
    required String profileId,
    required String itemId,
    required int cost,
    required int acquiredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       itemId = Value(itemId),
       cost = Value(cost),
       acquiredAt = Value(acquiredAt);
  static Insertable<OwnedItemsData> custom({
    Expression<String>? profileId,
    Expression<String>? itemId,
    Expression<int>? cost,
    Expression<int>? acquiredAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (itemId != null) 'item_id': itemId,
      if (cost != null) 'cost': cost,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedItemsCompanion copyWith({
    Value<String>? profileId,
    Value<String>? itemId,
    Value<int>? cost,
    Value<int>? acquiredAt,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return OwnedItemsCompanion(
      profileId: profileId ?? this.profileId,
      itemId: itemId ?? this.itemId,
      cost: cost ?? this.cost,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<int>(acquiredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('itemId: $itemId, ')
          ..write('cost: $cost, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Attempts extends Table with TableInfo<Attempts, AttemptsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Attempts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> starsEarned = GeneratedColumn<int>(
    'stars_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> hintsUsed = GeneratedColumn<int>(
    'hints_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> serverReceivedAt = GeneratedColumn<int>(
    'server_received_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    activityId,
    kind,
    score,
    total,
    starsEarned,
    hintsUsed,
    detailsJson,
    createdAt,
    syncedAt,
    serverReceivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      starsEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars_earned'],
      )!,
      hintsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hints_used'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_received_at'],
      ),
    );
  }

  @override
  Attempts createAlias(String alias) {
    return Attempts(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class AttemptsData extends DataClass implements Insertable<AttemptsData> {
  final String id;
  final String profileId;
  final String activityId;
  final String kind;
  final int score;
  final int total;
  final int starsEarned;
  final int hintsUsed;
  final String? detailsJson;
  final int createdAt;
  final int? syncedAt;
  final int? serverReceivedAt;
  const AttemptsData({
    required this.id,
    required this.profileId,
    required this.activityId,
    required this.kind,
    required this.score,
    required this.total,
    required this.starsEarned,
    required this.hintsUsed,
    this.detailsJson,
    required this.createdAt,
    this.syncedAt,
    this.serverReceivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['activity_id'] = Variable<String>(activityId);
    map['kind'] = Variable<String>(kind);
    map['score'] = Variable<int>(score);
    map['total'] = Variable<int>(total);
    map['stars_earned'] = Variable<int>(starsEarned);
    map['hints_used'] = Variable<int>(hintsUsed);
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<int>(serverReceivedAt);
    }
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      activityId: Value(activityId),
      kind: Value(kind),
      score: Value(score),
      total: Value(total),
      starsEarned: Value(starsEarned),
      hintsUsed: Value(hintsUsed),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
    );
  }

  factory AttemptsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptsData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      activityId: serializer.fromJson<String>(json['activityId']),
      kind: serializer.fromJson<String>(json['kind']),
      score: serializer.fromJson<int>(json['score']),
      total: serializer.fromJson<int>(json['total']),
      starsEarned: serializer.fromJson<int>(json['starsEarned']),
      hintsUsed: serializer.fromJson<int>(json['hintsUsed']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      serverReceivedAt: serializer.fromJson<int?>(json['serverReceivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'activityId': serializer.toJson<String>(activityId),
      'kind': serializer.toJson<String>(kind),
      'score': serializer.toJson<int>(score),
      'total': serializer.toJson<int>(total),
      'starsEarned': serializer.toJson<int>(starsEarned),
      'hintsUsed': serializer.toJson<int>(hintsUsed),
      'detailsJson': serializer.toJson<String?>(detailsJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'serverReceivedAt': serializer.toJson<int?>(serverReceivedAt),
    };
  }

  AttemptsData copyWith({
    String? id,
    String? profileId,
    String? activityId,
    String? kind,
    int? score,
    int? total,
    int? starsEarned,
    int? hintsUsed,
    Value<String?> detailsJson = const Value.absent(),
    int? createdAt,
    Value<int?> syncedAt = const Value.absent(),
    Value<int?> serverReceivedAt = const Value.absent(),
  }) => AttemptsData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    activityId: activityId ?? this.activityId,
    kind: kind ?? this.kind,
    score: score ?? this.score,
    total: total ?? this.total,
    starsEarned: starsEarned ?? this.starsEarned,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
  );
  AttemptsData copyWithCompanion(AttemptsCompanion data) {
    return AttemptsData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      kind: data.kind.present ? data.kind.value : this.kind,
      score: data.score.present ? data.score.value : this.score,
      total: data.total.present ? data.total.value : this.total,
      starsEarned: data.starsEarned.present
          ? data.starsEarned.value
          : this.starsEarned,
      hintsUsed: data.hintsUsed.present ? data.hintsUsed.value : this.hintsUsed,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('activityId: $activityId, ')
          ..write('kind: $kind, ')
          ..write('score: $score, ')
          ..write('total: $total, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    activityId,
    kind,
    score,
    total,
    starsEarned,
    hintsUsed,
    detailsJson,
    createdAt,
    syncedAt,
    serverReceivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptsData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.activityId == this.activityId &&
          other.kind == this.kind &&
          other.score == this.score &&
          other.total == this.total &&
          other.starsEarned == this.starsEarned &&
          other.hintsUsed == this.hintsUsed &&
          other.detailsJson == this.detailsJson &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt &&
          other.serverReceivedAt == this.serverReceivedAt);
}

class AttemptsCompanion extends UpdateCompanion<AttemptsData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> activityId;
  final Value<String> kind;
  final Value<int> score;
  final Value<int> total;
  final Value<int> starsEarned;
  final Value<int> hintsUsed;
  final Value<String?> detailsJson;
  final Value<int> createdAt;
  final Value<int?> syncedAt;
  final Value<int?> serverReceivedAt;
  final Value<int> rowid;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.activityId = const Value.absent(),
    this.kind = const Value.absent(),
    this.score = const Value.absent(),
    this.total = const Value.absent(),
    this.starsEarned = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttemptsCompanion.insert({
    required String id,
    required String profileId,
    required String activityId,
    required String kind,
    required int score,
    required int total,
    this.starsEarned = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.detailsJson = const Value.absent(),
    required int createdAt,
    this.syncedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       activityId = Value(activityId),
       kind = Value(kind),
       score = Value(score),
       total = Value(total),
       createdAt = Value(createdAt);
  static Insertable<AttemptsData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? activityId,
    Expression<String>? kind,
    Expression<int>? score,
    Expression<int>? total,
    Expression<int>? starsEarned,
    Expression<int>? hintsUsed,
    Expression<String>? detailsJson,
    Expression<int>? createdAt,
    Expression<int>? syncedAt,
    Expression<int>? serverReceivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (activityId != null) 'activity_id': activityId,
      if (kind != null) 'kind': kind,
      if (score != null) 'score': score,
      if (total != null) 'total': total,
      if (starsEarned != null) 'stars_earned': starsEarned,
      if (hintsUsed != null) 'hints_used': hintsUsed,
      if (detailsJson != null) 'details_json': detailsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? activityId,
    Value<String>? kind,
    Value<int>? score,
    Value<int>? total,
    Value<int>? starsEarned,
    Value<int>? hintsUsed,
    Value<String?>? detailsJson,
    Value<int>? createdAt,
    Value<int?>? syncedAt,
    Value<int?>? serverReceivedAt,
    Value<int>? rowid,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      activityId: activityId ?? this.activityId,
      kind: kind ?? this.kind,
      score: score ?? this.score,
      total: total ?? this.total,
      starsEarned: starsEarned ?? this.starsEarned,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (starsEarned.present) {
      map['stars_earned'] = Variable<int>(starsEarned.value);
    }
    if (hintsUsed.present) {
      map['hints_used'] = Variable<int>(hintsUsed.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<int>(serverReceivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('activityId: $activityId, ')
          ..write('kind: $kind, ')
          ..write('score: $score, ')
          ..write('total: $total, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ConceptMastery extends Table
    with TableInfo<ConceptMastery, ConceptMasteryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ConceptMastery(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
    'concept_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> mastery = GeneratedColumn<double>(
    'mastery',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    conceptId,
    mastery,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concept_mastery';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, conceptId};
  @override
  ConceptMasteryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConceptMasteryData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      conceptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept_id'],
      )!,
      mastery: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mastery'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  ConceptMastery createAlias(String alias) {
    return ConceptMastery(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, concept_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ConceptMasteryData extends DataClass
    implements Insertable<ConceptMasteryData> {
  final String profileId;
  final String conceptId;
  final double mastery;
  final int updatedAt;
  const ConceptMasteryData({
    required this.profileId,
    required this.conceptId,
    required this.mastery,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['concept_id'] = Variable<String>(conceptId);
    map['mastery'] = Variable<double>(mastery);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ConceptMasteryCompanion toCompanion(bool nullToAbsent) {
    return ConceptMasteryCompanion(
      profileId: Value(profileId),
      conceptId: Value(conceptId),
      mastery: Value(mastery),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConceptMasteryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConceptMasteryData(
      profileId: serializer.fromJson<String>(json['profileId']),
      conceptId: serializer.fromJson<String>(json['conceptId']),
      mastery: serializer.fromJson<double>(json['mastery']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'conceptId': serializer.toJson<String>(conceptId),
      'mastery': serializer.toJson<double>(mastery),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ConceptMasteryData copyWith({
    String? profileId,
    String? conceptId,
    double? mastery,
    int? updatedAt,
  }) => ConceptMasteryData(
    profileId: profileId ?? this.profileId,
    conceptId: conceptId ?? this.conceptId,
    mastery: mastery ?? this.mastery,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ConceptMasteryData copyWithCompanion(ConceptMasteryCompanion data) {
    return ConceptMasteryData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      mastery: data.mastery.present ? data.mastery.value : this.mastery,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConceptMasteryData(')
          ..write('profileId: $profileId, ')
          ..write('conceptId: $conceptId, ')
          ..write('mastery: $mastery, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, conceptId, mastery, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConceptMasteryData &&
          other.profileId == this.profileId &&
          other.conceptId == this.conceptId &&
          other.mastery == this.mastery &&
          other.updatedAt == this.updatedAt);
}

class ConceptMasteryCompanion extends UpdateCompanion<ConceptMasteryData> {
  final Value<String> profileId;
  final Value<String> conceptId;
  final Value<double> mastery;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ConceptMasteryCompanion({
    this.profileId = const Value.absent(),
    this.conceptId = const Value.absent(),
    this.mastery = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConceptMasteryCompanion.insert({
    required String profileId,
    required String conceptId,
    required double mastery,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       conceptId = Value(conceptId),
       mastery = Value(mastery),
       updatedAt = Value(updatedAt);
  static Insertable<ConceptMasteryData> custom({
    Expression<String>? profileId,
    Expression<String>? conceptId,
    Expression<double>? mastery,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (conceptId != null) 'concept_id': conceptId,
      if (mastery != null) 'mastery': mastery,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConceptMasteryCompanion copyWith({
    Value<String>? profileId,
    Value<String>? conceptId,
    Value<double>? mastery,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConceptMasteryCompanion(
      profileId: profileId ?? this.profileId,
      conceptId: conceptId ?? this.conceptId,
      mastery: mastery ?? this.mastery,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (mastery.present) {
      map['mastery'] = Variable<double>(mastery.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConceptMasteryCompanion(')
          ..write('profileId: $profileId, ')
          ..write('conceptId: $conceptId, ')
          ..write('mastery: $mastery, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Bookmarks extends Table with TableInfo<Bookmarks, BookmarksData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Bookmarks(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> removedAt = GeneratedColumn<int>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    lessonId,
    removedAt,
    updatedAt,
    localVersion,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, lessonId};
  @override
  BookmarksData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarksData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}removed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Bookmarks createAlias(String alias) {
    return Bookmarks(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, lesson_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BookmarksData extends DataClass implements Insertable<BookmarksData> {
  final String profileId;
  final String lessonId;
  final int? removedAt;
  final int updatedAt;
  final int localVersion;
  final int? syncedAt;
  const BookmarksData({
    required this.profileId,
    required this.lessonId,
    this.removedAt,
    required this.updatedAt,
    required this.localVersion,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['lesson_id'] = Variable<String>(lessonId);
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<int>(removedAt);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['local_version'] = Variable<int>(localVersion);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      profileId: Value(profileId),
      lessonId: Value(lessonId),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
      updatedAt: Value(updatedAt),
      localVersion: Value(localVersion),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory BookmarksData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarksData(
      profileId: serializer.fromJson<String>(json['profileId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      removedAt: serializer.fromJson<int?>(json['removedAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'lessonId': serializer.toJson<String>(lessonId),
      'removedAt': serializer.toJson<int?>(removedAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  BookmarksData copyWith({
    String? profileId,
    String? lessonId,
    Value<int?> removedAt = const Value.absent(),
    int? updatedAt,
    int? localVersion,
    Value<int?> syncedAt = const Value.absent(),
  }) => BookmarksData(
    profileId: profileId ?? this.profileId,
    lessonId: lessonId ?? this.lessonId,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    localVersion: localVersion ?? this.localVersion,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  BookmarksData copyWithCompanion(BookmarksCompanion data) {
    return BookmarksData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksData(')
          ..write('profileId: $profileId, ')
          ..write('lessonId: $lessonId, ')
          ..write('removedAt: $removedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    lessonId,
    removedAt,
    updatedAt,
    localVersion,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarksData &&
          other.profileId == this.profileId &&
          other.lessonId == this.lessonId &&
          other.removedAt == this.removedAt &&
          other.updatedAt == this.updatedAt &&
          other.localVersion == this.localVersion &&
          other.syncedAt == this.syncedAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarksData> {
  final Value<String> profileId;
  final Value<String> lessonId;
  final Value<int?> removedAt;
  final Value<int> updatedAt;
  final Value<int> localVersion;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.profileId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String profileId,
    required String lessonId,
    this.removedAt = const Value.absent(),
    required int updatedAt,
    this.localVersion = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       lessonId = Value(lessonId),
       updatedAt = Value(updatedAt);
  static Insertable<BookmarksData> custom({
    Expression<String>? profileId,
    Expression<String>? lessonId,
    Expression<int>? removedAt,
    Expression<int>? updatedAt,
    Expression<int>? localVersion,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (removedAt != null) 'removed_at': removedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? profileId,
    Value<String>? lessonId,
    Value<int?>? removedAt,
    Value<int>? updatedAt,
    Value<int>? localVersion,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      profileId: profileId ?? this.profileId,
      lessonId: lessonId ?? this.lessonId,
      removedAt: removedAt ?? this.removedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localVersion: localVersion ?? this.localVersion,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<int>(removedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('profileId: $profileId, ')
          ..write('lessonId: $lessonId, ')
          ..write('removedAt: $removedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AppSettings extends Table with TableInfo<AppSettings, AppSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppSettings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  AppSettings createAlias(String alias) {
    return AppSettings(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY("key")'];
  @override
  bool get dontWriteConstraints => true;
}

class AppSettingsData extends DataClass implements Insertable<AppSettingsData> {
  final String key;
  final String value;
  const AppSettingsData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsData copyWith({String? key, String? value}) =>
      AppSettingsData(key: key ?? this.key, value: value ?? this.value);
  AppSettingsData copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingsData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ContentManifests extends Table
    with TableInfo<ContentManifests, ContentManifestsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ContentManifests(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> catalogSha256 = GeneratedColumn<String>(
    'catalog_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> pendingCatalogSha256 =
      GeneratedColumn<String>(
        'pending_catalog_sha256',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'NULL',
      );
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    grade,
    sequence,
    body,
    catalogSha256,
    pendingCatalogSha256,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_manifests';
  @override
  Set<GeneratedColumn> get $primaryKey => {grade};
  @override
  ContentManifestsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentManifestsData(
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      catalogSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_sha256'],
      ),
      pendingCatalogSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_catalog_sha256'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  ContentManifests createAlias(String alias) {
    return ContentManifests(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(grade)'];
  @override
  bool get dontWriteConstraints => true;
}

class ContentManifestsData extends DataClass
    implements Insertable<ContentManifestsData> {
  final int grade;
  final int sequence;
  final String body;
  final String? catalogSha256;
  final String? pendingCatalogSha256;
  final int fetchedAt;
  const ContentManifestsData({
    required this.grade,
    required this.sequence,
    required this.body,
    this.catalogSha256,
    this.pendingCatalogSha256,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['grade'] = Variable<int>(grade);
    map['sequence'] = Variable<int>(sequence);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || catalogSha256 != null) {
      map['catalog_sha256'] = Variable<String>(catalogSha256);
    }
    if (!nullToAbsent || pendingCatalogSha256 != null) {
      map['pending_catalog_sha256'] = Variable<String>(pendingCatalogSha256);
    }
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  ContentManifestsCompanion toCompanion(bool nullToAbsent) {
    return ContentManifestsCompanion(
      grade: Value(grade),
      sequence: Value(sequence),
      body: Value(body),
      catalogSha256: catalogSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogSha256),
      pendingCatalogSha256: pendingCatalogSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingCatalogSha256),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ContentManifestsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentManifestsData(
      grade: serializer.fromJson<int>(json['grade']),
      sequence: serializer.fromJson<int>(json['sequence']),
      body: serializer.fromJson<String>(json['body']),
      catalogSha256: serializer.fromJson<String?>(json['catalogSha256']),
      pendingCatalogSha256: serializer.fromJson<String?>(
        json['pendingCatalogSha256'],
      ),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'grade': serializer.toJson<int>(grade),
      'sequence': serializer.toJson<int>(sequence),
      'body': serializer.toJson<String>(body),
      'catalogSha256': serializer.toJson<String?>(catalogSha256),
      'pendingCatalogSha256': serializer.toJson<String?>(pendingCatalogSha256),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  ContentManifestsData copyWith({
    int? grade,
    int? sequence,
    String? body,
    Value<String?> catalogSha256 = const Value.absent(),
    Value<String?> pendingCatalogSha256 = const Value.absent(),
    int? fetchedAt,
  }) => ContentManifestsData(
    grade: grade ?? this.grade,
    sequence: sequence ?? this.sequence,
    body: body ?? this.body,
    catalogSha256: catalogSha256.present
        ? catalogSha256.value
        : this.catalogSha256,
    pendingCatalogSha256: pendingCatalogSha256.present
        ? pendingCatalogSha256.value
        : this.pendingCatalogSha256,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ContentManifestsData copyWithCompanion(ContentManifestsCompanion data) {
    return ContentManifestsData(
      grade: data.grade.present ? data.grade.value : this.grade,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      body: data.body.present ? data.body.value : this.body,
      catalogSha256: data.catalogSha256.present
          ? data.catalogSha256.value
          : this.catalogSha256,
      pendingCatalogSha256: data.pendingCatalogSha256.present
          ? data.pendingCatalogSha256.value
          : this.pendingCatalogSha256,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentManifestsData(')
          ..write('grade: $grade, ')
          ..write('sequence: $sequence, ')
          ..write('body: $body, ')
          ..write('catalogSha256: $catalogSha256, ')
          ..write('pendingCatalogSha256: $pendingCatalogSha256, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    grade,
    sequence,
    body,
    catalogSha256,
    pendingCatalogSha256,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentManifestsData &&
          other.grade == this.grade &&
          other.sequence == this.sequence &&
          other.body == this.body &&
          other.catalogSha256 == this.catalogSha256 &&
          other.pendingCatalogSha256 == this.pendingCatalogSha256 &&
          other.fetchedAt == this.fetchedAt);
}

class ContentManifestsCompanion extends UpdateCompanion<ContentManifestsData> {
  final Value<int> grade;
  final Value<int> sequence;
  final Value<String> body;
  final Value<String?> catalogSha256;
  final Value<String?> pendingCatalogSha256;
  final Value<int> fetchedAt;
  const ContentManifestsCompanion({
    this.grade = const Value.absent(),
    this.sequence = const Value.absent(),
    this.body = const Value.absent(),
    this.catalogSha256 = const Value.absent(),
    this.pendingCatalogSha256 = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  ContentManifestsCompanion.insert({
    this.grade = const Value.absent(),
    required int sequence,
    required String body,
    this.catalogSha256 = const Value.absent(),
    this.pendingCatalogSha256 = const Value.absent(),
    required int fetchedAt,
  }) : sequence = Value(sequence),
       body = Value(body),
       fetchedAt = Value(fetchedAt);
  static Insertable<ContentManifestsData> custom({
    Expression<int>? grade,
    Expression<int>? sequence,
    Expression<String>? body,
    Expression<String>? catalogSha256,
    Expression<String>? pendingCatalogSha256,
    Expression<int>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (grade != null) 'grade': grade,
      if (sequence != null) 'sequence': sequence,
      if (body != null) 'body': body,
      if (catalogSha256 != null) 'catalog_sha256': catalogSha256,
      if (pendingCatalogSha256 != null)
        'pending_catalog_sha256': pendingCatalogSha256,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  ContentManifestsCompanion copyWith({
    Value<int>? grade,
    Value<int>? sequence,
    Value<String>? body,
    Value<String?>? catalogSha256,
    Value<String?>? pendingCatalogSha256,
    Value<int>? fetchedAt,
  }) {
    return ContentManifestsCompanion(
      grade: grade ?? this.grade,
      sequence: sequence ?? this.sequence,
      body: body ?? this.body,
      catalogSha256: catalogSha256 ?? this.catalogSha256,
      pendingCatalogSha256: pendingCatalogSha256 ?? this.pendingCatalogSha256,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (catalogSha256.present) {
      map['catalog_sha256'] = Variable<String>(catalogSha256.value);
    }
    if (pendingCatalogSha256.present) {
      map['pending_catalog_sha256'] = Variable<String>(
        pendingCatalogSha256.value,
      );
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentManifestsCompanion(')
          ..write('grade: $grade, ')
          ..write('sequence: $sequence, ')
          ..write('body: $body, ')
          ..write('catalogSha256: $catalogSha256, ')
          ..write('pendingCatalogSha256: $pendingCatalogSha256, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class ContentLessons extends Table
    with TableInfo<ContentLessons, ContentLessonsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ContentLessons(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> contentFormat = GeneratedColumn<int>(
    'content_format',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  late final GeneratedColumn<String> files = GeneratedColumn<String>(
    'files',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'{}\'',
    defaultValue: const CustomExpression('\'{}\''),
  );
  late final GeneratedColumn<String> videoSha256 = GeneratedColumn<String>(
    'video_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> videoSize = GeneratedColumn<int>(
    'video_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> installedAt = GeneratedColumn<int>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> pendingVersion = GeneratedColumn<int>(
    'pending_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> pendingContentFormat = GeneratedColumn<int>(
    'pending_content_format',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> pendingFiles = GeneratedColumn<String>(
    'pending_files',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> pendingVideoSha256 =
      GeneratedColumn<String>(
        'pending_video_sha256',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'NULL',
      );
  late final GeneratedColumn<int> pendingVideoSize = GeneratedColumn<int>(
    'pending_video_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    lessonId,
    version,
    contentFormat,
    files,
    videoSha256,
    videoSize,
    installedAt,
    pendingVersion,
    pendingContentFormat,
    pendingFiles,
    pendingVideoSha256,
    pendingVideoSize,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_lessons';
  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  ContentLessonsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentLessonsData(
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      contentFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_format'],
      )!,
      files: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}files'],
      )!,
      videoSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_sha256'],
      ),
      videoSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}video_size'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installed_at'],
      ),
      pendingVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_version'],
      ),
      pendingContentFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_content_format'],
      ),
      pendingFiles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_files'],
      ),
      pendingVideoSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_video_sha256'],
      ),
      pendingVideoSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_video_size'],
      ),
    );
  }

  @override
  ContentLessons createAlias(String alias) {
    return ContentLessons(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(lesson_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class ContentLessonsData extends DataClass
    implements Insertable<ContentLessonsData> {
  final String lessonId;
  final int version;
  final int contentFormat;
  final String files;
  final String? videoSha256;
  final int? videoSize;
  final int? installedAt;
  final int? pendingVersion;
  final int? pendingContentFormat;
  final String? pendingFiles;
  final String? pendingVideoSha256;
  final int? pendingVideoSize;
  const ContentLessonsData({
    required this.lessonId,
    required this.version,
    required this.contentFormat,
    required this.files,
    this.videoSha256,
    this.videoSize,
    this.installedAt,
    this.pendingVersion,
    this.pendingContentFormat,
    this.pendingFiles,
    this.pendingVideoSha256,
    this.pendingVideoSize,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<String>(lessonId);
    map['version'] = Variable<int>(version);
    map['content_format'] = Variable<int>(contentFormat);
    map['files'] = Variable<String>(files);
    if (!nullToAbsent || videoSha256 != null) {
      map['video_sha256'] = Variable<String>(videoSha256);
    }
    if (!nullToAbsent || videoSize != null) {
      map['video_size'] = Variable<int>(videoSize);
    }
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<int>(installedAt);
    }
    if (!nullToAbsent || pendingVersion != null) {
      map['pending_version'] = Variable<int>(pendingVersion);
    }
    if (!nullToAbsent || pendingContentFormat != null) {
      map['pending_content_format'] = Variable<int>(pendingContentFormat);
    }
    if (!nullToAbsent || pendingFiles != null) {
      map['pending_files'] = Variable<String>(pendingFiles);
    }
    if (!nullToAbsent || pendingVideoSha256 != null) {
      map['pending_video_sha256'] = Variable<String>(pendingVideoSha256);
    }
    if (!nullToAbsent || pendingVideoSize != null) {
      map['pending_video_size'] = Variable<int>(pendingVideoSize);
    }
    return map;
  }

  ContentLessonsCompanion toCompanion(bool nullToAbsent) {
    return ContentLessonsCompanion(
      lessonId: Value(lessonId),
      version: Value(version),
      contentFormat: Value(contentFormat),
      files: Value(files),
      videoSha256: videoSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(videoSha256),
      videoSize: videoSize == null && nullToAbsent
          ? const Value.absent()
          : Value(videoSize),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
      pendingVersion: pendingVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingVersion),
      pendingContentFormat: pendingContentFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingContentFormat),
      pendingFiles: pendingFiles == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingFiles),
      pendingVideoSha256: pendingVideoSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingVideoSha256),
      pendingVideoSize: pendingVideoSize == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingVideoSize),
    );
  }

  factory ContentLessonsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentLessonsData(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      version: serializer.fromJson<int>(json['version']),
      contentFormat: serializer.fromJson<int>(json['contentFormat']),
      files: serializer.fromJson<String>(json['files']),
      videoSha256: serializer.fromJson<String?>(json['videoSha256']),
      videoSize: serializer.fromJson<int?>(json['videoSize']),
      installedAt: serializer.fromJson<int?>(json['installedAt']),
      pendingVersion: serializer.fromJson<int?>(json['pendingVersion']),
      pendingContentFormat: serializer.fromJson<int?>(
        json['pendingContentFormat'],
      ),
      pendingFiles: serializer.fromJson<String?>(json['pendingFiles']),
      pendingVideoSha256: serializer.fromJson<String?>(
        json['pendingVideoSha256'],
      ),
      pendingVideoSize: serializer.fromJson<int?>(json['pendingVideoSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<String>(lessonId),
      'version': serializer.toJson<int>(version),
      'contentFormat': serializer.toJson<int>(contentFormat),
      'files': serializer.toJson<String>(files),
      'videoSha256': serializer.toJson<String?>(videoSha256),
      'videoSize': serializer.toJson<int?>(videoSize),
      'installedAt': serializer.toJson<int?>(installedAt),
      'pendingVersion': serializer.toJson<int?>(pendingVersion),
      'pendingContentFormat': serializer.toJson<int?>(pendingContentFormat),
      'pendingFiles': serializer.toJson<String?>(pendingFiles),
      'pendingVideoSha256': serializer.toJson<String?>(pendingVideoSha256),
      'pendingVideoSize': serializer.toJson<int?>(pendingVideoSize),
    };
  }

  ContentLessonsData copyWith({
    String? lessonId,
    int? version,
    int? contentFormat,
    String? files,
    Value<String?> videoSha256 = const Value.absent(),
    Value<int?> videoSize = const Value.absent(),
    Value<int?> installedAt = const Value.absent(),
    Value<int?> pendingVersion = const Value.absent(),
    Value<int?> pendingContentFormat = const Value.absent(),
    Value<String?> pendingFiles = const Value.absent(),
    Value<String?> pendingVideoSha256 = const Value.absent(),
    Value<int?> pendingVideoSize = const Value.absent(),
  }) => ContentLessonsData(
    lessonId: lessonId ?? this.lessonId,
    version: version ?? this.version,
    contentFormat: contentFormat ?? this.contentFormat,
    files: files ?? this.files,
    videoSha256: videoSha256.present ? videoSha256.value : this.videoSha256,
    videoSize: videoSize.present ? videoSize.value : this.videoSize,
    installedAt: installedAt.present ? installedAt.value : this.installedAt,
    pendingVersion: pendingVersion.present
        ? pendingVersion.value
        : this.pendingVersion,
    pendingContentFormat: pendingContentFormat.present
        ? pendingContentFormat.value
        : this.pendingContentFormat,
    pendingFiles: pendingFiles.present ? pendingFiles.value : this.pendingFiles,
    pendingVideoSha256: pendingVideoSha256.present
        ? pendingVideoSha256.value
        : this.pendingVideoSha256,
    pendingVideoSize: pendingVideoSize.present
        ? pendingVideoSize.value
        : this.pendingVideoSize,
  );
  ContentLessonsData copyWithCompanion(ContentLessonsCompanion data) {
    return ContentLessonsData(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      version: data.version.present ? data.version.value : this.version,
      contentFormat: data.contentFormat.present
          ? data.contentFormat.value
          : this.contentFormat,
      files: data.files.present ? data.files.value : this.files,
      videoSha256: data.videoSha256.present
          ? data.videoSha256.value
          : this.videoSha256,
      videoSize: data.videoSize.present ? data.videoSize.value : this.videoSize,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      pendingVersion: data.pendingVersion.present
          ? data.pendingVersion.value
          : this.pendingVersion,
      pendingContentFormat: data.pendingContentFormat.present
          ? data.pendingContentFormat.value
          : this.pendingContentFormat,
      pendingFiles: data.pendingFiles.present
          ? data.pendingFiles.value
          : this.pendingFiles,
      pendingVideoSha256: data.pendingVideoSha256.present
          ? data.pendingVideoSha256.value
          : this.pendingVideoSha256,
      pendingVideoSize: data.pendingVideoSize.present
          ? data.pendingVideoSize.value
          : this.pendingVideoSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentLessonsData(')
          ..write('lessonId: $lessonId, ')
          ..write('version: $version, ')
          ..write('contentFormat: $contentFormat, ')
          ..write('files: $files, ')
          ..write('videoSha256: $videoSha256, ')
          ..write('videoSize: $videoSize, ')
          ..write('installedAt: $installedAt, ')
          ..write('pendingVersion: $pendingVersion, ')
          ..write('pendingContentFormat: $pendingContentFormat, ')
          ..write('pendingFiles: $pendingFiles, ')
          ..write('pendingVideoSha256: $pendingVideoSha256, ')
          ..write('pendingVideoSize: $pendingVideoSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lessonId,
    version,
    contentFormat,
    files,
    videoSha256,
    videoSize,
    installedAt,
    pendingVersion,
    pendingContentFormat,
    pendingFiles,
    pendingVideoSha256,
    pendingVideoSize,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentLessonsData &&
          other.lessonId == this.lessonId &&
          other.version == this.version &&
          other.contentFormat == this.contentFormat &&
          other.files == this.files &&
          other.videoSha256 == this.videoSha256 &&
          other.videoSize == this.videoSize &&
          other.installedAt == this.installedAt &&
          other.pendingVersion == this.pendingVersion &&
          other.pendingContentFormat == this.pendingContentFormat &&
          other.pendingFiles == this.pendingFiles &&
          other.pendingVideoSha256 == this.pendingVideoSha256 &&
          other.pendingVideoSize == this.pendingVideoSize);
}

class ContentLessonsCompanion extends UpdateCompanion<ContentLessonsData> {
  final Value<String> lessonId;
  final Value<int> version;
  final Value<int> contentFormat;
  final Value<String> files;
  final Value<String?> videoSha256;
  final Value<int?> videoSize;
  final Value<int?> installedAt;
  final Value<int?> pendingVersion;
  final Value<int?> pendingContentFormat;
  final Value<String?> pendingFiles;
  final Value<String?> pendingVideoSha256;
  final Value<int?> pendingVideoSize;
  final Value<int> rowid;
  const ContentLessonsCompanion({
    this.lessonId = const Value.absent(),
    this.version = const Value.absent(),
    this.contentFormat = const Value.absent(),
    this.files = const Value.absent(),
    this.videoSha256 = const Value.absent(),
    this.videoSize = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.pendingVersion = const Value.absent(),
    this.pendingContentFormat = const Value.absent(),
    this.pendingFiles = const Value.absent(),
    this.pendingVideoSha256 = const Value.absent(),
    this.pendingVideoSize = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentLessonsCompanion.insert({
    required String lessonId,
    this.version = const Value.absent(),
    this.contentFormat = const Value.absent(),
    this.files = const Value.absent(),
    this.videoSha256 = const Value.absent(),
    this.videoSize = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.pendingVersion = const Value.absent(),
    this.pendingContentFormat = const Value.absent(),
    this.pendingFiles = const Value.absent(),
    this.pendingVideoSha256 = const Value.absent(),
    this.pendingVideoSize = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId);
  static Insertable<ContentLessonsData> custom({
    Expression<String>? lessonId,
    Expression<int>? version,
    Expression<int>? contentFormat,
    Expression<String>? files,
    Expression<String>? videoSha256,
    Expression<int>? videoSize,
    Expression<int>? installedAt,
    Expression<int>? pendingVersion,
    Expression<int>? pendingContentFormat,
    Expression<String>? pendingFiles,
    Expression<String>? pendingVideoSha256,
    Expression<int>? pendingVideoSize,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (version != null) 'version': version,
      if (contentFormat != null) 'content_format': contentFormat,
      if (files != null) 'files': files,
      if (videoSha256 != null) 'video_sha256': videoSha256,
      if (videoSize != null) 'video_size': videoSize,
      if (installedAt != null) 'installed_at': installedAt,
      if (pendingVersion != null) 'pending_version': pendingVersion,
      if (pendingContentFormat != null)
        'pending_content_format': pendingContentFormat,
      if (pendingFiles != null) 'pending_files': pendingFiles,
      if (pendingVideoSha256 != null)
        'pending_video_sha256': pendingVideoSha256,
      if (pendingVideoSize != null) 'pending_video_size': pendingVideoSize,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentLessonsCompanion copyWith({
    Value<String>? lessonId,
    Value<int>? version,
    Value<int>? contentFormat,
    Value<String>? files,
    Value<String?>? videoSha256,
    Value<int?>? videoSize,
    Value<int?>? installedAt,
    Value<int?>? pendingVersion,
    Value<int?>? pendingContentFormat,
    Value<String?>? pendingFiles,
    Value<String?>? pendingVideoSha256,
    Value<int?>? pendingVideoSize,
    Value<int>? rowid,
  }) {
    return ContentLessonsCompanion(
      lessonId: lessonId ?? this.lessonId,
      version: version ?? this.version,
      contentFormat: contentFormat ?? this.contentFormat,
      files: files ?? this.files,
      videoSha256: videoSha256 ?? this.videoSha256,
      videoSize: videoSize ?? this.videoSize,
      installedAt: installedAt ?? this.installedAt,
      pendingVersion: pendingVersion ?? this.pendingVersion,
      pendingContentFormat: pendingContentFormat ?? this.pendingContentFormat,
      pendingFiles: pendingFiles ?? this.pendingFiles,
      pendingVideoSha256: pendingVideoSha256 ?? this.pendingVideoSha256,
      pendingVideoSize: pendingVideoSize ?? this.pendingVideoSize,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (contentFormat.present) {
      map['content_format'] = Variable<int>(contentFormat.value);
    }
    if (files.present) {
      map['files'] = Variable<String>(files.value);
    }
    if (videoSha256.present) {
      map['video_sha256'] = Variable<String>(videoSha256.value);
    }
    if (videoSize.present) {
      map['video_size'] = Variable<int>(videoSize.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<int>(installedAt.value);
    }
    if (pendingVersion.present) {
      map['pending_version'] = Variable<int>(pendingVersion.value);
    }
    if (pendingContentFormat.present) {
      map['pending_content_format'] = Variable<int>(pendingContentFormat.value);
    }
    if (pendingFiles.present) {
      map['pending_files'] = Variable<String>(pendingFiles.value);
    }
    if (pendingVideoSha256.present) {
      map['pending_video_sha256'] = Variable<String>(pendingVideoSha256.value);
    }
    if (pendingVideoSize.present) {
      map['pending_video_size'] = Variable<int>(pendingVideoSize.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentLessonsCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('version: $version, ')
          ..write('contentFormat: $contentFormat, ')
          ..write('files: $files, ')
          ..write('videoSha256: $videoSha256, ')
          ..write('videoSize: $videoSize, ')
          ..write('installedAt: $installedAt, ')
          ..write('pendingVersion: $pendingVersion, ')
          ..write('pendingContentFormat: $pendingContentFormat, ')
          ..write('pendingFiles: $pendingFiles, ')
          ..write('pendingVideoSha256: $pendingVideoSha256, ')
          ..write('pendingVideoSize: $pendingVideoSize, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ContentBlobs extends Table
    with TableInfo<ContentBlobs, ContentBlobsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ContentBlobs(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> verifiedAt = GeneratedColumn<int>(
    'verified_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [sha256, size, kind, verifiedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_blobs';
  @override
  Set<GeneratedColumn> get $primaryKey => {sha256};
  @override
  ContentBlobsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentBlobsData(
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verified_at'],
      )!,
    );
  }

  @override
  ContentBlobs createAlias(String alias) {
    return ContentBlobs(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(sha256)'];
  @override
  bool get dontWriteConstraints => true;
}

class ContentBlobsData extends DataClass
    implements Insertable<ContentBlobsData> {
  final String sha256;
  final int size;
  final String kind;
  final int verifiedAt;
  const ContentBlobsData({
    required this.sha256,
    required this.size,
    required this.kind,
    required this.verifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sha256'] = Variable<String>(sha256);
    map['size'] = Variable<int>(size);
    map['kind'] = Variable<String>(kind);
    map['verified_at'] = Variable<int>(verifiedAt);
    return map;
  }

  ContentBlobsCompanion toCompanion(bool nullToAbsent) {
    return ContentBlobsCompanion(
      sha256: Value(sha256),
      size: Value(size),
      kind: Value(kind),
      verifiedAt: Value(verifiedAt),
    );
  }

  factory ContentBlobsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentBlobsData(
      sha256: serializer.fromJson<String>(json['sha256']),
      size: serializer.fromJson<int>(json['size']),
      kind: serializer.fromJson<String>(json['kind']),
      verifiedAt: serializer.fromJson<int>(json['verifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sha256': serializer.toJson<String>(sha256),
      'size': serializer.toJson<int>(size),
      'kind': serializer.toJson<String>(kind),
      'verifiedAt': serializer.toJson<int>(verifiedAt),
    };
  }

  ContentBlobsData copyWith({
    String? sha256,
    int? size,
    String? kind,
    int? verifiedAt,
  }) => ContentBlobsData(
    sha256: sha256 ?? this.sha256,
    size: size ?? this.size,
    kind: kind ?? this.kind,
    verifiedAt: verifiedAt ?? this.verifiedAt,
  );
  ContentBlobsData copyWithCompanion(ContentBlobsCompanion data) {
    return ContentBlobsData(
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      size: data.size.present ? data.size.value : this.size,
      kind: data.kind.present ? data.kind.value : this.kind,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentBlobsData(')
          ..write('sha256: $sha256, ')
          ..write('size: $size, ')
          ..write('kind: $kind, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sha256, size, kind, verifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentBlobsData &&
          other.sha256 == this.sha256 &&
          other.size == this.size &&
          other.kind == this.kind &&
          other.verifiedAt == this.verifiedAt);
}

class ContentBlobsCompanion extends UpdateCompanion<ContentBlobsData> {
  final Value<String> sha256;
  final Value<int> size;
  final Value<String> kind;
  final Value<int> verifiedAt;
  final Value<int> rowid;
  const ContentBlobsCompanion({
    this.sha256 = const Value.absent(),
    this.size = const Value.absent(),
    this.kind = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentBlobsCompanion.insert({
    required String sha256,
    required int size,
    required String kind,
    required int verifiedAt,
    this.rowid = const Value.absent(),
  }) : sha256 = Value(sha256),
       size = Value(size),
       kind = Value(kind),
       verifiedAt = Value(verifiedAt);
  static Insertable<ContentBlobsData> custom({
    Expression<String>? sha256,
    Expression<int>? size,
    Expression<String>? kind,
    Expression<int>? verifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sha256 != null) 'sha256': sha256,
      if (size != null) 'size': size,
      if (kind != null) 'kind': kind,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentBlobsCompanion copyWith({
    Value<String>? sha256,
    Value<int>? size,
    Value<String>? kind,
    Value<int>? verifiedAt,
    Value<int>? rowid,
  }) {
    return ContentBlobsCompanion(
      sha256: sha256 ?? this.sha256,
      size: size ?? this.size,
      kind: kind ?? this.kind,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<int>(verifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentBlobsCompanion(')
          ..write('sha256: $sha256, ')
          ..write('size: $size, ')
          ..write('kind: $kind, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ContentDownloads extends Table
    with TableInfo<ContentDownloads, ContentDownloadsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ContentDownloads(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> received = GeneratedColumn<int>(
    'received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> failures = GeneratedColumn<int>(
    'failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    sha256,
    size,
    kind,
    priority,
    received,
    failures,
    lastError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_downloads';
  @override
  Set<GeneratedColumn> get $primaryKey => {sha256};
  @override
  ContentDownloadsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentDownloadsData(
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      received: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received'],
      )!,
      failures: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failures'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ContentDownloads createAlias(String alias) {
    return ContentDownloads(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(sha256)'];
  @override
  bool get dontWriteConstraints => true;
}

class ContentDownloadsData extends DataClass
    implements Insertable<ContentDownloadsData> {
  final String sha256;
  final int size;
  final String kind;
  final int priority;
  final int received;
  final int failures;
  final String? lastError;
  final int createdAt;
  const ContentDownloadsData({
    required this.sha256,
    required this.size,
    required this.kind,
    required this.priority,
    required this.received,
    required this.failures,
    this.lastError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sha256'] = Variable<String>(sha256);
    map['size'] = Variable<int>(size);
    map['kind'] = Variable<String>(kind);
    map['priority'] = Variable<int>(priority);
    map['received'] = Variable<int>(received);
    map['failures'] = Variable<int>(failures);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ContentDownloadsCompanion toCompanion(bool nullToAbsent) {
    return ContentDownloadsCompanion(
      sha256: Value(sha256),
      size: Value(size),
      kind: Value(kind),
      priority: Value(priority),
      received: Value(received),
      failures: Value(failures),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory ContentDownloadsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentDownloadsData(
      sha256: serializer.fromJson<String>(json['sha256']),
      size: serializer.fromJson<int>(json['size']),
      kind: serializer.fromJson<String>(json['kind']),
      priority: serializer.fromJson<int>(json['priority']),
      received: serializer.fromJson<int>(json['received']),
      failures: serializer.fromJson<int>(json['failures']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sha256': serializer.toJson<String>(sha256),
      'size': serializer.toJson<int>(size),
      'kind': serializer.toJson<String>(kind),
      'priority': serializer.toJson<int>(priority),
      'received': serializer.toJson<int>(received),
      'failures': serializer.toJson<int>(failures),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ContentDownloadsData copyWith({
    String? sha256,
    int? size,
    String? kind,
    int? priority,
    int? received,
    int? failures,
    Value<String?> lastError = const Value.absent(),
    int? createdAt,
  }) => ContentDownloadsData(
    sha256: sha256 ?? this.sha256,
    size: size ?? this.size,
    kind: kind ?? this.kind,
    priority: priority ?? this.priority,
    received: received ?? this.received,
    failures: failures ?? this.failures,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  ContentDownloadsData copyWithCompanion(ContentDownloadsCompanion data) {
    return ContentDownloadsData(
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      size: data.size.present ? data.size.value : this.size,
      kind: data.kind.present ? data.kind.value : this.kind,
      priority: data.priority.present ? data.priority.value : this.priority,
      received: data.received.present ? data.received.value : this.received,
      failures: data.failures.present ? data.failures.value : this.failures,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentDownloadsData(')
          ..write('sha256: $sha256, ')
          ..write('size: $size, ')
          ..write('kind: $kind, ')
          ..write('priority: $priority, ')
          ..write('received: $received, ')
          ..write('failures: $failures, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sha256,
    size,
    kind,
    priority,
    received,
    failures,
    lastError,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentDownloadsData &&
          other.sha256 == this.sha256 &&
          other.size == this.size &&
          other.kind == this.kind &&
          other.priority == this.priority &&
          other.received == this.received &&
          other.failures == this.failures &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class ContentDownloadsCompanion extends UpdateCompanion<ContentDownloadsData> {
  final Value<String> sha256;
  final Value<int> size;
  final Value<String> kind;
  final Value<int> priority;
  final Value<int> received;
  final Value<int> failures;
  final Value<String?> lastError;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ContentDownloadsCompanion({
    this.sha256 = const Value.absent(),
    this.size = const Value.absent(),
    this.kind = const Value.absent(),
    this.priority = const Value.absent(),
    this.received = const Value.absent(),
    this.failures = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentDownloadsCompanion.insert({
    required String sha256,
    required int size,
    required String kind,
    required int priority,
    this.received = const Value.absent(),
    this.failures = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : sha256 = Value(sha256),
       size = Value(size),
       kind = Value(kind),
       priority = Value(priority),
       createdAt = Value(createdAt);
  static Insertable<ContentDownloadsData> custom({
    Expression<String>? sha256,
    Expression<int>? size,
    Expression<String>? kind,
    Expression<int>? priority,
    Expression<int>? received,
    Expression<int>? failures,
    Expression<String>? lastError,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sha256 != null) 'sha256': sha256,
      if (size != null) 'size': size,
      if (kind != null) 'kind': kind,
      if (priority != null) 'priority': priority,
      if (received != null) 'received': received,
      if (failures != null) 'failures': failures,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentDownloadsCompanion copyWith({
    Value<String>? sha256,
    Value<int>? size,
    Value<String>? kind,
    Value<int>? priority,
    Value<int>? received,
    Value<int>? failures,
    Value<String?>? lastError,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ContentDownloadsCompanion(
      sha256: sha256 ?? this.sha256,
      size: size ?? this.size,
      kind: kind ?? this.kind,
      priority: priority ?? this.priority,
      received: received ?? this.received,
      failures: failures ?? this.failures,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (received.present) {
      map['received'] = Variable<int>(received.value);
    }
    if (failures.present) {
      map['failures'] = Variable<int>(failures.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentDownloadsCompanion(')
          ..write('sha256: $sha256, ')
          ..write('size: $size, ')
          ..write('kind: $kind, ')
          ..write('priority: $priority, ')
          ..write('received: $received, ')
          ..write('failures: $failures, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV4 extends GeneratedDatabase {
  DatabaseAtV4(QueryExecutor e) : super(e);
  late final Profiles profiles = Profiles(this);
  late final LessonProgress lessonProgress = LessonProgress(this);
  late final LessonPartProgress lessonPartProgress = LessonPartProgress(this);
  late final OwnedItems ownedItems = OwnedItems(this);
  late final Attempts attempts = Attempts(this);
  late final ConceptMastery conceptMastery = ConceptMastery(this);
  late final Bookmarks bookmarks = Bookmarks(this);
  late final AppSettings appSettings = AppSettings(this);
  late final ContentManifests contentManifests = ContentManifests(this);
  late final ContentLessons contentLessons = ContentLessons(this);
  late final ContentBlobs contentBlobs = ContentBlobs(this);
  late final ContentDownloads contentDownloads = ContentDownloads(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    lessonProgress,
    lessonPartProgress,
    ownedItems,
    attempts,
    conceptMastery,
    bookmarks,
    appSettings,
    contentManifests,
    contentLessons,
    contentBlobs,
    contentDownloads,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lesson_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lesson_part_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('owned_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('concept_mastery', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  int get schemaVersion => 4;
}
