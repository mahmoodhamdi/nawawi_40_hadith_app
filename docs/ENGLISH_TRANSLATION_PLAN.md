# خطة إضافة الترجمة الإنجليزية للأحاديث الأربعين النووية

## نظرة عامة
إنشاء ملف JSON يحتوي على الترجمة الإنجليزية الكاملة للأحاديث الأربعين النووية (42 حديث) مع الشروحات.

## البنية المطلوبة

### مكان الملف
```
D:\nawawi_40_hadith_app\assets\json\40-hadith-nawawi-en.json
```

### بنية JSON
```json
[
  {
    "hadith": "English hadith text with narrator and source",
    "description": "English explanation/commentary"
  }
]
```

## مصادر الترجمة

سنستخدم الترجمات المعتمدة والموثوقة للأحاديث الأربعين النووية:

1. **ترجمة عزيز الدين - Ezzeddin Ibrahim & Denys Johnson-Davies** - الأكثر انتشاراً
2. **ترجمة Jamal al-Din Zarabozo** - ترجمة دقيقة مع شروح مفصلة
3. **ترجمة النووي من مواقع معتمدة** مثل:
   - Sunnah.com
   - IslamicStudies.info
   - Islamicity

## المحتوى المطلوب

### لكل حديث:
1. **رقم الحديث** (Hadith 1-42)
2. **اسم الراوي بالإنجليزية** (e.g., Umar ibn al-Khattab)
3. **نص الحديث المترجم** مع المصدر (Bukhari, Muslim, etc.)
4. **الشرح/التفسير** - ملخص مختصر ومفيد للحديث

### الأحاديث الـ 42:

