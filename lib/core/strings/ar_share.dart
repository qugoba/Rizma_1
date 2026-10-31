abstract final class ArShare {
  static const cardTitle = 'شارك الدروس مع هاتف آخر';
  static const cardBody =
      'نزّلها مرة من الإنترنت، وأعطها لأصحابك بدون إنترنت: ملف على واتساب أو بلوتوث أو بطاقة ذاكرة.';
  static const cardSend = 'شارك';
  static const cardReceive = 'استلم';

  static const sendTitle = 'شارك الدروس';
  static const sendKicker = 'ملف «رزمة» واحد لهاتف آخر';
  static String sendCore(String size) => 'الدروس وتحديثاتها · $size';
  static const sendCoreNote = 'تُرسل دائمًا مع الملف.';
  static const sendVideos = 'الفيديو';
  static const sendFiles = 'ملفات الدروس';
  static const sendNothing =
      'لا شيء للمشاركة بعد. افتح التطبيق وأنت متصل بالإنترنت مرة، ثم ارجع هنا.';
  static String sendButton(String size) => 'أرسل ملف رزمة ($size)';
  static String sendPreparing(int percent) => 'جارٍ تجهيز الملف · $percent٪';
  static const sendNote =
      'أرسله بواتساب أو بلوتوث، أو احفظه على بطاقة الذاكرة. الهاتف الثاني يفتحه من «استلم دروسًا».';
  static const sendFailed = 'تعذّر تجهيز الملف. تأكد من وجود مساحة على الهاتف.';
  static const sendWifi = 'أرسل على Wi-Fi';

  static const wifiTitle = 'أرسل على Wi-Fi';
  static const wifiKicker = 'للهواتف القريبة على نفس الشبكة';
  static const wifiCode = 'رمز هذا الهاتف';
  static const wifiSteps =
      'على الهاتف الثاني: التنزيلات ← استلم ← ابحث عن هاتف قريب، واختر هذا الرمز.';
  static String wifiAddress(String address) => 'العنوان: $address';
  static const wifiKeepOpen =
      'خلّ هذه الشاشة مفتوحة حتى ينتهي الآخرون (الشاشة لن تنطفئ وحدها). يمكن لأكثر من هاتف أن يستلم معًا.';
  static String wifiSent(String size) => 'أُرسل حتى الآن: $size';
  static const wifiStop = 'أوقف الإرسال';
  static const wifiNoNetwork =
      'هذا الهاتف ليس على شبكة Wi-Fi. اتصل بشبكة، أو شغّل نقطة الاتصال (هوتسبوت) وخلّ الهاتف الثاني يتصل بها.';
  static const wifiFailed = 'تعذّر بدء الإرسال. أغلق الشاشة وافتحها مرة ثانية.';
  static const wifiStarting = 'جارٍ التجهيز…';

  static const nearbySend = 'شارك مع القريبين (بدون نت)';
  static const nearbyTitle = 'شارك مع القريبين';
  static const nearbyKicker = 'بلا إنترنت ولا شبكة';
  static const nearbySteps =
      'على الهواتف الأخرى: التنزيلات ← استلم ← استقبل من القريبين، واختر هذا الرمز. أكثر من هاتف يستلم معًا.';
  static String nearbyConnected(int n) => 'هواتف متصلة الآن: $n';
  static const nearbyKeepOpen =
      'خلّ هذه الشاشة مفتوحة والهواتف قريبة منك (الشاشة لن تنطفئ وحدها).';
  static const nearbyReceive = 'استقبل من القريبين (بدون نت)';
  static const nearbyReceiveNote =
      'الهاتف الثاني فاتح «شارك مع القريبين» وقريب منك. لا يحتاج إنترنت ولا Wi-Fi.';
  static const nearbySearching = 'جارٍ البحث عن هواتف قريبة…';
  static const nearbyNoneYet =
      'ما ظهر هاتف بعد. تأكد أن الهاتف الثاني فاتح «شارك مع القريبين» وأنه قريب منك.';
  static const nearbyCantConnect =
      'تعذّر الاتصال بالهاتف. قرّبه منك وجرّب مرة ثانية.';
  static const nearbyPermission =
      'اسمح للتطبيق بالوصول إلى «الأجهزة القريبة» ليجد الهواتف بدون إنترنت، ثم جرّب مرة ثانية.';
  static const nearbyLocationOff =
      'شغّل «الموقع» (Location) من أعلى الشاشة: أندرويد يحتاجه ليجد الهواتف القريبة. لا نستعمل موقعك.';
  static const nearbyUnsupported =
      'هذا الهاتف لا يدعم المشاركة مع القريبين (بلا خدمات Google). استعمل «أرسل على Wi-Fi» مع الهوتسبوت.';
  static const nearbyAgain = 'جرّب مرة ثانية';

  static const spreadTitle = 'صار عندك الدروس. أعطها لغيرك بدون إنترنت!';
  static const spreadButton = 'انشر الدروس';

  static const receiveTitle = 'استلم دروسًا';
  static const receiveKicker = 'من ملف رزمة أو من هاتف قريب';
  static const receivePickFile = 'اختر ملف رزمة';
  static const receivePickNote =
      'الملف الذي وصلك بواتساب أو بلوتوث أو على بطاقة الذاكرة (ينتهي بـ .rizma).';
  static const receiveOpening = 'جارٍ فحص الملف…';
  static const receiveNotPackage = 'هذا ليس ملف رزمة صالحًا.';
  static const receiveUntrusted =
      'لم نستطع التأكد من هذا الملف، فلم نأخذ منه شيئًا. اطلب من صاحبه أن يرسله مرة ثانية.';
  static const receiveNothingNew = 'كل ما في هذا الملف موجود على هاتفك.';
  static const receiveChoose = 'اختر ما تأخذه';
  static String receiveButton(String size) => 'أضف إلى الهاتف ($size)';
  static const receiveDone = 'تمت الإضافة ✓ تفتحها الآن دون إنترنت.';
  static const receiveSomeMissing =
      'بعض الملفات لم تصل سليمة، فلم تُضف. تنزل من الإنترنت لاحقًا.';
  static const receiveAnother = 'استلم ملفًا آخر';
  static const receiveFindPhone = 'ابحث عن هاتف قريب';
  static const receiveFindNote =
      'الهاتفان على نفس الـ Wi-Fi (أو هوتسبوت)، والثاني فاتح «أرسل على Wi-Fi».';
  static const receiveSearching = 'جارٍ البحث عن هواتف قريبة…';
  static String receivePhone(String code) => 'هاتف برمز $code';
  static const receiveNoPhones =
      'ما وجدنا هاتفًا. تأكد أن الهاتفين على نفس الشبكة وأن الثاني فاتح «أرسل على Wi-Fi». إن بقي هكذا فبعض الراوترات تمنع الهواتف من الاتصال ببعض: شغّل الهوتسبوت على أحد الهاتفين وخلّ الثاني يتصل به، أو اكتب العنوان تحت.';
  static const failTimeout =
      'ما ردّ الهاتف الثاني. إما أنه ليس على نفس الشبكة، أو أن الراوتر يمنع الهواتف من الاتصال ببعض (يحصل كثيرًا). جرّبوا الهوتسبوت: شغّله على هاتف وخلّ الثاني يتصل به.';
  static const failRefused =
      'وصلنا للهاتف الثاني، لكن «أرسل على Wi-Fi» ليس مفتوحًا عنده. افتحه وخلّ شاشته مفتوحة.';
  static const failUnreachable =
      'هذا العنوان ليس على شبكتك. تأكد من العنوان ومن أن الهاتفين على نفس الـ Wi-Fi.';
  static const failNotRizma = 'في جهاز على هذا العنوان، لكنه ليس هاتف رزمة.';
  static const receiveSearchAgain = 'ابحث مرة ثانية';
  static String receiveOwnAddress(String address, String prefix) =>
      'عنوان هاتفك: $address. عنوان الهاتف الثاني لازم يبدأ بـ $prefix وإلا فهما على شبكتين مختلفتين.';
  static String receiveOwnAddressOnly(String address) =>
      'عنوان هاتفك: $address.';
  static const receiveNoWifi =
      'هاتفك ليس متصلًا بشبكة Wi-Fi. اتصل بنفس شبكة الهاتف الثاني أو بالهوتسبوت تبعه.';
  static const receiveAddressHint = 'أو اكتب العنوان الظاهر على الهاتف الثاني';
  static const receiveConnect = 'اتصل';
  static const receiveConnecting = 'جارٍ الاتصال…';
  static const receiveCantConnect =
      'تعذّر الاتصال بالهاتف. تأكد أنه ما زال فاتحًا «أرسل على Wi-Fi».';
  static const receiveSafety =
      'كل درس يُفحص قبل إضافته: ما لم ننشره نحن لا يُقبل.';
}
