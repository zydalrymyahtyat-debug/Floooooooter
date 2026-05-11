# تطبيق زيد الريمي CV - Flutter

تم تحويل واجهة HTML إلى Flutter Native قدر الإمكان مع الحفاظ على:
- اللغة العربية RTL
- شاشة البداية بتأثير دائري
- الخلفية المتدرجة والشبكية
- بطاقة الملف الشخصي
- أقسام النبذة والخدمات والتواصل
- زر الاتصال المباشر

## البناء APK عبر Codemagic
1. ارفع هذا المشروع إلى GitHub.
2. افتح Codemagic واربط حساب GitHub.
3. اختر هذا المستودع.
4. اختر workflow باسم: `android-apk`.
5. اضغط Build.
6. بعد الانتهاء حمّل الملف من Artifacts:
   `app-release.apk`

## البناء محلياً
إذا كان Flutter مثبتاً لديك:
```bash
flutter create . --platforms=android
flutter pub get
flutter build apk --release
```

## تغيير الصورة الشخصية
استبدل الملف:
`assets/profile.jpg`
بنفس الاسم والصيغة.

## ملاحظة
تم الاحتفاظ بنسخة HTML الأصلية داخل:
`assets/original_index.html`
للمراجعة فقط.