1. **Hadith 1** - Actions by Intentions (Umar - Bukhari & Muslim)
2. **Hadith 2** - Angel Jibreel on Islam, Iman, Ihsan (Umar - Muslim)
3. **Hadith 3** - Five Pillars of Islam (Ibn Umar - Bukhari & Muslim)
4. **Hadith 4** - Stages of Creation (Ibn Mas'ud - Bukhari & Muslim)
5. **Hadith 5** - Rejection of Innovation (Aisha - Bukhari & Muslim)
6. **Hadith 6** - Halal and Haram (Nu'man ibn Bashir - Bukhari & Muslim)
7. **Hadith 7** - Religion is Sincerity (Tamim ad-Dari - Muslim)
8. **Hadith 8** - Sanctity of Muslim (Ibn Umar - Bukhari & Muslim)
9. **Hadith 9** - Prohibited Things (Abu Hurairah - Bukhari & Muslim)
10. **Hadith 10** - Pure Earnings (Abu Hurairah - Muslim)
11. **Hadith 11** - Leaving Doubtful Matters (Al-Hasan ibn Ali - Tirmidhi)
12. **Hadith 12** - Good Islam (Abu Hurairah - Tirmidhi)
13. **Hadith 13** - Love for Others (Anas - Bukhari & Muslim)
14. **Hadith 14** - Inviolability of Muslim Blood (Ibn Mas'ud - Bukhari & Muslim)
15. **Hadith 15** - Belief in Allah & Last Day (Abu Hurairah - Bukhari & Muslim)
16. **Hadith 16** - Do Not Get Angry (Abu Hurairah - Bukhari)
17. **Hadith 17** - Excellence in All Things (Shaddad ibn Aws - Muslim)
18. **Hadith 18** - Taqwa & Good Character (Abu Dharr & Mu'adh - Tirmidhi)
19. **Hadith 19** - Believe in Qadar (Ibn Abbas - Tirmidhi)
20. **Hadith 20** - Modesty (Abu Mas'ud - Bukhari & Muslim)
21. **Hadith 21** - Say I Believe in Allah (Sufyan ibn Abdullah - Muslim)
22. **Hadith 22** - Path to Paradise (Jabir - Muslim)
23. **Hadith 23** - Purity is Half of Faith (Thawban - Muslim)
24. **Hadith 24** - Prohibition of Oppression (Abu Dharr - Muslim - Qudsi)
25. **Hadith 25** - Charity for Every Joint (Abu Hurairah - Bukhari & Muslim)
26. **Hadith 26** - Every Good Deed is Charity (Abu Hurairah - Bukhari & Muslim)
27. **Hadith 27** - Righteousness and Sin (Nawwas ibn Sam'an - Muslim)
28. **Hadith 28** - Stick to the Sunnah (Al-Irbad ibn Sariyah - Tirmidhi)
29. **Hadith 29** - Path to Paradise (Mu'adh - Tirmidhi)
30. **Hadith 30** - Rights of Allah (Abu Tha'labah - Tirmidhi)
31. **Hadith 31** - True Asceticism (Abu Abbas - Ibn Majah)
32. **Hadith 32** - No Harm (Abu Said - Ibn Majah)
33. **Hadith 33** - Burden of Proof (Ibn Abbas - Bayhaqi)
34. **Hadith 34** - Changing Evil (Abu Said - Muslim)
35. **Hadith 35** - Brotherhood of Believers (Abu Hurairah - Bukhari & Muslim)
36. **Hadith 36** - Relief from Distress (Abu Hurairah - Bukhari & Muslim)
37. **Hadith 37** - Allah's Kindness to Creation (Ibn Abbas - Muslim - Qudsi)
38. **Hadith 38** - Allah's Love (Abu Hurairah - Muslim - Qudsi)
39. **Hadith 39** - Allah Overlooks Mistakes (Ibn Abbas - Bukhari & Muslim)
40. **Hadith 40** - Be in the World as a Stranger (Ibn Umar - Bukhari)
41. **Hadith 41** - Follow the Prophet (Unknown - Ahmad & Tabarani)
42. **Hadith 42** - Allah's Vastness (Anas - Bukhari)

## خطوات التنفيذ

### المرحلة 1: إنشاء الملف الأساسي
- إنشاء ملف `40-hadith-nawawi-en.json` في مجلد assets/json
- التأكد من صحة بنية JSON

### المرحلة 2: ترجمة الأحاديث
- جمع الترجمات المعتمدة لكل حديث
- التأكد من دقة الترجمة والمراجع
- إضافة اسم الراوي والمصدر

### المرحلة 3: إضافة الشروحات
- كتابة شرح موجز لكل حديث باللغة الإنجليزية
- التركيز على المعاني الأساسية والدروس المستفادة
- الحفاظ على الإيجاز والوضوح

### المرحلة 4: المراجعة والتدقيق
- التحقق من صحة بنية JSON
- مراجعة الترجمات والتأكد من دقتها
- التأكد من اكتمال جميع الأحاديث الـ 42

### المرحلة 5: التكامل مع التطبيق
- تحديث الكود ليدعم التبديل بين العربية والإنجليزية
- إضافة ملفات الترجمة (i18n) إذا لزم الأمر
- تحديث ملف constants.dart لإضافة مسار الملف الإنجليزي

## معايير الجودة

### الترجمة:
- دقيقة وموثوقة
- تحافظ على المعنى الأصلي
- سلسة وسهلة الفهم
- متوافقة مع الترجمات المعتمدة

### الشروحات:
- مختصرة وواضحة (2-4 جمل لكل حديث)
- تشرح المعنى الأساسي
- توضح الدروس المستفادة
- باللغة الإنجليزية البسيطة

### البنية التقنية:
- JSON صحيح وخالي من الأخطاء
- ترميز UTF-8
- تنسيق موحد ومنظم
- متوافق مع البنية العربية

## الاختبار بعد التنفيذ

1. **التحقق من صحة JSON**: استخدام أدوات التحقق من JSON
2. **قراءة الملف في التطبيق**: التأكد من أن التطبيق يقرأ الملف بشكل صحيح
3. **مراجعة المحتوى**: التحقق من دقة الترجمات والشروحات
4. **الاختبار الشامل**: اختبار عرض جميع الأحاديث في التطبيق

## الجدول الزمني

- **إنشاء الملف**: فوري
- **الترجمة والشروحات**: حسب توفر المصادر
- **المراجعة**: بعد الانتهاء من الترجمة
- **التكامل**: بعد التأكد من صحة الملف

## ملاحظات مهمة

1. الأحاديث 41 و 42 أُضيفت لاحقاً بواسطة الإمام ابن رجب الحنبلي
2. يجب التأكد من دقة نسبة الحديث للراوي والمصدر
3. الشروحات يجب أن تكون موجزة ومفيدة
4. الحفاظ على نفس ترتيب الأحاديث في الملف العربي
