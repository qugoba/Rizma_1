// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    check: () => ComparableExpr(grade).isBetweenValues(1, 12),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProfileColor, String> color =
      GeneratedColumn<String>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProfileColor>($ProfilesTable.$convertercolor);
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta(
    'pinSalt',
  );
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentCodeMeta = const VerificationMeta(
    'studentCode',
  );
  @override
  late final GeneratedColumn<String> studentCode = GeneratedColumn<String>(
    'student_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _classCodeMeta = const VerificationMeta(
    'classCode',
  );
  @override
  late final GeneratedColumn<String> classCode = GeneratedColumn<String>(
    'class_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equippedMeta = const VerificationMeta(
    'equipped',
  );
  @override
  late final GeneratedColumn<String> equipped = GeneratedColumn<String>(
    'equipped',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta(
    'lastActiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
    'last_active_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('pin_salt')) {
      context.handle(
        _pinSaltMeta,
        pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta),
      );
    }
    if (data.containsKey('student_code')) {
      context.handle(
        _studentCodeMeta,
        studentCode.isAcceptableOrUnknown(
          data['student_code']!,
          _studentCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentCodeMeta);
    }
    if (data.containsKey('class_code')) {
      context.handle(
        _classCodeMeta,
        classCode.isAcceptableOrUnknown(data['class_code']!, _classCodeMeta),
      );
    }
    if (data.containsKey('equipped')) {
      context.handle(
        _equippedMeta,
        equipped.isAcceptableOrUnknown(data['equipped']!, _equippedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(
          data['last_active_at']!,
          _lastActiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActiveAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
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
      color: $ProfilesTable.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color'],
        )!,
      ),
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
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
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
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProfileColor, String, String> $convertercolor =
      const EnumNameConverter<ProfileColor>(ProfileColor.values);
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String name;
  final int grade;
  final ProfileColor color;

  /// SHA-256 للرمز السري مع salt عشوائي. null = لا رمز سري. لا يُرفع.
  final String? pinHash;
  final String? pinSalt;
  final String studentCode;
  final String? classCode;

  /// معرّفات قطع الخزانة المرتداة، مفصولة بفواصل (فارغ = لا شيء).
  final String equipped;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  /// رقم النسخة على الخادم؛ يرفعه الخادم مع كل تعديل مقبول. 0 = لم يُرفع قط.
  final int revision;

  /// يزيد واحدًا مع كل تعديل محلي على ما يُرفع؛ يحسم سباق «عُدّل أثناء الرفع».
  final int localVersion;

  /// متى رُفعت آخر نسخة. null = فيه تعديل لم يُرفع بعد.
  final DateTime? syncedAt;
  const Profile({
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
    {
      map['color'] = Variable<String>(
        $ProfilesTable.$convertercolor.toSql(color),
      );
    }
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
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    map['revision'] = Variable<int>(revision);
    map['local_version'] = Variable<int>(localVersion);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
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

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      grade: serializer.fromJson<int>(json['grade']),
      color: $ProfilesTable.$convertercolor.fromJson(
        serializer.fromJson<String>(json['color']),
      ),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      pinSalt: serializer.fromJson<String?>(json['pinSalt']),
      studentCode: serializer.fromJson<String>(json['studentCode']),
      classCode: serializer.fromJson<String?>(json['classCode']),
      equipped: serializer.fromJson<String>(json['equipped']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastActiveAt: serializer.fromJson<DateTime>(json['lastActiveAt']),
      revision: serializer.fromJson<int>(json['revision']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'grade': serializer.toJson<int>(grade),
      'color': serializer.toJson<String>(
        $ProfilesTable.$convertercolor.toJson(color),
      ),
      'pinHash': serializer.toJson<String?>(pinHash),
      'pinSalt': serializer.toJson<String?>(pinSalt),
      'studentCode': serializer.toJson<String>(studentCode),
      'classCode': serializer.toJson<String?>(classCode),
      'equipped': serializer.toJson<String>(equipped),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastActiveAt': serializer.toJson<DateTime>(lastActiveAt),
      'revision': serializer.toJson<int>(revision),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    int? grade,
    ProfileColor? color,
    Value<String?> pinHash = const Value.absent(),
    Value<String?> pinSalt = const Value.absent(),
    String? studentCode,
    Value<String?> classCode = const Value.absent(),
    String? equipped,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? revision,
    int? localVersion,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => Profile(
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
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
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
    return (StringBuffer('Profile(')
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
      (other is Profile &&
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

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> grade;
  final Value<ProfileColor> color;
  final Value<String?> pinHash;
  final Value<String?> pinSalt;
  final Value<String> studentCode;
  final Value<String?> classCode;
  final Value<String> equipped;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastActiveAt;
  final Value<int> revision;
  final Value<int> localVersion;
  final Value<DateTime?> syncedAt;
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
    required ProfileColor color,
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    required String studentCode,
    this.classCode = const Value.absent(),
    this.equipped = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastActiveAt,
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
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? grade,
    Expression<String>? color,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<String>? studentCode,
    Expression<String>? classCode,
    Expression<String>? equipped,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastActiveAt,
    Expression<int>? revision,
    Expression<int>? localVersion,
    Expression<DateTime>? syncedAt,
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
    Value<ProfileColor>? color,
    Value<String?>? pinHash,
    Value<String?>? pinSalt,
    Value<String>? studentCode,
    Value<String?>? classCode,
    Value<String>? equipped,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastActiveAt,
    Value<int>? revision,
    Value<int>? localVersion,
    Value<DateTime?>? syncedAt,
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
      map['color'] = Variable<String>(
        $ProfilesTable.$convertercolor.toSql(color.value),
      );
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
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
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

class $LessonProgressTable extends LessonProgress
    with TableInfo<$LessonProgressTable, LessonProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LessonStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LessonStatus>($LessonProgressTable.$converterstatus);
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  VerificationContext validateIntegrity(
    Insertable<LessonProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, lessonId};
  @override
  LessonProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressEntry(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      status: $LessonProgressTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LessonProgressTable createAlias(String alias) {
    return $LessonProgressTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LessonStatus, String, String> $converterstatus =
      const EnumNameConverter<LessonStatus>(LessonStatus.values);
}

class LessonProgressEntry extends DataClass
    implements Insertable<LessonProgressEntry> {
  final String profileId;
  final String lessonId;
  final LessonStatus status;
  final double progress;
  final DateTime updatedAt;
  const LessonProgressEntry({
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
    {
      map['status'] = Variable<String>(
        $LessonProgressTable.$converterstatus.toSql(status),
      );
    }
    map['progress'] = Variable<double>(progress);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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

  factory LessonProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressEntry(
      profileId: serializer.fromJson<String>(json['profileId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      status: $LessonProgressTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      progress: serializer.fromJson<double>(json['progress']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'lessonId': serializer.toJson<String>(lessonId),
      'status': serializer.toJson<String>(
        $LessonProgressTable.$converterstatus.toJson(status),
      ),
      'progress': serializer.toJson<double>(progress),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LessonProgressEntry copyWith({
    String? profileId,
    String? lessonId,
    LessonStatus? status,
    double? progress,
    DateTime? updatedAt,
  }) => LessonProgressEntry(
    profileId: profileId ?? this.profileId,
    lessonId: lessonId ?? this.lessonId,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LessonProgressEntry copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressEntry(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressEntry(')
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
      (other is LessonProgressEntry &&
          other.profileId == this.profileId &&
          other.lessonId == this.lessonId &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.updatedAt == this.updatedAt);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressEntry> {
  final Value<String> profileId;
  final Value<String> lessonId;
  final Value<LessonStatus> status;
  final Value<double> progress;
  final Value<DateTime> updatedAt;
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
    required LessonStatus status,
    this.progress = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       lessonId = Value(lessonId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<LessonProgressEntry> custom({
    Expression<String>? profileId,
    Expression<String>? lessonId,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<DateTime>? updatedAt,
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
    Value<LessonStatus>? status,
    Value<double>? progress,
    Value<DateTime>? updatedAt,
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
      map['status'] = Variable<String>(
        $LessonProgressTable.$converterstatus.toSql(status.value),
      );
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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

class $LessonPartProgressTable extends LessonPartProgress
    with TableInfo<$LessonPartProgressTable, LessonPartEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonPartProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LessonPart, String> part =
      GeneratedColumn<String>(
        'part',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LessonPart>($LessonPartProgressTable.$converterpart);
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  VerificationContext validateIntegrity(
    Insertable<LessonPartEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, lessonId, part};
  @override
  LessonPartEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonPartEntry(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      part: $LessonPartProgressTable.$converterpart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}part'],
        )!,
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $LessonPartProgressTable createAlias(String alias) {
    return $LessonPartProgressTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LessonPart, String, String> $converterpart =
      const EnumNameConverter<LessonPart>(LessonPart.values);
}

class LessonPartEntry extends DataClass implements Insertable<LessonPartEntry> {
  final String profileId;
  final String lessonId;
  final LessonPart part;
  final DateTime completedAt;

  /// متى رُفع إلى الخادم. null = لم يُرفع بعد. حدث لا يتغيّر بعد حفظه.
  final DateTime? syncedAt;
  const LessonPartEntry({
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
    {
      map['part'] = Variable<String>(
        $LessonPartProgressTable.$converterpart.toSql(part),
      );
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
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

  factory LessonPartEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonPartEntry(
      profileId: serializer.fromJson<String>(json['profileId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      part: $LessonPartProgressTable.$converterpart.fromJson(
        serializer.fromJson<String>(json['part']),
      ),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'lessonId': serializer.toJson<String>(lessonId),
      'part': serializer.toJson<String>(
        $LessonPartProgressTable.$converterpart.toJson(part),
      ),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LessonPartEntry copyWith({
    String? profileId,
    String? lessonId,
    LessonPart? part,
    DateTime? completedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LessonPartEntry(
    profileId: profileId ?? this.profileId,
    lessonId: lessonId ?? this.lessonId,
    part: part ?? this.part,
    completedAt: completedAt ?? this.completedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LessonPartEntry copyWithCompanion(LessonPartProgressCompanion data) {
    return LessonPartEntry(
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
    return (StringBuffer('LessonPartEntry(')
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
      (other is LessonPartEntry &&
          other.profileId == this.profileId &&
          other.lessonId == this.lessonId &&
          other.part == this.part &&
          other.completedAt == this.completedAt &&
          other.syncedAt == this.syncedAt);
}

class LessonPartProgressCompanion extends UpdateCompanion<LessonPartEntry> {
  final Value<String> profileId;
  final Value<String> lessonId;
  final Value<LessonPart> part;
  final Value<DateTime> completedAt;
  final Value<DateTime?> syncedAt;
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
    required LessonPart part,
    required DateTime completedAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       lessonId = Value(lessonId),
       part = Value(part),
       completedAt = Value(completedAt);
  static Insertable<LessonPartEntry> custom({
    Expression<String>? profileId,
    Expression<String>? lessonId,
    Expression<String>? part,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? syncedAt,
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
    Value<LessonPart>? part,
    Value<DateTime>? completedAt,
    Value<DateTime?>? syncedAt,
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
      map['part'] = Variable<String>(
        $LessonPartProgressTable.$converterpart.toSql(part.value),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
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

class $OwnedItemsTable extends OwnedItems
    with TableInfo<$OwnedItemsTable, OwnedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
    'acquired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  VerificationContext validateIntegrity(
    Insertable<OwnedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_acquiredAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, itemId};
  @override
  OwnedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedItem(
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
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $OwnedItemsTable createAlias(String alias) {
    return $OwnedItemsTable(attachedDatabase, alias);
  }
}

class OwnedItem extends DataClass implements Insertable<OwnedItem> {
  final String profileId;
  final String itemId;
  final int cost;
  final DateTime acquiredAt;

  /// متى رُفع إلى الخادم. null = لم يُرفع بعد. حدث لا يتغيّر بعد حفظه.
  final DateTime? syncedAt;
  const OwnedItem({
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
    map['acquired_at'] = Variable<DateTime>(acquiredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
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

  factory OwnedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedItem(
      profileId: serializer.fromJson<String>(json['profileId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      cost: serializer.fromJson<int>(json['cost']),
      acquiredAt: serializer.fromJson<DateTime>(json['acquiredAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'itemId': serializer.toJson<String>(itemId),
      'cost': serializer.toJson<int>(cost),
      'acquiredAt': serializer.toJson<DateTime>(acquiredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  OwnedItem copyWith({
    String? profileId,
    String? itemId,
    int? cost,
    DateTime? acquiredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => OwnedItem(
    profileId: profileId ?? this.profileId,
    itemId: itemId ?? this.itemId,
    cost: cost ?? this.cost,
    acquiredAt: acquiredAt ?? this.acquiredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  OwnedItem copyWithCompanion(OwnedItemsCompanion data) {
    return OwnedItem(
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
    return (StringBuffer('OwnedItem(')
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
      (other is OwnedItem &&
          other.profileId == this.profileId &&
          other.itemId == this.itemId &&
          other.cost == this.cost &&
          other.acquiredAt == this.acquiredAt &&
          other.syncedAt == this.syncedAt);
}

class OwnedItemsCompanion extends UpdateCompanion<OwnedItem> {
  final Value<String> profileId;
  final Value<String> itemId;
  final Value<int> cost;
  final Value<DateTime> acquiredAt;
  final Value<DateTime?> syncedAt;
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
    required DateTime acquiredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       itemId = Value(itemId),
       cost = Value(cost),
       acquiredAt = Value(acquiredAt);
  static Insertable<OwnedItem> custom({
    Expression<String>? profileId,
    Expression<String>? itemId,
    Expression<int>? cost,
    Expression<DateTime>? acquiredAt,
    Expression<DateTime>? syncedAt,
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
    Value<DateTime>? acquiredAt,
    Value<DateTime?>? syncedAt,
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
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
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

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AttemptKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AttemptKind>($AttemptsTable.$converterkind);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsEarnedMeta = const VerificationMeta(
    'starsEarned',
  );
  @override
  late final GeneratedColumn<int> starsEarned = GeneratedColumn<int>(
    'stars_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hintsUsedMeta = const VerificationMeta(
    'hintsUsed',
  );
  @override
  late final GeneratedColumn<int> hintsUsed = GeneratedColumn<int>(
    'hints_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('stars_earned')) {
      context.handle(
        _starsEarnedMeta,
        starsEarned.isAcceptableOrUnknown(
          data['stars_earned']!,
          _starsEarnedMeta,
        ),
      );
    }
    if (data.containsKey('hints_used')) {
      context.handle(
        _hintsUsedMeta,
        hintsUsed.isAcceptableOrUnknown(data['hints_used']!, _hintsUsedMeta),
      );
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
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
      kind: $AttemptsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
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
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AttemptKind, String, String> $converterkind =
      const EnumNameConverter<AttemptKind>(AttemptKind.values);
}

class Attempt extends DataClass implements Insertable<Attempt> {
  /// UUID يُنشأ على الهاتف (لا رقم تسلسلي: هاتفان قد يعطيان الرقم نفسه).
  final String id;
  final String profileId;
  final String activityId;
  final AttemptKind kind;
  final int score;
  final int total;
  final int starsEarned;

  /// عدد التلميحات المستعملة في الجولة.
  final int hintsUsed;

  /// نتيجة كل سؤال (JSON): معرّفه وبصمة محتواه ونوعه ومفهومه وصحّته وتلميحاته.
  /// منها تُبنى شاشات النتيجة وخطة المراجعة، ويُعاد حساب الإتقان. null للألعاب.
  final String? detailsJson;

  /// وقت الهاتف عند انتهاء الجولة.
  final DateTime createdAt;

  /// متى رُفعت إلى الخادم. null = لم تُرفع بعد.
  final DateTime? syncedAt;

  /// وقت استلام الخادم لها (من ساعته هو)، يصل مع السحب. null قبل ذلك.
  final DateTime? serverReceivedAt;
  const Attempt({
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
    {
      map['kind'] = Variable<String>($AttemptsTable.$converterkind.toSql(kind));
    }
    map['score'] = Variable<int>(score);
    map['total'] = Variable<int>(total);
    map['stars_earned'] = Variable<int>(starsEarned);
    map['hints_used'] = Variable<int>(hintsUsed);
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
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

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      activityId: serializer.fromJson<String>(json['activityId']),
      kind: $AttemptsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      score: serializer.fromJson<int>(json['score']),
      total: serializer.fromJson<int>(json['total']),
      starsEarned: serializer.fromJson<int>(json['starsEarned']),
      hintsUsed: serializer.fromJson<int>(json['hintsUsed']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'activityId': serializer.toJson<String>(activityId),
      'kind': serializer.toJson<String>(
        $AttemptsTable.$converterkind.toJson(kind),
      ),
      'score': serializer.toJson<int>(score),
      'total': serializer.toJson<int>(total),
      'starsEarned': serializer.toJson<int>(starsEarned),
      'hintsUsed': serializer.toJson<int>(hintsUsed),
      'detailsJson': serializer.toJson<String?>(detailsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
    };
  }

  Attempt copyWith({
    String? id,
    String? profileId,
    String? activityId,
    AttemptKind? kind,
    int? score,
    int? total,
    int? starsEarned,
    int? hintsUsed,
    Value<String?> detailsJson = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
    Value<DateTime?> serverReceivedAt = const Value.absent(),
  }) => Attempt(
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
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
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
    return (StringBuffer('Attempt(')
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
      (other is Attempt &&
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

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> activityId;
  final Value<AttemptKind> kind;
  final Value<int> score;
  final Value<int> total;
  final Value<int> starsEarned;
  final Value<int> hintsUsed;
  final Value<String?> detailsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  final Value<DateTime?> serverReceivedAt;
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
    required AttemptKind kind,
    required int score,
    required int total,
    this.starsEarned = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.detailsJson = const Value.absent(),
    required DateTime createdAt,
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
  static Insertable<Attempt> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? activityId,
    Expression<String>? kind,
    Expression<int>? score,
    Expression<int>? total,
    Expression<int>? starsEarned,
    Expression<int>? hintsUsed,
    Expression<String>? detailsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? serverReceivedAt,
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
    Value<AttemptKind>? kind,
    Value<int>? score,
    Value<int>? total,
    Value<int>? starsEarned,
    Value<int>? hintsUsed,
    Value<String?>? detailsJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? syncedAt,
    Value<DateTime?>? serverReceivedAt,
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
      map['kind'] = Variable<String>(
        $AttemptsTable.$converterkind.toSql(kind.value),
      );
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
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
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

class $ConceptMasteryTable extends ConceptMastery
    with TableInfo<$ConceptMasteryTable, ConceptMasteryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConceptMasteryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _conceptIdMeta = const VerificationMeta(
    'conceptId',
  );
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
    'concept_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _masteryMeta = const VerificationMeta(
    'mastery',
  );
  @override
  late final GeneratedColumn<double> mastery = GeneratedColumn<double>(
    'mastery',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  VerificationContext validateIntegrity(
    Insertable<ConceptMasteryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('concept_id')) {
      context.handle(
        _conceptIdMeta,
        conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptIdMeta);
    }
    if (data.containsKey('mastery')) {
      context.handle(
        _masteryMeta,
        mastery.isAcceptableOrUnknown(data['mastery']!, _masteryMeta),
      );
    } else if (isInserting) {
      context.missing(_masteryMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, conceptId};
  @override
  ConceptMasteryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConceptMasteryEntry(
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
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConceptMasteryTable createAlias(String alias) {
    return $ConceptMasteryTable(attachedDatabase, alias);
  }
}

class ConceptMasteryEntry extends DataClass
    implements Insertable<ConceptMasteryEntry> {
  final String profileId;
  final String conceptId;
  final double mastery;
  final DateTime updatedAt;
  const ConceptMasteryEntry({
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
    map['updated_at'] = Variable<DateTime>(updatedAt);
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

  factory ConceptMasteryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConceptMasteryEntry(
      profileId: serializer.fromJson<String>(json['profileId']),
      conceptId: serializer.fromJson<String>(json['conceptId']),
      mastery: serializer.fromJson<double>(json['mastery']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'conceptId': serializer.toJson<String>(conceptId),
      'mastery': serializer.toJson<double>(mastery),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConceptMasteryEntry copyWith({
    String? profileId,
    String? conceptId,
    double? mastery,
    DateTime? updatedAt,
  }) => ConceptMasteryEntry(
    profileId: profileId ?? this.profileId,
    conceptId: conceptId ?? this.conceptId,
    mastery: mastery ?? this.mastery,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ConceptMasteryEntry copyWithCompanion(ConceptMasteryCompanion data) {
    return ConceptMasteryEntry(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      mastery: data.mastery.present ? data.mastery.value : this.mastery,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConceptMasteryEntry(')
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
      (other is ConceptMasteryEntry &&
          other.profileId == this.profileId &&
          other.conceptId == this.conceptId &&
          other.mastery == this.mastery &&
          other.updatedAt == this.updatedAt);
}

class ConceptMasteryCompanion extends UpdateCompanion<ConceptMasteryEntry> {
  final Value<String> profileId;
  final Value<String> conceptId;
  final Value<double> mastery;
  final Value<DateTime> updatedAt;
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
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       conceptId = Value(conceptId),
       mastery = Value(mastery),
       updatedAt = Value(updatedAt);
  static Insertable<ConceptMasteryEntry> custom({
    Expression<String>? profileId,
    Expression<String>? conceptId,
    Expression<double>? mastery,
    Expression<DateTime>? updatedAt,
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
    Value<DateTime>? updatedAt,
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
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _removedAtMeta = const VerificationMeta(
    'removedAt',
  );
  @override
  late final GeneratedColumn<DateTime> removedAt = GeneratedColumn<DateTime>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('removed_at')) {
      context.handle(
        _removedAtMeta,
        removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, lessonId};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}removed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final String profileId;
  final String lessonId;

  /// متى أُزيل. null = محفوظ حاليًا.
  final DateTime? removedAt;

  /// وقت آخر تعديل على الهاتف (للترتيب في الواجهة فقط، لا لحسم التعارض).
  final DateTime updatedAt;

  /// يزيد واحدًا مع كل تعديل محلي.
  final int localVersion;

  /// متى رُفع آخر تعديل. null = فيه تعديل لم يُرفع بعد.
  final DateTime? syncedAt;
  const Bookmark({
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
      map['removed_at'] = Variable<DateTime>(removedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['local_version'] = Variable<int>(localVersion);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
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

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      profileId: serializer.fromJson<String>(json['profileId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'lessonId': serializer.toJson<String>(lessonId),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  Bookmark copyWith({
    String? profileId,
    String? lessonId,
    Value<DateTime?> removedAt = const Value.absent(),
    DateTime? updatedAt,
    int? localVersion,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => Bookmark(
    profileId: profileId ?? this.profileId,
    lessonId: lessonId ?? this.lessonId,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    localVersion: localVersion ?? this.localVersion,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
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
    return (StringBuffer('Bookmark(')
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
      (other is Bookmark &&
          other.profileId == this.profileId &&
          other.lessonId == this.lessonId &&
          other.removedAt == this.removedAt &&
          other.updatedAt == this.updatedAt &&
          other.localVersion == this.localVersion &&
          other.syncedAt == this.syncedAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> profileId;
  final Value<String> lessonId;
  final Value<DateTime?> removedAt;
  final Value<DateTime> updatedAt;
  final Value<int> localVersion;
  final Value<DateTime?> syncedAt;
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
    required DateTime updatedAt,
    this.localVersion = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       lessonId = Value(lessonId),
       updatedAt = Value(updatedAt);
  static Insertable<Bookmark> custom({
    Expression<String>? profileId,
    Expression<String>? lessonId,
    Expression<DateTime>? removedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? localVersion,
    Expression<DateTime>? syncedAt,
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
    Value<DateTime?>? removedAt,
    Value<DateTime>? updatedAt,
    Value<int>? localVersion,
    Value<DateTime?>? syncedAt,
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
      map['removed_at'] = Variable<DateTime>(removedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
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

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
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
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
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

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
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
  static Insertable<AppSetting> custom({
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

class $ContentManifestsTable extends ContentManifests
    with TableInfo<$ContentManifestsTable, ContentManifest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentManifestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogSha256Meta = const VerificationMeta(
    'catalogSha256',
  );
  @override
  late final GeneratedColumn<String> catalogSha256 = GeneratedColumn<String>(
    'catalog_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingCatalogSha256Meta =
      const VerificationMeta('pendingCatalogSha256');
  @override
  late final GeneratedColumn<String> pendingCatalogSha256 =
      GeneratedColumn<String>(
        'pending_catalog_sha256',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    grade,
    sequence,
    body,
    signature,
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
  VerificationContext validateIntegrity(
    Insertable<ContentManifest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    }
    if (data.containsKey('catalog_sha256')) {
      context.handle(
        _catalogSha256Meta,
        catalogSha256.isAcceptableOrUnknown(
          data['catalog_sha256']!,
          _catalogSha256Meta,
        ),
      );
    }
    if (data.containsKey('pending_catalog_sha256')) {
      context.handle(
        _pendingCatalogSha256Meta,
        pendingCatalogSha256.isAcceptableOrUnknown(
          data['pending_catalog_sha256']!,
          _pendingCatalogSha256Meta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {grade};
  @override
  ContentManifest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentManifest(
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
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      ),
      catalogSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_sha256'],
      ),
      pendingCatalogSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_catalog_sha256'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ContentManifestsTable createAlias(String alias) {
    return $ContentManifestsTable(attachedDatabase, alias);
  }
}

class ContentManifest extends DataClass implements Insertable<ContentManifest> {
  final int grade;

  /// يزيد مع كل نشر. فهرس رقمه أقل من هذا يُرفض.
  final int sequence;

  /// نص الفهرس كما وصل وفُحص توقيعه.
  final String body;

  /// توقيعه (base64) كما وصل، ليُرسل مع الفهرس إلى هاتف آخر (ADR 003؛
  /// الإصدار 6). null لفهرس قُبل قبل ذلك: يُشارك بعد الفحص التالي.
  final String? signature;

  /// بصمة الكتالوج المفعّل لهذا الصف. null = كتالوج التطبيق.
  final String? catalogSha256;

  /// كتالوج الفهرس الأحدث، ينتظر اكتمال تنزيله ليصبح المفعّل.
  final String? pendingCatalogSha256;
  final DateTime fetchedAt;
  const ContentManifest({
    required this.grade,
    required this.sequence,
    required this.body,
    this.signature,
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
    if (!nullToAbsent || signature != null) {
      map['signature'] = Variable<String>(signature);
    }
    if (!nullToAbsent || catalogSha256 != null) {
      map['catalog_sha256'] = Variable<String>(catalogSha256);
    }
    if (!nullToAbsent || pendingCatalogSha256 != null) {
      map['pending_catalog_sha256'] = Variable<String>(pendingCatalogSha256);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ContentManifestsCompanion toCompanion(bool nullToAbsent) {
    return ContentManifestsCompanion(
      grade: Value(grade),
      sequence: Value(sequence),
      body: Value(body),
      signature: signature == null && nullToAbsent
          ? const Value.absent()
          : Value(signature),
      catalogSha256: catalogSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogSha256),
      pendingCatalogSha256: pendingCatalogSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingCatalogSha256),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ContentManifest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentManifest(
      grade: serializer.fromJson<int>(json['grade']),
      sequence: serializer.fromJson<int>(json['sequence']),
      body: serializer.fromJson<String>(json['body']),
      signature: serializer.fromJson<String?>(json['signature']),
      catalogSha256: serializer.fromJson<String?>(json['catalogSha256']),
      pendingCatalogSha256: serializer.fromJson<String?>(
        json['pendingCatalogSha256'],
      ),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'grade': serializer.toJson<int>(grade),
      'sequence': serializer.toJson<int>(sequence),
      'body': serializer.toJson<String>(body),
      'signature': serializer.toJson<String?>(signature),
      'catalogSha256': serializer.toJson<String?>(catalogSha256),
      'pendingCatalogSha256': serializer.toJson<String?>(pendingCatalogSha256),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ContentManifest copyWith({
    int? grade,
    int? sequence,
    String? body,
    Value<String?> signature = const Value.absent(),
    Value<String?> catalogSha256 = const Value.absent(),
    Value<String?> pendingCatalogSha256 = const Value.absent(),
    DateTime? fetchedAt,
  }) => ContentManifest(
    grade: grade ?? this.grade,
    sequence: sequence ?? this.sequence,
    body: body ?? this.body,
    signature: signature.present ? signature.value : this.signature,
    catalogSha256: catalogSha256.present
        ? catalogSha256.value
        : this.catalogSha256,
    pendingCatalogSha256: pendingCatalogSha256.present
        ? pendingCatalogSha256.value
        : this.pendingCatalogSha256,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ContentManifest copyWithCompanion(ContentManifestsCompanion data) {
    return ContentManifest(
      grade: data.grade.present ? data.grade.value : this.grade,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      body: data.body.present ? data.body.value : this.body,
      signature: data.signature.present ? data.signature.value : this.signature,
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
    return (StringBuffer('ContentManifest(')
          ..write('grade: $grade, ')
          ..write('sequence: $sequence, ')
          ..write('body: $body, ')
          ..write('signature: $signature, ')
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
    signature,
    catalogSha256,
    pendingCatalogSha256,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentManifest &&
          other.grade == this.grade &&
          other.sequence == this.sequence &&
          other.body == this.body &&
          other.signature == this.signature &&
          other.catalogSha256 == this.catalogSha256 &&
          other.pendingCatalogSha256 == this.pendingCatalogSha256 &&
          other.fetchedAt == this.fetchedAt);
}

class ContentManifestsCompanion extends UpdateCompanion<ContentManifest> {
  final Value<int> grade;
  final Value<int> sequence;
  final Value<String> body;
  final Value<String?> signature;
  final Value<String?> catalogSha256;
  final Value<String?> pendingCatalogSha256;
  final Value<DateTime> fetchedAt;
  const ContentManifestsCompanion({
    this.grade = const Value.absent(),
    this.sequence = const Value.absent(),
    this.body = const Value.absent(),
    this.signature = const Value.absent(),
    this.catalogSha256 = const Value.absent(),
    this.pendingCatalogSha256 = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  ContentManifestsCompanion.insert({
    this.grade = const Value.absent(),
    required int sequence,
    required String body,
    this.signature = const Value.absent(),
    this.catalogSha256 = const Value.absent(),
    this.pendingCatalogSha256 = const Value.absent(),
    required DateTime fetchedAt,
  }) : sequence = Value(sequence),
       body = Value(body),
       fetchedAt = Value(fetchedAt);
  static Insertable<ContentManifest> custom({
    Expression<int>? grade,
    Expression<int>? sequence,
    Expression<String>? body,
    Expression<String>? signature,
    Expression<String>? catalogSha256,
    Expression<String>? pendingCatalogSha256,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (grade != null) 'grade': grade,
      if (sequence != null) 'sequence': sequence,
      if (body != null) 'body': body,
      if (signature != null) 'signature': signature,
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
    Value<String?>? signature,
    Value<String?>? catalogSha256,
    Value<String?>? pendingCatalogSha256,
    Value<DateTime>? fetchedAt,
  }) {
    return ContentManifestsCompanion(
      grade: grade ?? this.grade,
      sequence: sequence ?? this.sequence,
      body: body ?? this.body,
      signature: signature ?? this.signature,
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
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
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
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentManifestsCompanion(')
          ..write('grade: $grade, ')
          ..write('sequence: $sequence, ')
          ..write('body: $body, ')
          ..write('signature: $signature, ')
          ..write('catalogSha256: $catalogSha256, ')
          ..write('pendingCatalogSha256: $pendingCatalogSha256, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $ContentLessonsTable extends ContentLessons
    with TableInfo<$ContentLessonsTable, ContentLesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentLessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _contentFormatMeta = const VerificationMeta(
    'contentFormat',
  );
  @override
  late final GeneratedColumn<int> contentFormat = GeneratedColumn<int>(
    'content_format',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _filesMeta = const VerificationMeta('files');
  @override
  late final GeneratedColumn<String> files = GeneratedColumn<String>(
    'files',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _videoSha256Meta = const VerificationMeta(
    'videoSha256',
  );
  @override
  late final GeneratedColumn<String> videoSha256 = GeneratedColumn<String>(
    'video_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoSizeMeta = const VerificationMeta(
    'videoSize',
  );
  @override
  late final GeneratedColumn<int> videoSize = GeneratedColumn<int>(
    'video_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentsMeta = const VerificationMeta(
    'attachments',
  );
  @override
  late final GeneratedColumn<String> attachments = GeneratedColumn<String>(
    'attachments',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingVersionMeta = const VerificationMeta(
    'pendingVersion',
  );
  @override
  late final GeneratedColumn<int> pendingVersion = GeneratedColumn<int>(
    'pending_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingContentFormatMeta =
      const VerificationMeta('pendingContentFormat');
  @override
  late final GeneratedColumn<int> pendingContentFormat = GeneratedColumn<int>(
    'pending_content_format',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingFilesMeta = const VerificationMeta(
    'pendingFiles',
  );
  @override
  late final GeneratedColumn<String> pendingFiles = GeneratedColumn<String>(
    'pending_files',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingVideoSha256Meta =
      const VerificationMeta('pendingVideoSha256');
  @override
  late final GeneratedColumn<String> pendingVideoSha256 =
      GeneratedColumn<String>(
        'pending_video_sha256',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pendingVideoSizeMeta = const VerificationMeta(
    'pendingVideoSize',
  );
  @override
  late final GeneratedColumn<int> pendingVideoSize = GeneratedColumn<int>(
    'pending_video_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingAttachmentsMeta =
      const VerificationMeta('pendingAttachments');
  @override
  late final GeneratedColumn<String> pendingAttachments =
      GeneratedColumn<String>(
        'pending_attachments',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    lessonId,
    version,
    contentFormat,
    files,
    videoSha256,
    videoSize,
    attachments,
    installedAt,
    pendingVersion,
    pendingContentFormat,
    pendingFiles,
    pendingVideoSha256,
    pendingVideoSize,
    pendingAttachments,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentLesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('content_format')) {
      context.handle(
        _contentFormatMeta,
        contentFormat.isAcceptableOrUnknown(
          data['content_format']!,
          _contentFormatMeta,
        ),
      );
    }
    if (data.containsKey('files')) {
      context.handle(
        _filesMeta,
        files.isAcceptableOrUnknown(data['files']!, _filesMeta),
      );
    }
    if (data.containsKey('video_sha256')) {
      context.handle(
        _videoSha256Meta,
        videoSha256.isAcceptableOrUnknown(
          data['video_sha256']!,
          _videoSha256Meta,
        ),
      );
    }
    if (data.containsKey('video_size')) {
      context.handle(
        _videoSizeMeta,
        videoSize.isAcceptableOrUnknown(data['video_size']!, _videoSizeMeta),
      );
    }
    if (data.containsKey('attachments')) {
      context.handle(
        _attachmentsMeta,
        attachments.isAcceptableOrUnknown(
          data['attachments']!,
          _attachmentsMeta,
        ),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending_version')) {
      context.handle(
        _pendingVersionMeta,
        pendingVersion.isAcceptableOrUnknown(
          data['pending_version']!,
          _pendingVersionMeta,
        ),
      );
    }
    if (data.containsKey('pending_content_format')) {
      context.handle(
        _pendingContentFormatMeta,
        pendingContentFormat.isAcceptableOrUnknown(
          data['pending_content_format']!,
          _pendingContentFormatMeta,
        ),
      );
    }
    if (data.containsKey('pending_files')) {
      context.handle(
        _pendingFilesMeta,
        pendingFiles.isAcceptableOrUnknown(
          data['pending_files']!,
          _pendingFilesMeta,
        ),
      );
    }
    if (data.containsKey('pending_video_sha256')) {
      context.handle(
        _pendingVideoSha256Meta,
        pendingVideoSha256.isAcceptableOrUnknown(
          data['pending_video_sha256']!,
          _pendingVideoSha256Meta,
        ),
      );
    }
    if (data.containsKey('pending_video_size')) {
      context.handle(
        _pendingVideoSizeMeta,
        pendingVideoSize.isAcceptableOrUnknown(
          data['pending_video_size']!,
          _pendingVideoSizeMeta,
        ),
      );
    }
    if (data.containsKey('pending_attachments')) {
      context.handle(
        _pendingAttachmentsMeta,
        pendingAttachments.isAcceptableOrUnknown(
          data['pending_attachments']!,
          _pendingAttachmentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  ContentLesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentLesson(
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
      attachments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachments'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
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
      pendingAttachments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_attachments'],
      ),
    );
  }

  @override
  $ContentLessonsTable createAlias(String alias) {
    return $ContentLessonsTable(attachedDatabase, alias);
  }
}

class ContentLesson extends DataClass implements Insertable<ContentLesson> {
  final String lessonId;

  /// النسخة المثبّتة. 0 = لا نسخة منزَّلة بعد (نسخة التطبيق تُعرض).
  final int version;
  final int contentFormat;

  /// ملفات النسخة المثبّتة: JSON `{path: sha256}`.
  final String files;

  /// فيديو النسخة المثبّتة (إن وُجد في الفهرس، نُزِّل أم لا).
  final String? videoSha256;
  final int? videoSize;

  /// مرفقات النسخة المثبّتة (ملخص PDF مثلًا): JSON `{sha256: الحجم}`، تُنزَّل باختيار
  /// الطالب (الإصدار 5).
  final String? attachments;
  final DateTime? installedAt;

  /// النسخة المنتظرة وملفاتها، أو null إن لا شيء ينتظر.
  final int? pendingVersion;
  final int? pendingContentFormat;
  final String? pendingFiles;
  final String? pendingVideoSha256;
  final int? pendingVideoSize;
  final String? pendingAttachments;
  const ContentLesson({
    required this.lessonId,
    required this.version,
    required this.contentFormat,
    required this.files,
    this.videoSha256,
    this.videoSize,
    this.attachments,
    this.installedAt,
    this.pendingVersion,
    this.pendingContentFormat,
    this.pendingFiles,
    this.pendingVideoSha256,
    this.pendingVideoSize,
    this.pendingAttachments,
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
    if (!nullToAbsent || attachments != null) {
      map['attachments'] = Variable<String>(attachments);
    }
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<DateTime>(installedAt);
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
    if (!nullToAbsent || pendingAttachments != null) {
      map['pending_attachments'] = Variable<String>(pendingAttachments);
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
      attachments: attachments == null && nullToAbsent
          ? const Value.absent()
          : Value(attachments),
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
      pendingAttachments: pendingAttachments == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingAttachments),
    );
  }

  factory ContentLesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentLesson(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      version: serializer.fromJson<int>(json['version']),
      contentFormat: serializer.fromJson<int>(json['contentFormat']),
      files: serializer.fromJson<String>(json['files']),
      videoSha256: serializer.fromJson<String?>(json['videoSha256']),
      videoSize: serializer.fromJson<int?>(json['videoSize']),
      attachments: serializer.fromJson<String?>(json['attachments']),
      installedAt: serializer.fromJson<DateTime?>(json['installedAt']),
      pendingVersion: serializer.fromJson<int?>(json['pendingVersion']),
      pendingContentFormat: serializer.fromJson<int?>(
        json['pendingContentFormat'],
      ),
      pendingFiles: serializer.fromJson<String?>(json['pendingFiles']),
      pendingVideoSha256: serializer.fromJson<String?>(
        json['pendingVideoSha256'],
      ),
      pendingVideoSize: serializer.fromJson<int?>(json['pendingVideoSize']),
      pendingAttachments: serializer.fromJson<String?>(
        json['pendingAttachments'],
      ),
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
      'attachments': serializer.toJson<String?>(attachments),
      'installedAt': serializer.toJson<DateTime?>(installedAt),
      'pendingVersion': serializer.toJson<int?>(pendingVersion),
      'pendingContentFormat': serializer.toJson<int?>(pendingContentFormat),
      'pendingFiles': serializer.toJson<String?>(pendingFiles),
      'pendingVideoSha256': serializer.toJson<String?>(pendingVideoSha256),
      'pendingVideoSize': serializer.toJson<int?>(pendingVideoSize),
      'pendingAttachments': serializer.toJson<String?>(pendingAttachments),
    };
  }

  ContentLesson copyWith({
    String? lessonId,
    int? version,
    int? contentFormat,
    String? files,
    Value<String?> videoSha256 = const Value.absent(),
    Value<int?> videoSize = const Value.absent(),
    Value<String?> attachments = const Value.absent(),
    Value<DateTime?> installedAt = const Value.absent(),
    Value<int?> pendingVersion = const Value.absent(),
    Value<int?> pendingContentFormat = const Value.absent(),
    Value<String?> pendingFiles = const Value.absent(),
    Value<String?> pendingVideoSha256 = const Value.absent(),
    Value<int?> pendingVideoSize = const Value.absent(),
    Value<String?> pendingAttachments = const Value.absent(),
  }) => ContentLesson(
    lessonId: lessonId ?? this.lessonId,
    version: version ?? this.version,
    contentFormat: contentFormat ?? this.contentFormat,
    files: files ?? this.files,
    videoSha256: videoSha256.present ? videoSha256.value : this.videoSha256,
    videoSize: videoSize.present ? videoSize.value : this.videoSize,
    attachments: attachments.present ? attachments.value : this.attachments,
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
    pendingAttachments: pendingAttachments.present
        ? pendingAttachments.value
        : this.pendingAttachments,
  );
  ContentLesson copyWithCompanion(ContentLessonsCompanion data) {
    return ContentLesson(
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
      attachments: data.attachments.present
          ? data.attachments.value
          : this.attachments,
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
      pendingAttachments: data.pendingAttachments.present
          ? data.pendingAttachments.value
          : this.pendingAttachments,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentLesson(')
          ..write('lessonId: $lessonId, ')
          ..write('version: $version, ')
          ..write('contentFormat: $contentFormat, ')
          ..write('files: $files, ')
          ..write('videoSha256: $videoSha256, ')
          ..write('videoSize: $videoSize, ')
          ..write('attachments: $attachments, ')
          ..write('installedAt: $installedAt, ')
          ..write('pendingVersion: $pendingVersion, ')
          ..write('pendingContentFormat: $pendingContentFormat, ')
          ..write('pendingFiles: $pendingFiles, ')
          ..write('pendingVideoSha256: $pendingVideoSha256, ')
          ..write('pendingVideoSize: $pendingVideoSize, ')
          ..write('pendingAttachments: $pendingAttachments')
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
    attachments,
    installedAt,
    pendingVersion,
    pendingContentFormat,
    pendingFiles,
    pendingVideoSha256,
    pendingVideoSize,
    pendingAttachments,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentLesson &&
          other.lessonId == this.lessonId &&
          other.version == this.version &&
          other.contentFormat == this.contentFormat &&
          other.files == this.files &&
          other.videoSha256 == this.videoSha256 &&
          other.videoSize == this.videoSize &&
          other.attachments == this.attachments &&
          other.installedAt == this.installedAt &&
          other.pendingVersion == this.pendingVersion &&
          other.pendingContentFormat == this.pendingContentFormat &&
          other.pendingFiles == this.pendingFiles &&
          other.pendingVideoSha256 == this.pendingVideoSha256 &&
          other.pendingVideoSize == this.pendingVideoSize &&
          other.pendingAttachments == this.pendingAttachments);
}

class ContentLessonsCompanion extends UpdateCompanion<ContentLesson> {
  final Value<String> lessonId;
  final Value<int> version;
  final Value<int> contentFormat;
  final Value<String> files;
  final Value<String?> videoSha256;
  final Value<int?> videoSize;
  final Value<String?> attachments;
  final Value<DateTime?> installedAt;
  final Value<int?> pendingVersion;
  final Value<int?> pendingContentFormat;
  final Value<String?> pendingFiles;
  final Value<String?> pendingVideoSha256;
  final Value<int?> pendingVideoSize;
  final Value<String?> pendingAttachments;
  final Value<int> rowid;
  const ContentLessonsCompanion({
    this.lessonId = const Value.absent(),
    this.version = const Value.absent(),
    this.contentFormat = const Value.absent(),
    this.files = const Value.absent(),
    this.videoSha256 = const Value.absent(),
    this.videoSize = const Value.absent(),
    this.attachments = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.pendingVersion = const Value.absent(),
    this.pendingContentFormat = const Value.absent(),
    this.pendingFiles = const Value.absent(),
    this.pendingVideoSha256 = const Value.absent(),
    this.pendingVideoSize = const Value.absent(),
    this.pendingAttachments = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentLessonsCompanion.insert({
    required String lessonId,
    this.version = const Value.absent(),
    this.contentFormat = const Value.absent(),
    this.files = const Value.absent(),
    this.videoSha256 = const Value.absent(),
    this.videoSize = const Value.absent(),
    this.attachments = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.pendingVersion = const Value.absent(),
    this.pendingContentFormat = const Value.absent(),
    this.pendingFiles = const Value.absent(),
    this.pendingVideoSha256 = const Value.absent(),
    this.pendingVideoSize = const Value.absent(),
    this.pendingAttachments = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId);
  static Insertable<ContentLesson> custom({
    Expression<String>? lessonId,
    Expression<int>? version,
    Expression<int>? contentFormat,
    Expression<String>? files,
    Expression<String>? videoSha256,
    Expression<int>? videoSize,
    Expression<String>? attachments,
    Expression<DateTime>? installedAt,
    Expression<int>? pendingVersion,
    Expression<int>? pendingContentFormat,
    Expression<String>? pendingFiles,
    Expression<String>? pendingVideoSha256,
    Expression<int>? pendingVideoSize,
    Expression<String>? pendingAttachments,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (version != null) 'version': version,
      if (contentFormat != null) 'content_format': contentFormat,
      if (files != null) 'files': files,
      if (videoSha256 != null) 'video_sha256': videoSha256,
      if (videoSize != null) 'video_size': videoSize,
      if (attachments != null) 'attachments': attachments,
      if (installedAt != null) 'installed_at': installedAt,
      if (pendingVersion != null) 'pending_version': pendingVersion,
      if (pendingContentFormat != null)
        'pending_content_format': pendingContentFormat,
      if (pendingFiles != null) 'pending_files': pendingFiles,
      if (pendingVideoSha256 != null)
        'pending_video_sha256': pendingVideoSha256,
      if (pendingVideoSize != null) 'pending_video_size': pendingVideoSize,
      if (pendingAttachments != null) 'pending_attachments': pendingAttachments,
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
    Value<String?>? attachments,
    Value<DateTime?>? installedAt,
    Value<int?>? pendingVersion,
    Value<int?>? pendingContentFormat,
    Value<String?>? pendingFiles,
    Value<String?>? pendingVideoSha256,
    Value<int?>? pendingVideoSize,
    Value<String?>? pendingAttachments,
    Value<int>? rowid,
  }) {
    return ContentLessonsCompanion(
      lessonId: lessonId ?? this.lessonId,
      version: version ?? this.version,
      contentFormat: contentFormat ?? this.contentFormat,
      files: files ?? this.files,
      videoSha256: videoSha256 ?? this.videoSha256,
      videoSize: videoSize ?? this.videoSize,
      attachments: attachments ?? this.attachments,
      installedAt: installedAt ?? this.installedAt,
      pendingVersion: pendingVersion ?? this.pendingVersion,
      pendingContentFormat: pendingContentFormat ?? this.pendingContentFormat,
      pendingFiles: pendingFiles ?? this.pendingFiles,
      pendingVideoSha256: pendingVideoSha256 ?? this.pendingVideoSha256,
      pendingVideoSize: pendingVideoSize ?? this.pendingVideoSize,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
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
    if (attachments.present) {
      map['attachments'] = Variable<String>(attachments.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
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
    if (pendingAttachments.present) {
      map['pending_attachments'] = Variable<String>(pendingAttachments.value);
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
          ..write('attachments: $attachments, ')
          ..write('installedAt: $installedAt, ')
          ..write('pendingVersion: $pendingVersion, ')
          ..write('pendingContentFormat: $pendingContentFormat, ')
          ..write('pendingFiles: $pendingFiles, ')
          ..write('pendingVideoSha256: $pendingVideoSha256, ')
          ..write('pendingVideoSize: $pendingVideoSize, ')
          ..write('pendingAttachments: $pendingAttachments, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentBlobsTable extends ContentBlobs
    with TableInfo<$ContentBlobsTable, ContentBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BlobKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BlobKind>($ContentBlobsTable.$converterkind);
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sha256, size, kind, verifiedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentBlob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_verifiedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sha256};
  @override
  ContentBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentBlob(
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      kind: $ContentBlobsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      )!,
    );
  }

  @override
  $ContentBlobsTable createAlias(String alias) {
    return $ContentBlobsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BlobKind, String, String> $converterkind =
      const EnumNameConverter<BlobKind>(BlobKind.values);
}

class ContentBlob extends DataClass implements Insertable<ContentBlob> {
  final String sha256;
  final int size;
  final BlobKind kind;
  final DateTime verifiedAt;
  const ContentBlob({
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
    {
      map['kind'] = Variable<String>(
        $ContentBlobsTable.$converterkind.toSql(kind),
      );
    }
    map['verified_at'] = Variable<DateTime>(verifiedAt);
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

  factory ContentBlob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentBlob(
      sha256: serializer.fromJson<String>(json['sha256']),
      size: serializer.fromJson<int>(json['size']),
      kind: $ContentBlobsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      verifiedAt: serializer.fromJson<DateTime>(json['verifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sha256': serializer.toJson<String>(sha256),
      'size': serializer.toJson<int>(size),
      'kind': serializer.toJson<String>(
        $ContentBlobsTable.$converterkind.toJson(kind),
      ),
      'verifiedAt': serializer.toJson<DateTime>(verifiedAt),
    };
  }

  ContentBlob copyWith({
    String? sha256,
    int? size,
    BlobKind? kind,
    DateTime? verifiedAt,
  }) => ContentBlob(
    sha256: sha256 ?? this.sha256,
    size: size ?? this.size,
    kind: kind ?? this.kind,
    verifiedAt: verifiedAt ?? this.verifiedAt,
  );
  ContentBlob copyWithCompanion(ContentBlobsCompanion data) {
    return ContentBlob(
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
    return (StringBuffer('ContentBlob(')
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
      (other is ContentBlob &&
          other.sha256 == this.sha256 &&
          other.size == this.size &&
          other.kind == this.kind &&
          other.verifiedAt == this.verifiedAt);
}

class ContentBlobsCompanion extends UpdateCompanion<ContentBlob> {
  final Value<String> sha256;
  final Value<int> size;
  final Value<BlobKind> kind;
  final Value<DateTime> verifiedAt;
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
    required BlobKind kind,
    required DateTime verifiedAt,
    this.rowid = const Value.absent(),
  }) : sha256 = Value(sha256),
       size = Value(size),
       kind = Value(kind),
       verifiedAt = Value(verifiedAt);
  static Insertable<ContentBlob> custom({
    Expression<String>? sha256,
    Expression<int>? size,
    Expression<String>? kind,
    Expression<DateTime>? verifiedAt,
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
    Value<BlobKind>? kind,
    Value<DateTime>? verifiedAt,
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
      map['kind'] = Variable<String>(
        $ContentBlobsTable.$converterkind.toSql(kind.value),
      );
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
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

class $ContentDownloadsTable extends ContentDownloads
    with TableInfo<$ContentDownloadsTable, ContentDownload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentDownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BlobKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BlobKind>($ContentDownloadsTable.$converterkind);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedMeta = const VerificationMeta(
    'received',
  );
  @override
  late final GeneratedColumn<int> received = GeneratedColumn<int>(
    'received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failuresMeta = const VerificationMeta(
    'failures',
  );
  @override
  late final GeneratedColumn<int> failures = GeneratedColumn<int>(
    'failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  VerificationContext validateIntegrity(
    Insertable<ContentDownload> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('received')) {
      context.handle(
        _receivedMeta,
        received.isAcceptableOrUnknown(data['received']!, _receivedMeta),
      );
    }
    if (data.containsKey('failures')) {
      context.handle(
        _failuresMeta,
        failures.isAcceptableOrUnknown(data['failures']!, _failuresMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sha256};
  @override
  ContentDownload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentDownload(
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      kind: $ContentDownloadsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
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
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ContentDownloadsTable createAlias(String alias) {
    return $ContentDownloadsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BlobKind, String, String> $converterkind =
      const EnumNameConverter<BlobKind>(BlobKind.values);
}

class ContentDownload extends DataClass implements Insertable<ContentDownload> {
  final String sha256;

  /// الحجم المكتوب في الفهرس، وهو حد أعلى: ما يتجاوزه يُرفض.
  final int size;
  final BlobKind kind;

  /// الأصغر أولًا: 0 الكتالوج، 1 الوحدة الحالية، 2 بقية الدروس، 3 الفيديو.
  final int priority;

  /// بايتات مكتوبة في `blobs/<sha256>.part` (من هنا يكمل التنزيل).
  final int received;

  /// محاولات انتهت بملف تالف. بعد 3 يتوقف هذا الملف حتى الفهرس التالي.
  final int failures;
  final String? lastError;
  final DateTime createdAt;
  const ContentDownload({
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
    {
      map['kind'] = Variable<String>(
        $ContentDownloadsTable.$converterkind.toSql(kind),
      );
    }
    map['priority'] = Variable<int>(priority);
    map['received'] = Variable<int>(received);
    map['failures'] = Variable<int>(failures);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
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

  factory ContentDownload.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentDownload(
      sha256: serializer.fromJson<String>(json['sha256']),
      size: serializer.fromJson<int>(json['size']),
      kind: $ContentDownloadsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      priority: serializer.fromJson<int>(json['priority']),
      received: serializer.fromJson<int>(json['received']),
      failures: serializer.fromJson<int>(json['failures']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sha256': serializer.toJson<String>(sha256),
      'size': serializer.toJson<int>(size),
      'kind': serializer.toJson<String>(
        $ContentDownloadsTable.$converterkind.toJson(kind),
      ),
      'priority': serializer.toJson<int>(priority),
      'received': serializer.toJson<int>(received),
      'failures': serializer.toJson<int>(failures),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ContentDownload copyWith({
    String? sha256,
    int? size,
    BlobKind? kind,
    int? priority,
    int? received,
    int? failures,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
  }) => ContentDownload(
    sha256: sha256 ?? this.sha256,
    size: size ?? this.size,
    kind: kind ?? this.kind,
    priority: priority ?? this.priority,
    received: received ?? this.received,
    failures: failures ?? this.failures,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  ContentDownload copyWithCompanion(ContentDownloadsCompanion data) {
    return ContentDownload(
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
    return (StringBuffer('ContentDownload(')
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
      (other is ContentDownload &&
          other.sha256 == this.sha256 &&
          other.size == this.size &&
          other.kind == this.kind &&
          other.priority == this.priority &&
          other.received == this.received &&
          other.failures == this.failures &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class ContentDownloadsCompanion extends UpdateCompanion<ContentDownload> {
  final Value<String> sha256;
  final Value<int> size;
  final Value<BlobKind> kind;
  final Value<int> priority;
  final Value<int> received;
  final Value<int> failures;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
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
    required BlobKind kind,
    required int priority,
    this.received = const Value.absent(),
    this.failures = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : sha256 = Value(sha256),
       size = Value(size),
       kind = Value(kind),
       priority = Value(priority),
       createdAt = Value(createdAt);
  static Insertable<ContentDownload> custom({
    Expression<String>? sha256,
    Expression<int>? size,
    Expression<String>? kind,
    Expression<int>? priority,
    Expression<int>? received,
    Expression<int>? failures,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
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
    Value<BlobKind>? kind,
    Value<int>? priority,
    Value<int>? received,
    Value<int>? failures,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
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
      map['kind'] = Variable<String>(
        $ContentDownloadsTable.$converterkind.toSql(kind.value),
      );
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
      map['created_at'] = Variable<DateTime>(createdAt.value);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $LessonProgressTable lessonProgress = $LessonProgressTable(this);
  late final $LessonPartProgressTable lessonPartProgress =
      $LessonPartProgressTable(this);
  late final $OwnedItemsTable ownedItems = $OwnedItemsTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $ConceptMasteryTable conceptMastery = $ConceptMasteryTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ContentManifestsTable contentManifests = $ContentManifestsTable(
    this,
  );
  late final $ContentLessonsTable contentLessons = $ContentLessonsTable(this);
  late final $ContentBlobsTable contentBlobs = $ContentBlobsTable(this);
  late final $ContentDownloadsTable contentDownloads = $ContentDownloadsTable(
    this,
  );
  late final ProfilesDao profilesDao = ProfilesDao(this as AppDatabase);
  late final ActivityDao activityDao = ActivityDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final WardrobeDao wardrobeDao = WardrobeDao(this as AppDatabase);
  late final ContentDao contentDao = ContentDao(this as AppDatabase);
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
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required String name,
      required int grade,
      required ProfileColor color,
      Value<String?> pinHash,
      Value<String?> pinSalt,
      required String studentCode,
      Value<String?> classCode,
      Value<String> equipped,
      required DateTime createdAt,
      required DateTime lastActiveAt,
      Value<int> revision,
      Value<int> localVersion,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> grade,
      Value<ProfileColor> color,
      Value<String?> pinHash,
      Value<String?> pinSalt,
      Value<String> studentCode,
      Value<String?> classCode,
      Value<String> equipped,
      Value<DateTime> createdAt,
      Value<DateTime> lastActiveAt,
      Value<int> revision,
      Value<int> localVersion,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LessonProgressTable, List<LessonProgressEntry>>
  _lessonProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lessonProgress,
    aliasName: $_aliasNameGenerator(
      db.profiles.id,
      db.lessonProgress.profileId,
    ),
  );

  $$LessonProgressTableProcessedTableManager get lessonProgressRefs {
    final manager = $$LessonProgressTableTableManager(
      $_db,
      $_db.lessonProgress,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lessonProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LessonPartProgressTable, List<LessonPartEntry>>
  _lessonPartProgressRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lessonPartProgress,
        aliasName: $_aliasNameGenerator(
          db.profiles.id,
          db.lessonPartProgress.profileId,
        ),
      );

  $$LessonPartProgressTableProcessedTableManager get lessonPartProgressRefs {
    final manager = $$LessonPartProgressTableTableManager(
      $_db,
      $_db.lessonPartProgress,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lessonPartProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OwnedItemsTable, List<OwnedItem>>
  _ownedItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ownedItems,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.ownedItems.profileId),
  );

  $$OwnedItemsTableProcessedTableManager get ownedItemsRefs {
    final manager = $$OwnedItemsTableTableManager(
      $_db,
      $_db.ownedItems,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ownedItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttemptsTable, List<Attempt>> _attemptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.attempts,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.attempts.profileId),
  );

  $$AttemptsTableProcessedTableManager get attemptsRefs {
    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConceptMasteryTable, List<ConceptMasteryEntry>>
  _conceptMasteryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conceptMastery,
    aliasName: $_aliasNameGenerator(
      db.profiles.id,
      db.conceptMastery.profileId,
    ),
  );

  $$ConceptMasteryTableProcessedTableManager get conceptMasteryRefs {
    final manager = $$ConceptMasteryTableTableManager(
      $_db,
      $_db.conceptMastery,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_conceptMasteryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.bookmarks.profileId),
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProfileColor, ProfileColor, String>
  get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentCode => $composableBuilder(
    column: $table.studentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipped => $composableBuilder(
    column: $table.equipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lessonProgressRefs(
    Expression<bool> Function($$LessonProgressTableFilterComposer f) f,
  ) {
    final $$LessonProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonProgress,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonProgressTableFilterComposer(
            $db: $db,
            $table: $db.lessonProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lessonPartProgressRefs(
    Expression<bool> Function($$LessonPartProgressTableFilterComposer f) f,
  ) {
    final $$LessonPartProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonPartProgress,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonPartProgressTableFilterComposer(
            $db: $db,
            $table: $db.lessonPartProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ownedItemsRefs(
    Expression<bool> Function($$OwnedItemsTableFilterComposer f) f,
  ) {
    final $$OwnedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ownedItems,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OwnedItemsTableFilterComposer(
            $db: $db,
            $table: $db.ownedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attemptsRefs(
    Expression<bool> Function($$AttemptsTableFilterComposer f) f,
  ) {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conceptMasteryRefs(
    Expression<bool> Function($$ConceptMasteryTableFilterComposer f) f,
  ) {
    final $$ConceptMasteryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conceptMastery,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConceptMasteryTableFilterComposer(
            $db: $db,
            $table: $db.conceptMastery,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentCode => $composableBuilder(
    column: $table.studentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipped => $composableBuilder(
    column: $table.equipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProfileColor, String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<String> get studentCode => $composableBuilder(
    column: $table.studentCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classCode =>
      $composableBuilder(column: $table.classCode, builder: (column) => column);

  GeneratedColumn<String> get equipped =>
      $composableBuilder(column: $table.equipped, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  Expression<T> lessonProgressRefs<T extends Object>(
    Expression<T> Function($$LessonProgressTableAnnotationComposer a) f,
  ) {
    final $$LessonProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonProgress,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.lessonProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lessonPartProgressRefs<T extends Object>(
    Expression<T> Function($$LessonPartProgressTableAnnotationComposer a) f,
  ) {
    final $$LessonPartProgressTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lessonPartProgress,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LessonPartProgressTableAnnotationComposer(
                $db: $db,
                $table: $db.lessonPartProgress,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ownedItemsRefs<T extends Object>(
    Expression<T> Function($$OwnedItemsTableAnnotationComposer a) f,
  ) {
    final $$OwnedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ownedItems,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OwnedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.ownedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attemptsRefs<T extends Object>(
    Expression<T> Function($$AttemptsTableAnnotationComposer a) f,
  ) {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conceptMasteryRefs<T extends Object>(
    Expression<T> Function($$ConceptMasteryTableAnnotationComposer a) f,
  ) {
    final $$ConceptMasteryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conceptMastery,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConceptMasteryTableAnnotationComposer(
            $db: $db,
            $table: $db.conceptMastery,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool lessonProgressRefs,
            bool lessonPartProgressRefs,
            bool ownedItemsRefs,
            bool attemptsRefs,
            bool conceptMasteryRefs,
            bool bookmarksRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<ProfileColor> color = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                Value<String> studentCode = const Value.absent(),
                Value<String?> classCode = const Value.absent(),
                Value<String> equipped = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastActiveAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                grade: grade,
                color: color,
                pinHash: pinHash,
                pinSalt: pinSalt,
                studentCode: studentCode,
                classCode: classCode,
                equipped: equipped,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
                revision: revision,
                localVersion: localVersion,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int grade,
                required ProfileColor color,
                Value<String?> pinHash = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                required String studentCode,
                Value<String?> classCode = const Value.absent(),
                Value<String> equipped = const Value.absent(),
                required DateTime createdAt,
                required DateTime lastActiveAt,
                Value<int> revision = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                grade: grade,
                color: color,
                pinHash: pinHash,
                pinSalt: pinSalt,
                studentCode: studentCode,
                classCode: classCode,
                equipped: equipped,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
                revision: revision,
                localVersion: localVersion,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                lessonProgressRefs = false,
                lessonPartProgressRefs = false,
                ownedItemsRefs = false,
                attemptsRefs = false,
                conceptMasteryRefs = false,
                bookmarksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lessonProgressRefs) db.lessonProgress,
                    if (lessonPartProgressRefs) db.lessonPartProgress,
                    if (ownedItemsRefs) db.ownedItems,
                    if (attemptsRefs) db.attempts,
                    if (conceptMasteryRefs) db.conceptMastery,
                    if (bookmarksRefs) db.bookmarks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lessonProgressRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          LessonProgressEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._lessonProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).lessonProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lessonPartProgressRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          LessonPartEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._lessonPartProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).lessonPartProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ownedItemsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          OwnedItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._ownedItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).ownedItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attemptsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Attempt
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._attemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).attemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conceptMasteryRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          ConceptMasteryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._conceptMasteryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).conceptMasteryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Bookmark
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({
        bool lessonProgressRefs,
        bool lessonPartProgressRefs,
        bool ownedItemsRefs,
        bool attemptsRefs,
        bool conceptMasteryRefs,
        bool bookmarksRefs,
      })
    >;
typedef $$LessonProgressTableCreateCompanionBuilder =
    LessonProgressCompanion Function({
      required String profileId,
      required String lessonId,
      required LessonStatus status,
      Value<double> progress,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LessonProgressTableUpdateCompanionBuilder =
    LessonProgressCompanion Function({
      Value<String> profileId,
      Value<String> lessonId,
      Value<LessonStatus> status,
      Value<double> progress,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LessonProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LessonProgressTable,
          LessonProgressEntry
        > {
  $$LessonProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.lessonProgress.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LessonProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LessonStatus, LessonStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LessonStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressTable,
          LessonProgressEntry,
          $$LessonProgressTableFilterComposer,
          $$LessonProgressTableOrderingComposer,
          $$LessonProgressTableAnnotationComposer,
          $$LessonProgressTableCreateCompanionBuilder,
          $$LessonProgressTableUpdateCompanionBuilder,
          (LessonProgressEntry, $$LessonProgressTableReferences),
          LessonProgressEntry,
          PrefetchHooks Function({bool profileId})
        > {
  $$LessonProgressTableTableManager(
    _$AppDatabase db,
    $LessonProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<LessonStatus> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion(
                profileId: profileId,
                lessonId: lessonId,
                status: status,
                progress: progress,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String lessonId,
                required LessonStatus status,
                Value<double> progress = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion.insert(
                profileId: profileId,
                lessonId: lessonId,
                status: status,
                progress: progress,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LessonProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$LessonProgressTableReferences
                                    ._profileIdTable(db),
                                referencedColumn:
                                    $$LessonProgressTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LessonProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressTable,
      LessonProgressEntry,
      $$LessonProgressTableFilterComposer,
      $$LessonProgressTableOrderingComposer,
      $$LessonProgressTableAnnotationComposer,
      $$LessonProgressTableCreateCompanionBuilder,
      $$LessonProgressTableUpdateCompanionBuilder,
      (LessonProgressEntry, $$LessonProgressTableReferences),
      LessonProgressEntry,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$LessonPartProgressTableCreateCompanionBuilder =
    LessonPartProgressCompanion Function({
      required String profileId,
      required String lessonId,
      required LessonPart part,
      required DateTime completedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$LessonPartProgressTableUpdateCompanionBuilder =
    LessonPartProgressCompanion Function({
      Value<String> profileId,
      Value<String> lessonId,
      Value<LessonPart> part,
      Value<DateTime> completedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

final class $$LessonPartProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LessonPartProgressTable,
          LessonPartEntry
        > {
  $$LessonPartProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.lessonPartProgress.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LessonPartProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LessonPartProgressTable> {
  $$LessonPartProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LessonPart, LessonPart, String> get part =>
      $composableBuilder(
        column: $table.part,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonPartProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonPartProgressTable> {
  $$LessonPartProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get part => $composableBuilder(
    column: $table.part,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonPartProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonPartProgressTable> {
  $$LessonPartProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LessonPart, String> get part =>
      $composableBuilder(column: $table.part, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonPartProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonPartProgressTable,
          LessonPartEntry,
          $$LessonPartProgressTableFilterComposer,
          $$LessonPartProgressTableOrderingComposer,
          $$LessonPartProgressTableAnnotationComposer,
          $$LessonPartProgressTableCreateCompanionBuilder,
          $$LessonPartProgressTableUpdateCompanionBuilder,
          (LessonPartEntry, $$LessonPartProgressTableReferences),
          LessonPartEntry,
          PrefetchHooks Function({bool profileId})
        > {
  $$LessonPartProgressTableTableManager(
    _$AppDatabase db,
    $LessonPartProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonPartProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonPartProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonPartProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<LessonPart> part = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonPartProgressCompanion(
                profileId: profileId,
                lessonId: lessonId,
                part: part,
                completedAt: completedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String lessonId,
                required LessonPart part,
                required DateTime completedAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonPartProgressCompanion.insert(
                profileId: profileId,
                lessonId: lessonId,
                part: part,
                completedAt: completedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LessonPartProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$LessonPartProgressTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$LessonPartProgressTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LessonPartProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonPartProgressTable,
      LessonPartEntry,
      $$LessonPartProgressTableFilterComposer,
      $$LessonPartProgressTableOrderingComposer,
      $$LessonPartProgressTableAnnotationComposer,
      $$LessonPartProgressTableCreateCompanionBuilder,
      $$LessonPartProgressTableUpdateCompanionBuilder,
      (LessonPartEntry, $$LessonPartProgressTableReferences),
      LessonPartEntry,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$OwnedItemsTableCreateCompanionBuilder =
    OwnedItemsCompanion Function({
      required String profileId,
      required String itemId,
      required int cost,
      required DateTime acquiredAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$OwnedItemsTableUpdateCompanionBuilder =
    OwnedItemsCompanion Function({
      Value<String> profileId,
      Value<String> itemId,
      Value<int> cost,
      Value<DateTime> acquiredAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

final class $$OwnedItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OwnedItemsTable, OwnedItem> {
  $$OwnedItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.ownedItems.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OwnedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OwnedItemsTable> {
  $$OwnedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OwnedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnedItemsTable> {
  $$OwnedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OwnedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnedItemsTable> {
  $$OwnedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OwnedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnedItemsTable,
          OwnedItem,
          $$OwnedItemsTableFilterComposer,
          $$OwnedItemsTableOrderingComposer,
          $$OwnedItemsTableAnnotationComposer,
          $$OwnedItemsTableCreateCompanionBuilder,
          $$OwnedItemsTableUpdateCompanionBuilder,
          (OwnedItem, $$OwnedItemsTableReferences),
          OwnedItem,
          PrefetchHooks Function({bool profileId})
        > {
  $$OwnedItemsTableTableManager(_$AppDatabase db, $OwnedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<DateTime> acquiredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnedItemsCompanion(
                profileId: profileId,
                itemId: itemId,
                cost: cost,
                acquiredAt: acquiredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String itemId,
                required int cost,
                required DateTime acquiredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnedItemsCompanion.insert(
                profileId: profileId,
                itemId: itemId,
                cost: cost,
                acquiredAt: acquiredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OwnedItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$OwnedItemsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$OwnedItemsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OwnedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnedItemsTable,
      OwnedItem,
      $$OwnedItemsTableFilterComposer,
      $$OwnedItemsTableOrderingComposer,
      $$OwnedItemsTableAnnotationComposer,
      $$OwnedItemsTableCreateCompanionBuilder,
      $$OwnedItemsTableUpdateCompanionBuilder,
      (OwnedItem, $$OwnedItemsTableReferences),
      OwnedItem,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$AttemptsTableCreateCompanionBuilder =
    AttemptsCompanion Function({
      required String id,
      required String profileId,
      required String activityId,
      required AttemptKind kind,
      required int score,
      required int total,
      Value<int> starsEarned,
      Value<int> hintsUsed,
      Value<String?> detailsJson,
      required DateTime createdAt,
      Value<DateTime?> syncedAt,
      Value<DateTime?> serverReceivedAt,
      Value<int> rowid,
    });
typedef $$AttemptsTableUpdateCompanionBuilder =
    AttemptsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> activityId,
      Value<AttemptKind> kind,
      Value<int> score,
      Value<int> total,
      Value<int> starsEarned,
      Value<int> hintsUsed,
      Value<String?> detailsJson,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
      Value<DateTime?> serverReceivedAt,
      Value<int> rowid,
    });

final class $$AttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptsTable, Attempt> {
  $$AttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) => db.profiles
      .createAlias($_aliasNameGenerator(db.attempts.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AttemptKind, AttemptKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get starsEarned => $composableBuilder(
    column: $table.starsEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get starsEarned => $composableBuilder(
    column: $table.starsEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AttemptKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get starsEarned => $composableBuilder(
    column: $table.starsEarned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintsUsed =>
      $composableBuilder(column: $table.hintsUsed, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, $$AttemptsTableReferences),
          Attempt,
          PrefetchHooks Function({bool profileId})
        > {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<AttemptKind> kind = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> starsEarned = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<String?> detailsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                profileId: profileId,
                activityId: activityId,
                kind: kind,
                score: score,
                total: total,
                starsEarned: starsEarned,
                hintsUsed: hintsUsed,
                detailsJson: detailsJson,
                createdAt: createdAt,
                syncedAt: syncedAt,
                serverReceivedAt: serverReceivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String activityId,
                required AttemptKind kind,
                required int score,
                required int total,
                Value<int> starsEarned = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<String?> detailsJson = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion.insert(
                id: id,
                profileId: profileId,
                activityId: activityId,
                kind: kind,
                score: score,
                total: total,
                starsEarned: starsEarned,
                hintsUsed: hintsUsed,
                detailsJson: detailsJson,
                createdAt: createdAt,
                syncedAt: syncedAt,
                serverReceivedAt: serverReceivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$AttemptsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$AttemptsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, $$AttemptsTableReferences),
      Attempt,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ConceptMasteryTableCreateCompanionBuilder =
    ConceptMasteryCompanion Function({
      required String profileId,
      required String conceptId,
      required double mastery,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ConceptMasteryTableUpdateCompanionBuilder =
    ConceptMasteryCompanion Function({
      Value<String> profileId,
      Value<String> conceptId,
      Value<double> mastery,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ConceptMasteryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConceptMasteryTable,
          ConceptMasteryEntry
        > {
  $$ConceptMasteryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.conceptMastery.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConceptMasteryTableFilterComposer
    extends Composer<_$AppDatabase, $ConceptMasteryTable> {
  $$ConceptMasteryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mastery => $composableBuilder(
    column: $table.mastery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConceptMasteryTableOrderingComposer
    extends Composer<_$AppDatabase, $ConceptMasteryTable> {
  $$ConceptMasteryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conceptId => $composableBuilder(
    column: $table.conceptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mastery => $composableBuilder(
    column: $table.mastery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConceptMasteryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConceptMasteryTable> {
  $$ConceptMasteryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<double> get mastery =>
      $composableBuilder(column: $table.mastery, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConceptMasteryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConceptMasteryTable,
          ConceptMasteryEntry,
          $$ConceptMasteryTableFilterComposer,
          $$ConceptMasteryTableOrderingComposer,
          $$ConceptMasteryTableAnnotationComposer,
          $$ConceptMasteryTableCreateCompanionBuilder,
          $$ConceptMasteryTableUpdateCompanionBuilder,
          (ConceptMasteryEntry, $$ConceptMasteryTableReferences),
          ConceptMasteryEntry,
          PrefetchHooks Function({bool profileId})
        > {
  $$ConceptMasteryTableTableManager(
    _$AppDatabase db,
    $ConceptMasteryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConceptMasteryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConceptMasteryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConceptMasteryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> conceptId = const Value.absent(),
                Value<double> mastery = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConceptMasteryCompanion(
                profileId: profileId,
                conceptId: conceptId,
                mastery: mastery,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String conceptId,
                required double mastery,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConceptMasteryCompanion.insert(
                profileId: profileId,
                conceptId: conceptId,
                mastery: mastery,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConceptMasteryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ConceptMasteryTableReferences
                                    ._profileIdTable(db),
                                referencedColumn:
                                    $$ConceptMasteryTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConceptMasteryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConceptMasteryTable,
      ConceptMasteryEntry,
      $$ConceptMasteryTableFilterComposer,
      $$ConceptMasteryTableOrderingComposer,
      $$ConceptMasteryTableAnnotationComposer,
      $$ConceptMasteryTableCreateCompanionBuilder,
      $$ConceptMasteryTableUpdateCompanionBuilder,
      (ConceptMasteryEntry, $$ConceptMasteryTableReferences),
      ConceptMasteryEntry,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      required String profileId,
      required String lessonId,
      Value<DateTime?> removedAt,
      required DateTime updatedAt,
      Value<int> localVersion,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<String> profileId,
      Value<String> lessonId,
      Value<DateTime?> removedAt,
      Value<DateTime> updatedAt,
      Value<int> localVersion,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.bookmarks.profileId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<DateTime> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool profileId})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                profileId: profileId,
                lessonId: lessonId,
                removedAt: removedAt,
                updatedAt: updatedAt,
                localVersion: localVersion,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String lessonId,
                Value<DateTime?> removedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> localVersion = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                profileId: profileId,
                lessonId: lessonId,
                removedAt: removedAt,
                updatedAt: updatedAt,
                localVersion: localVersion,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$BookmarksTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$BookmarksTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ContentManifestsTableCreateCompanionBuilder =
    ContentManifestsCompanion Function({
      Value<int> grade,
      required int sequence,
      required String body,
      Value<String?> signature,
      Value<String?> catalogSha256,
      Value<String?> pendingCatalogSha256,
      required DateTime fetchedAt,
    });
typedef $$ContentManifestsTableUpdateCompanionBuilder =
    ContentManifestsCompanion Function({
      Value<int> grade,
      Value<int> sequence,
      Value<String> body,
      Value<String?> signature,
      Value<String?> catalogSha256,
      Value<String?> pendingCatalogSha256,
      Value<DateTime> fetchedAt,
    });

class $$ContentManifestsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentManifestsTable> {
  $$ContentManifestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogSha256 => $composableBuilder(
    column: $table.catalogSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingCatalogSha256 => $composableBuilder(
    column: $table.pendingCatalogSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentManifestsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentManifestsTable> {
  $$ContentManifestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogSha256 => $composableBuilder(
    column: $table.catalogSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingCatalogSha256 => $composableBuilder(
    column: $table.pendingCatalogSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentManifestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentManifestsTable> {
  $$ContentManifestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<String> get catalogSha256 => $composableBuilder(
    column: $table.catalogSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingCatalogSha256 => $composableBuilder(
    column: $table.pendingCatalogSha256,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ContentManifestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentManifestsTable,
          ContentManifest,
          $$ContentManifestsTableFilterComposer,
          $$ContentManifestsTableOrderingComposer,
          $$ContentManifestsTableAnnotationComposer,
          $$ContentManifestsTableCreateCompanionBuilder,
          $$ContentManifestsTableUpdateCompanionBuilder,
          (
            ContentManifest,
            BaseReferences<
              _$AppDatabase,
              $ContentManifestsTable,
              ContentManifest
            >,
          ),
          ContentManifest,
          PrefetchHooks Function()
        > {
  $$ContentManifestsTableTableManager(
    _$AppDatabase db,
    $ContentManifestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentManifestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentManifestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentManifestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> grade = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> signature = const Value.absent(),
                Value<String?> catalogSha256 = const Value.absent(),
                Value<String?> pendingCatalogSha256 = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => ContentManifestsCompanion(
                grade: grade,
                sequence: sequence,
                body: body,
                signature: signature,
                catalogSha256: catalogSha256,
                pendingCatalogSha256: pendingCatalogSha256,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> grade = const Value.absent(),
                required int sequence,
                required String body,
                Value<String?> signature = const Value.absent(),
                Value<String?> catalogSha256 = const Value.absent(),
                Value<String?> pendingCatalogSha256 = const Value.absent(),
                required DateTime fetchedAt,
              }) => ContentManifestsCompanion.insert(
                grade: grade,
                sequence: sequence,
                body: body,
                signature: signature,
                catalogSha256: catalogSha256,
                pendingCatalogSha256: pendingCatalogSha256,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentManifestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentManifestsTable,
      ContentManifest,
      $$ContentManifestsTableFilterComposer,
      $$ContentManifestsTableOrderingComposer,
      $$ContentManifestsTableAnnotationComposer,
      $$ContentManifestsTableCreateCompanionBuilder,
      $$ContentManifestsTableUpdateCompanionBuilder,
      (
        ContentManifest,
        BaseReferences<_$AppDatabase, $ContentManifestsTable, ContentManifest>,
      ),
      ContentManifest,
      PrefetchHooks Function()
    >;
typedef $$ContentLessonsTableCreateCompanionBuilder =
    ContentLessonsCompanion Function({
      required String lessonId,
      Value<int> version,
      Value<int> contentFormat,
      Value<String> files,
      Value<String?> videoSha256,
      Value<int?> videoSize,
      Value<String?> attachments,
      Value<DateTime?> installedAt,
      Value<int?> pendingVersion,
      Value<int?> pendingContentFormat,
      Value<String?> pendingFiles,
      Value<String?> pendingVideoSha256,
      Value<int?> pendingVideoSize,
      Value<String?> pendingAttachments,
      Value<int> rowid,
    });
typedef $$ContentLessonsTableUpdateCompanionBuilder =
    ContentLessonsCompanion Function({
      Value<String> lessonId,
      Value<int> version,
      Value<int> contentFormat,
      Value<String> files,
      Value<String?> videoSha256,
      Value<int?> videoSize,
      Value<String?> attachments,
      Value<DateTime?> installedAt,
      Value<int?> pendingVersion,
      Value<int?> pendingContentFormat,
      Value<String?> pendingFiles,
      Value<String?> pendingVideoSha256,
      Value<int?> pendingVideoSize,
      Value<String?> pendingAttachments,
      Value<int> rowid,
    });

class $$ContentLessonsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentLessonsTable> {
  $$ContentLessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentFormat => $composableBuilder(
    column: $table.contentFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get files => $composableBuilder(
    column: $table.files,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoSha256 => $composableBuilder(
    column: $table.videoSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get videoSize => $composableBuilder(
    column: $table.videoSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingVersion => $composableBuilder(
    column: $table.pendingVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingContentFormat => $composableBuilder(
    column: $table.pendingContentFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingFiles => $composableBuilder(
    column: $table.pendingFiles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingVideoSha256 => $composableBuilder(
    column: $table.pendingVideoSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingVideoSize => $composableBuilder(
    column: $table.pendingVideoSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingAttachments => $composableBuilder(
    column: $table.pendingAttachments,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentLessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentLessonsTable> {
  $$ContentLessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentFormat => $composableBuilder(
    column: $table.contentFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get files => $composableBuilder(
    column: $table.files,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoSha256 => $composableBuilder(
    column: $table.videoSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get videoSize => $composableBuilder(
    column: $table.videoSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingVersion => $composableBuilder(
    column: $table.pendingVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingContentFormat => $composableBuilder(
    column: $table.pendingContentFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingFiles => $composableBuilder(
    column: $table.pendingFiles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingVideoSha256 => $composableBuilder(
    column: $table.pendingVideoSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingVideoSize => $composableBuilder(
    column: $table.pendingVideoSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingAttachments => $composableBuilder(
    column: $table.pendingAttachments,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentLessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentLessonsTable> {
  $$ContentLessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get contentFormat => $composableBuilder(
    column: $table.contentFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get files =>
      $composableBuilder(column: $table.files, builder: (column) => column);

  GeneratedColumn<String> get videoSha256 => $composableBuilder(
    column: $table.videoSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get videoSize =>
      $composableBuilder(column: $table.videoSize, builder: (column) => column);

  GeneratedColumn<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingVersion => $composableBuilder(
    column: $table.pendingVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingContentFormat => $composableBuilder(
    column: $table.pendingContentFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingFiles => $composableBuilder(
    column: $table.pendingFiles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingVideoSha256 => $composableBuilder(
    column: $table.pendingVideoSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingVideoSize => $composableBuilder(
    column: $table.pendingVideoSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingAttachments => $composableBuilder(
    column: $table.pendingAttachments,
    builder: (column) => column,
  );
}

class $$ContentLessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentLessonsTable,
          ContentLesson,
          $$ContentLessonsTableFilterComposer,
          $$ContentLessonsTableOrderingComposer,
          $$ContentLessonsTableAnnotationComposer,
          $$ContentLessonsTableCreateCompanionBuilder,
          $$ContentLessonsTableUpdateCompanionBuilder,
          (
            ContentLesson,
            BaseReferences<_$AppDatabase, $ContentLessonsTable, ContentLesson>,
          ),
          ContentLesson,
          PrefetchHooks Function()
        > {
  $$ContentLessonsTableTableManager(
    _$AppDatabase db,
    $ContentLessonsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentLessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentLessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentLessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> lessonId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> contentFormat = const Value.absent(),
                Value<String> files = const Value.absent(),
                Value<String?> videoSha256 = const Value.absent(),
                Value<int?> videoSize = const Value.absent(),
                Value<String?> attachments = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<int?> pendingVersion = const Value.absent(),
                Value<int?> pendingContentFormat = const Value.absent(),
                Value<String?> pendingFiles = const Value.absent(),
                Value<String?> pendingVideoSha256 = const Value.absent(),
                Value<int?> pendingVideoSize = const Value.absent(),
                Value<String?> pendingAttachments = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentLessonsCompanion(
                lessonId: lessonId,
                version: version,
                contentFormat: contentFormat,
                files: files,
                videoSha256: videoSha256,
                videoSize: videoSize,
                attachments: attachments,
                installedAt: installedAt,
                pendingVersion: pendingVersion,
                pendingContentFormat: pendingContentFormat,
                pendingFiles: pendingFiles,
                pendingVideoSha256: pendingVideoSha256,
                pendingVideoSize: pendingVideoSize,
                pendingAttachments: pendingAttachments,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lessonId,
                Value<int> version = const Value.absent(),
                Value<int> contentFormat = const Value.absent(),
                Value<String> files = const Value.absent(),
                Value<String?> videoSha256 = const Value.absent(),
                Value<int?> videoSize = const Value.absent(),
                Value<String?> attachments = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<int?> pendingVersion = const Value.absent(),
                Value<int?> pendingContentFormat = const Value.absent(),
                Value<String?> pendingFiles = const Value.absent(),
                Value<String?> pendingVideoSha256 = const Value.absent(),
                Value<int?> pendingVideoSize = const Value.absent(),
                Value<String?> pendingAttachments = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentLessonsCompanion.insert(
                lessonId: lessonId,
                version: version,
                contentFormat: contentFormat,
                files: files,
                videoSha256: videoSha256,
                videoSize: videoSize,
                attachments: attachments,
                installedAt: installedAt,
                pendingVersion: pendingVersion,
                pendingContentFormat: pendingContentFormat,
                pendingFiles: pendingFiles,
                pendingVideoSha256: pendingVideoSha256,
                pendingVideoSize: pendingVideoSize,
                pendingAttachments: pendingAttachments,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentLessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentLessonsTable,
      ContentLesson,
      $$ContentLessonsTableFilterComposer,
      $$ContentLessonsTableOrderingComposer,
      $$ContentLessonsTableAnnotationComposer,
      $$ContentLessonsTableCreateCompanionBuilder,
      $$ContentLessonsTableUpdateCompanionBuilder,
      (
        ContentLesson,
        BaseReferences<_$AppDatabase, $ContentLessonsTable, ContentLesson>,
      ),
      ContentLesson,
      PrefetchHooks Function()
    >;
typedef $$ContentBlobsTableCreateCompanionBuilder =
    ContentBlobsCompanion Function({
      required String sha256,
      required int size,
      required BlobKind kind,
      required DateTime verifiedAt,
      Value<int> rowid,
    });
typedef $$ContentBlobsTableUpdateCompanionBuilder =
    ContentBlobsCompanion Function({
      Value<String> sha256,
      Value<int> size,
      Value<BlobKind> kind,
      Value<DateTime> verifiedAt,
      Value<int> rowid,
    });

class $$ContentBlobsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentBlobsTable> {
  $$ContentBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BlobKind, BlobKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentBlobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentBlobsTable> {
  $$ContentBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentBlobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentBlobsTable> {
  $$ContentBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BlobKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );
}

class $$ContentBlobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentBlobsTable,
          ContentBlob,
          $$ContentBlobsTableFilterComposer,
          $$ContentBlobsTableOrderingComposer,
          $$ContentBlobsTableAnnotationComposer,
          $$ContentBlobsTableCreateCompanionBuilder,
          $$ContentBlobsTableUpdateCompanionBuilder,
          (
            ContentBlob,
            BaseReferences<_$AppDatabase, $ContentBlobsTable, ContentBlob>,
          ),
          ContentBlob,
          PrefetchHooks Function()
        > {
  $$ContentBlobsTableTableManager(_$AppDatabase db, $ContentBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sha256 = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<BlobKind> kind = const Value.absent(),
                Value<DateTime> verifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentBlobsCompanion(
                sha256: sha256,
                size: size,
                kind: kind,
                verifiedAt: verifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sha256,
                required int size,
                required BlobKind kind,
                required DateTime verifiedAt,
                Value<int> rowid = const Value.absent(),
              }) => ContentBlobsCompanion.insert(
                sha256: sha256,
                size: size,
                kind: kind,
                verifiedAt: verifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentBlobsTable,
      ContentBlob,
      $$ContentBlobsTableFilterComposer,
      $$ContentBlobsTableOrderingComposer,
      $$ContentBlobsTableAnnotationComposer,
      $$ContentBlobsTableCreateCompanionBuilder,
      $$ContentBlobsTableUpdateCompanionBuilder,
      (
        ContentBlob,
        BaseReferences<_$AppDatabase, $ContentBlobsTable, ContentBlob>,
      ),
      ContentBlob,
      PrefetchHooks Function()
    >;
typedef $$ContentDownloadsTableCreateCompanionBuilder =
    ContentDownloadsCompanion Function({
      required String sha256,
      required int size,
      required BlobKind kind,
      required int priority,
      Value<int> received,
      Value<int> failures,
      Value<String?> lastError,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ContentDownloadsTableUpdateCompanionBuilder =
    ContentDownloadsCompanion Function({
      Value<String> sha256,
      Value<int> size,
      Value<BlobKind> kind,
      Value<int> priority,
      Value<int> received,
      Value<int> failures,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ContentDownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentDownloadsTable> {
  $$ContentDownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BlobKind, BlobKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get received => $composableBuilder(
    column: $table.received,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentDownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentDownloadsTable> {
  $$ContentDownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get received => $composableBuilder(
    column: $table.received,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentDownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentDownloadsTable> {
  $$ContentDownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BlobKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get received =>
      $composableBuilder(column: $table.received, builder: (column) => column);

  GeneratedColumn<int> get failures =>
      $composableBuilder(column: $table.failures, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContentDownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentDownloadsTable,
          ContentDownload,
          $$ContentDownloadsTableFilterComposer,
          $$ContentDownloadsTableOrderingComposer,
          $$ContentDownloadsTableAnnotationComposer,
          $$ContentDownloadsTableCreateCompanionBuilder,
          $$ContentDownloadsTableUpdateCompanionBuilder,
          (
            ContentDownload,
            BaseReferences<
              _$AppDatabase,
              $ContentDownloadsTable,
              ContentDownload
            >,
          ),
          ContentDownload,
          PrefetchHooks Function()
        > {
  $$ContentDownloadsTableTableManager(
    _$AppDatabase db,
    $ContentDownloadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentDownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentDownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentDownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sha256 = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<BlobKind> kind = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> received = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentDownloadsCompanion(
                sha256: sha256,
                size: size,
                kind: kind,
                priority: priority,
                received: received,
                failures: failures,
                lastError: lastError,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sha256,
                required int size,
                required BlobKind kind,
                required int priority,
                Value<int> received = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ContentDownloadsCompanion.insert(
                sha256: sha256,
                size: size,
                kind: kind,
                priority: priority,
                received: received,
                failures: failures,
                lastError: lastError,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentDownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentDownloadsTable,
      ContentDownload,
      $$ContentDownloadsTableFilterComposer,
      $$ContentDownloadsTableOrderingComposer,
      $$ContentDownloadsTableAnnotationComposer,
      $$ContentDownloadsTableCreateCompanionBuilder,
      $$ContentDownloadsTableUpdateCompanionBuilder,
      (
        ContentDownload,
        BaseReferences<_$AppDatabase, $ContentDownloadsTable, ContentDownload>,
      ),
      ContentDownload,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(_db, _db.lessonProgress);
  $$LessonPartProgressTableTableManager get lessonPartProgress =>
      $$LessonPartProgressTableTableManager(_db, _db.lessonPartProgress);
  $$OwnedItemsTableTableManager get ownedItems =>
      $$OwnedItemsTableTableManager(_db, _db.ownedItems);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$ConceptMasteryTableTableManager get conceptMastery =>
      $$ConceptMasteryTableTableManager(_db, _db.conceptMastery);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ContentManifestsTableTableManager get contentManifests =>
      $$ContentManifestsTableTableManager(_db, _db.contentManifests);
  $$ContentLessonsTableTableManager get contentLessons =>
      $$ContentLessonsTableTableManager(_db, _db.contentLessons);
  $$ContentBlobsTableTableManager get contentBlobs =>
      $$ContentBlobsTableTableManager(_db, _db.contentBlobs);
  $$ContentDownloadsTableTableManager get contentDownloads =>
      $$ContentDownloadsTableTableManager(_db, _db.contentDownloads);
}
