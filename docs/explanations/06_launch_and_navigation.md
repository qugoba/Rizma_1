# 06 — الإقلاع والتنقل (go_router)

**الملفات:** `lib/app/router.dart` · `lib/app/routes.dart` · `lib/features/launch/launch_plan.dart` · `lib/features/launch/launch_screen.dart` · `lib/features/profiles/active_profile_provider.dart`

## الغرض
عند فتح التطبيق يجب أن يعرف إلى أين يذهب دون أن يفكّر الطالب:

| الحالة على الجهاز | الوجهة |
|---|---|
| لا توجد ملفات | الترحيب `/welcome` ← إنشاء الملف (خطوتان) ← الرئيسية |
| ملف واحد بلا رمز سري | الرئيسية `/home` مباشرة |
| أكثر من ملف، أو ملف عليه رمز سري | «من يتعلّم الآن؟» `/profiles` |

وبعد اختيار ملف عليه رمز سري يمرّ الطالب بشاشة 27 قبل الرئيسية. وعند الضغط على «طالب جديد» يبدأ إنشاء الملف من الخطوة 1.

## `AppRoutes` — أسماء المسارات
| الثابت | المسار | الشاشة |
|---|---|---|
| `launch` | `/` | `LaunchScreen` (صامتة) |
| `welcome` | `/welcome` | الترحيب (01) |
| `createStep1` | `/create/step1` | الاسم والصف (02) |
| `createStep2` | `/create/step2` | اللون والرمز السري ورمز الصف (26) |
| `profiles` | `/profiles` | من يتعلّم الآن؟ (25) |
| `pinPattern` / `pin(id)` | `/pin/:id` | الرمز السري (27) |
| `home` | `/home` | الرئيسية (03/28) |
| `account` | `/account` | حسابي (19) — انظر `13_account_and_student_code.md` |
| `studentCode` | `/account/code` | رمز الطالب (29) |
| `downloads` | `/account/downloads` | إدارة التنزيلات (حالة فارغة) |

الثوابت في ملف مستقل (`routes.dart`) حتى تستورده الشاشات دون أن تستورد الراوتر (الذي يستورد الشاشات)، فنتجنب اعتمادًا دائريًا.

## القرار: `decideLaunchPlan` (دالة صرفة)
```dart
LaunchPlan decideLaunchPlan(List<Profile> profiles) {
  if (profiles.isEmpty) return LaunchPlan(LaunchTarget.welcome);
  if (profiles.length == 1 && profiles.single.pinHash == null) {
    return LaunchPlan(LaunchTarget.home, profileId: profiles.single.id);
  }
  return LaunchPlan(LaunchTarget.picker);
}
```
- ثلاث نتائج فقط (`LaunchTarget.welcome/home/picker`).
- دالة صرفة: تأخذ قائمة الملفات وتعيد خطة، فتُختبر بلا واجهة (`test/features/launch_plan_test.dart`: 4 اختبارات).
- `launchPlanProvider` (`FutureProvider.autoDispose`) يقرأ الملفات من المستودع ويستدعيها. `autoDispose` تجعله يُعاد حسابه كلما فُتحت شاشة الإقلاع من جديد.

## `LaunchScreen`
شاشة فيها الشخصية فقط. في `initState` تستدعي `_route()`:
1. `await ref.read(launchPlanProvider.future)`؛ إن فشلت قراءة القاعدة تنتقل إلى الترحيب (بدل شاشة عالقة).
2. بحسب `plan.target`:
   - `welcome` ← `context.go(welcome)`
   - `picker` ← `context.go(profiles)`
   - `home` ← `activeProfileIdProvider.notifier.select(profileId)` **ثم** `context.go(home)`. الاختيار أولًا لأن الرئيسية تقرأ الملف النشط.
3. تفحص `mounted` بعد كل `await` فلا تنتقل إن غادر المستخدم.

## `router.dart` — الراوتر
`routerProvider` (مزوّد Riverpod) ينشئ `GoRouter` بـ `initialLocation: AppRoutes.launch`. نقطتان خاصتان:
- **`/create/step2`** لها `redirect`: إن لم توجد مسودة من الخطوة 1 (`createProfileDraftProvider == null`) نعيد التوجيه إلى الخطوة 1. يحدث هذا مثلًا إن أُعيد فتح الرابط مباشرة.
- **`/home` و`/account` و`/account/code` و`/account/downloads`** لها نفس `redirect` (الدالة المحلية `requireActiveProfile` في `router.dart`):  إن كان `activeProfileIdProvider` تحمّل **وقيمته `null`** (لا ملف نشط) نعود إلى `/` فتقرر شاشة الإقلاع. بذلك لا تُعرض رئيسية بلا طالب.
- **`/pin/:id`**: يُستخرج `id` من `state.pathParameters['id']` ويُمرَّر لـ `PinEntryScreen`.

## `activeProfileProvider` / `activeProfileIdProvider`
| المزوّد | نوعه | وظيفته |
|---|---|---|
| `activeProfileIdProvider` | `AsyncNotifierProvider<…, String?>` | معرّف الملف النشط المحفوظ في `app_settings`. `build` يقرأه من القاعدة. |
| ↳ `select(id)` | دالة | `setActive` (يحدّث `lastActiveAt` ويحفظ المعرّف) ثم يحدّث الحالة. |
| ↳ `reload()` | دالة | يعيد القراءة من القاعدة (بعد إنشاء ملف جديد). |
| `activeProfileProvider` | `StreamProvider<Profile?>` | الملف النشط نفسه؛ يتحدّث تلقائيًا عند تغيّر بياناته. إن كان المعرّف `null` يصدر `null`. |

## ملاحظات
- شاشة الإقلاع تنتقل بـ `go` (لا `push`) فلا يستطيع الطالب الرجوع إليها بزر الرجوع.
- أضفنا في الاختبارات تثبيت `defaultRouteNameTestValue` على `/` لأن go_router يقرأ مسار المنصّة الافتراضي (انظر `12_testing.md`).
- التنقل من «حسابي» إلى «تبديل الطالب» سيُضاف في المرحلة 6؛ الآن يمكن الوصول لشاشة الاختيار بإعادة فتح التطبيق أو من أدوات التطوير (debug).
