import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/downloads/blob_store.dart';
import 'package:rizma/features/downloads/download_service.dart';
import 'package:rizma/features/downloads/manifest.dart';

import '../helpers/fake_content_server.dart' show shaOf;

bool get _hasNode {
  try {
    return Process.runSync('node', ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

void main() {
  final skip = _hasNode ? null : 'Node غير مثبت';
  late Directory tmp;
  late String keyPath;
  late List<int> publicKey;

  ProcessResult node(String script, List<String> args) => Process.runSync(
    'node',
    ['tools/content/$script', ...args],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );

  String p(String rel) => '${tmp.path}/$rel';

  ProcessResult publish() => node('publish.js', [
    '--grade',
    '5',
    '--key',
    keyPath,
    '--out',
    p('out'),
    '--assets',
    p('assets'),
    '--media',
    p('media'),
    '--state',
    p('state'),
    '--now',
    '2026-10-26T10:00:00Z',
  ]);

  Future<(List<int>, List<int>)> published() async => (
    await File(p('out/v1/grades/5/manifest.json')).readAsBytes(),
    await File(p('out/v1/grades/5/manifest.json.sig')).readAsBytes(),
  );

  setUp(() async {
    if (skip != null) return;
    tmp = await Directory.systemTemp.createTemp('rizma_publish');
    await Directory(p('assets/lessons')).create(recursive: true);
    await File(
      'assets/content/catalog_grade5.json',
    ).copy(p('assets/catalog_grade5.json'));
    for (final f in Directory('assets/content/lessons').listSync()) {
      if (f is File && f.path.endsWith('.json')) {
        await f.copy(p('assets/lessons/${f.uri.pathSegments.last}'));
      }
    }
    await Directory(p('state')).create(recursive: true);
    await File(p('state/grade5.manifest.json')).writeAsString(
      jsonEncode({
        'format': 1,
        'grade': 5,
        'sequence': 0,
        'lessons': [
          for (final f in Directory('assets/content/lessons').listSync())
            if (f is File && f.path.endsWith('.json'))
              if (jsonDecode(f.readAsStringSync())
                  case final Map<String, dynamic> lesson
                  when lesson['video'] != null || lesson['attachments'] != null)
                {
                  'id': lesson['lessonId'],
                  'version': 0,
                  'content_format': 1,
                  'files': <Object>[],
                  if (lesson['video'] case {'file': final String sha})
                    'video': {'sha256': sha, 'size': 1000},
                  'attachments': [
                    for (final a in (lesson['attachments'] as List?) ?? [])
                      {
                        'sha256': a['file'],
                        'size': (a['sizeKb'] as int) * 1024,
                      },
                  ],
                },
        ],
      }),
    );
    keyPath = p('keys/content.pem');
    final gen = node('keygen.js', [keyPath]);
    expect(gen.exitCode, 0, reason: '${gen.stderr}');
    publicKey = base64.decode(
      (gen.stdout as String).trim().split('\n').last.trim(),
    );
  });

  tearDown(() async {
    if (skip == null) await tmp.delete(recursive: true);
  });

  test(
    'فيديو مذكور في الدرس وغير موجود محليًا ولا منشورًا: يرفض بوضوح',
    () async {
      await File(p('state/grade5.manifest.json')).delete();
      final r = publish();
      expect(r.exitCode, 1);
      expect(r.stderr, contains('غير موجود'));
    },
    skip: skip,
  );

  test('فيديو منشور سابقًا يبقى في الفهرس دون ملفه محليًا', () async {
    expect(publish().exitCode, 0);
    final m = Manifest.parse(utf8.decode((await published()).$1));
    final english = m.lessons.firstWhere((l) => l.id == 'english.u1.l1');
    expect(
      english.video?.sha256,
      '7a85c0d0baee4b56720fdd039de01ac26eb074de83a15c2fb4bef16b09387297',
    );
  }, skip: skip);

  test('المفتاح الخاص لا يُحفظ داخل المستودع', () {
    final r = node('keygen.js', ['build/should-not-exist.pem']);
    expect(r.exitCode, isNot(0));
    expect(File('build/should-not-exist.pem').existsSync(), isFalse);
  }, skip: skip);

  group('أداة الرفع (upload.js)', () {
    test('توقيع الطلبات يطابق مثال AWS الموثّق (SigV4)', () {
      final r = node('upload.js', ['--self-test']);
      expect(r.exitCode, 0, reason: '${r.stderr}');
    }, skip: skip);

    test('تجربة الرفع تعدّ ملفات الفهرس دون اتصال', () async {
      expect(publish().exitCode, 0);
      final r = node('upload.js', [
        '--grade',
        '5',
        '--out',
        p('out'),
        '--dry-run',
      ]);
      expect(r.exitCode, 0, reason: '${r.stderr}');
      final m = Manifest.parse(utf8.decode((await published()).$1));
      final files = {
        m.catalog!.sha256,
        for (final l in m.lessons) ...l.fileMap.values,
        for (final l in m.lessons)
          if (l.video != null) l.video!.sha256,
        for (final l in m.lessons) ...l.attachmentSizes.keys,
      };
      expect(r.stdout, contains('${files.length} ملفًا'));
    }, skip: skip);

    test('بلا مفاتيح R2 في الطرفية يرفض بوضوح ولا يرفع شيئًا', () {
      expect(publish().exitCode, 0);
      final r = Process.runSync(
        'node',
        ['tools/content/upload.js', '--grade', '5', '--out', p('out')],
        environment: {
          'R2_ACCOUNT_ID': '',
          'R2_ACCESS_KEY_ID': '',
          'R2_SECRET_ACCESS_KEY': '',
        },
        stderrEncoding: utf8,
      );
      expect(r.exitCode, 1);
      expect(r.stderr, contains('R2_ACCESS_KEY_ID'));
    }, skip: skip);

    test('ملف لا يطابق بصمته محليًا يوقف الرفع قبل أي اتصال', () async {
      expect(publish().exitCode, 0);
      final m = Manifest.parse(utf8.decode((await published()).$1));
      final sha = m.lessons.first.fileMap['lesson.json']!;
      await File(p('out/v1/blobs/$sha')).writeAsString('تالف');
      final r = node('upload.js', [
        '--grade',
        '5',
        '--out',
        p('out'),
        '--dry-run',
      ]);
      expect(r.exitCode, 1);
      expect(r.stderr, contains('لا يطابق بصمته'));
    }, skip: skip);
  });

  test(
    'الفهرس المنشور: توقيعه صحيح عند الهاتف، وبصماته تطابق محتوى التطبيق',
    () async {
      final r = publish();
      expect(r.exitCode, 0, reason: '${r.stderr}');

      final (body, sig) = await published();
      expect(await ManifestVerifier([publicKey]).verify(body, sig), isTrue);
      final m = Manifest.parse(utf8.decode(body));
      expect(m.grade, 5);
      expect(m.sequence, 1);
      final ids = {
        for (final f in Directory('assets/content/lessons').listSync())
          if (f.path.endsWith('.json'))
            f.uri.pathSegments.last.replaceAll('.json', ''),
      };
      expect(m.lessons.map((l) => l.id).toSet(), ids);
      for (final l in m.lessons) {
        expect(l.version, 1);
        expect(
          l.fileMap['lesson.json'],
          shaOf(File('assets/content/lessons/${l.id}.json').readAsBytesSync()),
        );
      }
      expect(
        m.catalog!.sha256,
        shaOf(File('assets/content/catalog_grade5.json').readAsBytesSync()),
      );
      for (final l in m.lessons) {
        for (final f in l.files) {
          expect(
            shaOf(File(p('out/v1/blobs/${f.sha256}')).readAsBytesSync()),
            f.sha256,
          );
        }
      }
    },
    skip: skip,
  );

  test(
    'نشر ثانٍ بلا تغيير لا يفعل شيئًا، وتعديل درس يرفع نسخته وحده',
    () async {
      expect(publish().exitCode, 0);
      final again = publish();
      expect(again.exitCode, 0);
      expect(again.stdout, contains('لا جديد'));
      expect(Manifest.parse(utf8.decode((await published()).$1)).sequence, 1);

      final file = File(p('assets/lessons/math.u1.l1.json'));
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      json['note'] = 'تصحيح من المعلم';
      await file.writeAsString(jsonEncode(json));
      expect(publish().exitCode, 0);

      final m = Manifest.parse(utf8.decode((await published()).$1));
      expect(m.sequence, 2);
      for (final l in m.lessons) {
        expect(l.version, l.id == 'math.u1.l1' ? 2 : 1, reason: l.id);
      }
    },
    skip: skip,
  );

  test('صورة وفيديو من مجلد الوسائط يدخلان الحزمة والفيديو منفصل', () async {
    await Directory(p('media/math.u3.l3/img')).create(recursive: true);
    await File(p('media/math.u3.l3/img/bar.webp')).writeAsBytes([1, 2, 3]);
    await File(p('media/math.u3.l3/video.mp4')).writeAsBytes([4, 5, 6, 7]);
    expect(publish().exitCode, 0);
    final l = Manifest.parse(
      utf8.decode((await published()).$1),
    ).lessons.firstWhere((l) => l.id == 'math.u3.l3');
    expect(l.fileMap.keys, containsAll(['lesson.json', 'img/bar.webp']));
    expect(l.video!.sha256, shaOf([4, 5, 6, 7]));
    expect(l.videoMinutes, 4);
  }, skip: skip);

  group('الملفات المرفقة', () {
    final pdf = utf8.encode('%PDF-1.4 ملخص');
    Future<void> declare(List<Map<String, Object>> attachments) async {
      final file = File(p('assets/lessons/math.u1.l1.json'));
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      json['attachments'] = attachments;
      await file.writeAsString(jsonEncode(json));
    }

    Future<void> putLocal(List<int> bytes) async {
      await Directory(
        p('media/math.u1.l1/attachments'),
      ).create(recursive: true);
      await File(
        p('media/math.u1.l1/attachments/summary.pdf'),
      ).writeAsBytes(bytes);
    }

    test('مرفق من مجلد الوسائط يدخل الفهرس منفصلًا عن الحزمة', () async {
      await putLocal(pdf);
      await declare([
        {'title': 'ملخص', 'file': shaOf(pdf), 'sizeKb': 1},
      ]);
      expect(publish().exitCode, 0);
      final m = Manifest.parse(utf8.decode((await published()).$1));
      final l = m.lessons.firstWhere((l) => l.id == 'math.u1.l1');
      expect(l.attachmentSizes, {shaOf(pdf): pdf.length});
      expect(l.fileMap.keys, ['lesson.json']);
      expect(File(p('out/v1/blobs/${shaOf(pdf)}')).readAsBytesSync(), pdf);

      final english = m.lessons.firstWhere((l) => l.id == 'english.u1.l1');
      expect(english.attachments, hasLength(1));
    }, skip: skip);

    test('حجم خاطئ، أو ملف لا يذكره الدرس، أو غير موجود: يرفض بوضوح', () async {
      await putLocal(pdf);
      await declare([
        {'title': 'ملخص', 'file': shaOf(pdf), 'sizeKb': 7},
      ]);
      var r = publish();
      expect(r.exitCode, 1);
      expect(r.stderr, contains('sizeKb'));

      await declare([]);
      r = publish();
      expect(r.exitCode, 1);
      expect(r.stderr, contains(shaOf(pdf)));

      await File(p('media/math.u1.l1/attachments/summary.pdf')).delete();
      await declare([
        {'title': 'ملخص', 'file': shaOf(pdf), 'sizeKb': 1},
      ]);
      r = publish();
      expect(r.exitCode, 1);
      expect(r.stderr, contains('غير موجود'));
    }, skip: skip);
  });

  test(
    'من الأداة إلى الهاتف: المطابق يُنسخ من التطبيق، والمعدَّل وحده يُنزَّل',
    () async {
      expect(publish().exitCode, 0);
      final file = File(p('assets/lessons/math.u1.l2.json'));
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      json['note'] = 'نسخة 2';
      await file.writeAsString(jsonEncode(json));
      expect(publish().exitCode, 0);

      final downloaded = <String>[];
      final client = MockClient((req) async {
        final f = File(p('out${req.url.path}'));
        if (!f.existsSync()) return http.Response('', 404);
        if (req.url.path.startsWith('/v1/blobs/')) {
          downloaded.add(req.url.pathSegments.last);
        }
        return http.Response.bytes(await f.readAsBytes(), 200, request: req);
      });
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = BlobStore(Directory(p('phone')));
      final service = DownloadService(
        db,
        store,
        ContentConfig(
          baseUrl: Uri.parse('https://content.test/'),
          publicKeys: [publicKey],
        ),
        client: client,
        bundledLessonFile: (id, path) async =>
            File('assets/content/lessons/$id.json').readAsBytes(),
        bundledCatalog: (_) async =>
            File('assets/content/catalog_grade5.json').readAsBytes(),
      );

      expect(
        await service.checkGrade(5, autoVideo: false),
        CheckResult.updated,
      );
      expect(await service.runQueue(), RunResult.done);
      expect(downloaded, [shaOf(await file.readAsBytes())]);
      expect((await db.contentDao.lesson('math.u1.l2'))!.version, 2);
      expect((await db.contentDao.lesson('math.u1.l1'))!.version, 1);
    },
    skip: skip,
  );
}
