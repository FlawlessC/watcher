import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:my_list_app/update_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final GoogleSignIn appGoogleSignIn = GoogleSignIn(
  clientId:
      '92396295432-28qavr9votkv53p98u6sdlhfpet9vuru.apps.googleusercontent.com', // Web Client ID из Firebase
  scopes: <String>['email', 'profile'],
);

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Обязательно передаем опции текущей платформы
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        // Заменили __ на _
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.indigo,
          ),
          // Проверь, что AuthGate() написан без ошибок
          home: const AuthGate(),
        );
      },
    );
  }
}

// Этот класс решает: показать экран входа или само приложение
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInScreen();
        }
        return const App();
      },
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Future<void> _signInWithGoogle() async {
    try {
      final firebaseAuth = FirebaseAuth.instance;

      // 🌐 WEB → redirect flow (без popup вообще)
      if (kIsWeb) {
        final provider = GoogleAuthProvider();

        await firebaseAuth.signInWithRedirect(provider);
        return;
      }

      // 📱 ANDROID / IOS → native Firebase Google provider
      final provider = GoogleAuthProvider();

      final userCredential = await firebaseAuth.signInWithPopup(provider);

      if (userCredential.user != null) {
        debugPrint("Login success: ${userCredential.user!.email}");
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuth error: ${e.code}");
    } catch (e) {
      debugPrint("Unknown error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 100, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              "Мой Список",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Войти через Google"),
              onPressed: _signInWithGoogle, // Теперь кнопка увидит метод
            ),
          ],
        ),
      ),
    );
  }
} // <--- ПРОВЕРЬ, ЧТО ЭТА СКОБКА ЕСТЬ И ОНА ЗАКРЫВАЕТ КЛАСС

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController ctrl = TextEditingController();
  final TextEditingController catCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController currentProgCtrl = TextEditingController();
  final TextEditingController totalProgCtrl = TextEditingController();

  String progressUnit = 'серия';
  List<String> selectedFilters = ['Все'];
  String get filter =>
      selectedFilters.contains('Все') ? 'Все' : selectedFilters.join(', ');
  String searchQuery = "";
  final Set<String> selected = {};

  Future<void> _ensureDefaultCategories() async {
    if (currentUserId.isEmpty) return;
    HapticFeedback.selectionClick();
    var snap = await FirebaseFirestore.instance
        .collection('categories')
        .where('userId', isEqualTo: currentUserId)
        .get();

    if (snap.docs.isEmpty) {
      final batch = FirebaseFirestore.instance.batch();

      final categories = ['Книги', 'Фильмы', 'Сериалы', 'Аниме', 'Игры'];

      for (int i = 0; i < categories.length; i++) {
        var ref = FirebaseFirestore.instance.collection('categories').doc();

        batch.set(ref, {
          'name': categories[i],
          'index': i,
          'userId': currentUserId,
        });
      }

      await batch.commit();
    }
    return;
  }

  Future<void> downloadAndInstall(String url) async {
    final dir = await getExternalStorageDirectory();
    final filePath = "${dir!.path}/update.apk";

    await Dio().download(url, filePath);

    await OpenFile.open(filePath);
  }

  void showUpdateDialog(String apkUrl, String changelog) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Доступно обновление"),
        content: Text(changelog),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Позже"),
          ),
          TextButton(
            onPressed: () {
              downloadAndInstall(apkUrl);
            },
            child: const Text("Обновить"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleWebRedirectResult() async {
    if (!kIsWeb) return;

    final result = await FirebaseAuth.instance.getRedirectResult();

    if (result.user != null) {
      debugPrint("Web login success: ${result.user!.email}");
    }
  }

  @override
  void initState() {
    super.initState();

    _ensureDefaultCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });

    _handleWebRedirectResult();
  }

  bool _updateCheckRunning = false;

  void _checkForUpdate() {
    if (_updateCheckRunning) return;
    _updateCheckRunning = true;

    UpdateService.checkForUpdate(
      onUpdate: (apkUrl, changelog) {
        if (!mounted) return;
        showUpdateDialog(apkUrl, changelog);
      },
    ).whenComplete(() {
      _updateCheckRunning = false;
    });
  }

  void _showAddCategoryDialog() {
    // Локальный контроллер, не пересекается с полем класса
    final TextEditingController newCatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый список'),
        content: TextField(
          controller: newCatCtrl,
          decoration: const InputDecoration(
            hintText: 'Название (например, Книги)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              if (newCatCtrl.text.isNotEmpty) {
                HapticFeedback.selectionClick();
                // Получаем текущее кол-во категорий для индекса
                var snap = await FirebaseFirestore.instance
                    .collection('categories')
                    .where('userId', isEqualTo: currentUserId)
                    .get();
                HapticFeedback.selectionClick();
                await FirebaseFirestore.instance.collection('categories').add({
                  'name': newCatCtrl.text.trim(),
                  'index': snap.docs.length,
                  'userId': currentUserId,
                });

                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  // Метод для удаления категории
  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить список?'),
        content: const Text(
          'Сами элементы останутся в базе, удалится только категория.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.selectionClick();
              await FirebaseFirestore.instance
                  .collection('categories')
                  .doc(id)
                  .delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Заполняем контроллеры данными из документа
    ctrl.text = data['t'] ?? '';
    descCtrl.text = data['desc'] ?? '';
    currentProgCtrl.text = data['cur']?.toString() ?? '0';
    totalProgCtrl.text = data['total']?.toString() ?? '0';
    progressUnit = data['unit'] ?? 'серия';

    // ВАЖНО: если done == true, добавляем "Архив" в выбранные теги для отображения
    selected.clear();
    List<String> existingTags = List<String>.from(data['tags'] ?? []);
    selected.addAll(existingTags);
    if (data['done'] == true && !selected.contains('Архив')) {
      selected.add('Архив');
    }

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      useSafeArea: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Редактировать пункт',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: currentProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Сейчас',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('из'),
                    ),
                    Expanded(
                      child: TextField(
                        controller: totalProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Всего',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: progressUnit,
                      onChanged: (val) =>
                          setSheetState(() => progressUnit = val!),
                      items:
                          ['серия', 'стр', 'гл', 'книга', 'сезон', 'часов', '-']
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTagsSelectorForSheet(setSheetState),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      _updateItem(doc);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Сохранить'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // НОВЫЙ метод для обновления существующей записи
  void _updateItem(DocumentSnapshot doc) {
    if (ctrl.text.isEmpty) return;

    bool isArchive = selected.contains('Архив');
    List<String> tagsToSave = List.from(selected);
    tagsToSave.remove('Архив');

    doc.reference.update({
      't': ctrl.text,
      'desc': descCtrl.text,
      'cur': currentProgCtrl.text,
      'total': totalProgCtrl.text,
      'unit': progressUnit,
      'tags': tagsToSave,
      'done': isArchive,
    });

    ctrl.clear();
    descCtrl.clear();
    currentProgCtrl.clear();
    totalProgCtrl.clear();
    selected.clear();
  }

  // 1. Метод добавления в базу
  void _add() {
    if (ctrl.text.isEmpty) return;

    // Проверяем, выбран ли статус "Архив"
    bool isArchive = selected.contains('Архив');

    // Убираем "Архив" из тегов, т.к. это статус, а не категория
    List<String> tagsToSave = List.from(selected);
    tagsToSave.remove('Архив');

    FirebaseFirestore.instance.collection('items').add({
      't': ctrl.text,
      'desc': descCtrl.text,
      'cur': currentProgCtrl.text,
      'total': totalProgCtrl.text,
      'unit': progressUnit,
      'tags': tagsToSave,
      'done': isArchive,
      'time': DateTime.now().millisecondsSinceEpoch,
      'userId': currentUserId, // <-- добавь это
    });

    ctrl.clear();
    descCtrl.clear();
    currentProgCtrl.clear();
    totalProgCtrl.clear();
    selected.clear();
  }

  // 2. Окно добавления (выезжает снизу)
  void _showAddItemSheet() {
    ctrl.clear();
    descCtrl.clear();
    currentProgCtrl.clear();
    totalProgCtrl.clear();
    selected.clear();
    progressUnit = 'серия'; // сброс единиц на дефолт
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,

            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Добавить новый пункт',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: currentProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Сейчас',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('из'),
                    ),
                    Expanded(
                      child: TextField(
                        controller: totalProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Всего',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Возвращаем выбор единиц:
                    DropdownButton<String>(
                      value: progressUnit,
                      onChanged: (val) =>
                          setSheetState(() => progressUnit = val!),
                      items:
                          ['серия', 'стр', 'гл', 'книга', 'сезон', 'часов', '-']
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildTagsSelectorForSheet(
                  setSheetState,
                ), // Выбор тегов внутри окна
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      _add();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Добавить в список'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для выбора тегов в окне добавления
  Widget _buildTagsSelectorForSheet(StateSetter setSheetState) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('userId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        var allCatsFromDb = snapshot.data!.docs
            .map((d) => d['name'] as String)
            .toList();

        // Возвращаем 'Архив' в статусы!
        var statusTags = ['В работе', 'Пересмотреть', 'Архив'];

        var typeTags = allCatsFromDb
            .where((c) => !statusTags.contains(c))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Тип отдыха:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 220,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: typeTags
                      .map((cat) => _buildChip(cat, setSheetState))
                      .toList(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            const Text(
              "Статус:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: statusTags
                  .map((cat) => _buildChip(cat, setSheetState))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  // Вспомогательный метод для красивой кнопки-тега
  Widget _buildChip(String cat, StateSetter setSheetState) {
    final isSel = selected.contains(cat);

    return FilterChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(cat, style: const TextStyle(fontSize: 13)),
      ),

      selected: isSel,

      showCheckmark: false,

      materialTapTargetSize: MaterialTapTargetSize.padded,

      onSelected: (val) => setSheetState(() {
        if (val) {
          selected.add(cat);
        } else {
          selected.remove(cat);
        }
      }),
    );
  }

  // 3. Основной метод списка (с 4 вкладками)
  Widget _buildItemList({required String status}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snap.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String title = (data['t'] ?? '').toString().toLowerCase();
          List tags = data['tags'] ?? [];

          bool matchesStatus = false;

          if (status == 'all') {
            matchesStatus = true;
          } else if (status == 'archive') {
            matchesStatus = data['done'] == true;
          } else if (status == 'rewatch') {
            // Пересмотреть = есть тег "Пересмотреть" И не в архиве (done = false)
            matchesStatus =
                tags.contains('Пересмотреть') && data['done'] == false;
          } else {
            // В работе = не в архиве И не пересмотр
            matchesStatus =
                data['done'] == false && !tags.contains('Пересмотреть');
          }

          bool matchesCategory =
              selectedFilters.contains('Все') ||
              tags.any((tag) => selectedFilters.contains(tag));
          bool matchesSearch = title.contains(searchQuery);

          return matchesStatus && matchesCategory && matchesSearch;
        }).toList();

        if (docs.isEmpty) return const Center(child: Text('Ничего не найдено'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) => _buildTaskCard(docs[i]),
        );
      },
    );
  }

  // Карточка задачи
  Widget _buildTaskCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List tags = List.from(data['tags'] ?? []);

    bool isDone = data['done'] ?? false;

    return Dismissible(
      key: Key(doc.id),

      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.archive, color: Colors.white),
      ),

      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        // Свайп справа налево = удалить
        if (direction == DismissDirection.endToStart) {
          HapticFeedback.mediumImpact();
          await doc.reference.delete();

          return true;
        }
        // Свайп слева направо = архив
        else {
          List<String> updatedTags = List.from(tags);

          if (!updatedTags.contains('Архив')) {
            updatedTags.add('Архив');
          }

          await doc.reference.update({'done': true, 'tags': updatedTags});

          return false;
        }
      },

      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

          leading: Checkbox(
            value: isDone,

            onChanged: (v) async {
              if (v == null) return;
              HapticFeedback.lightImpact();

              List<String> updatedTags = List.from(tags);

              if (v) {
                if (!updatedTags.contains('Архив')) {
                  updatedTags.add('Архив');
                }
              } else {
                updatedTags.remove('Архив');
              }

              await doc.reference.update({'done': v, 'tags': updatedTags});

              if (mounted) setState(() {});
            },
          ),

          title: Text(
            data['t'] ?? '',

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),

            child: Text(
              'Прогресс: ${data['cur'] ?? 0}/${data['total'] ?? 0} ${data['unit'] ?? ''}\n${tags.join(", ")}',
            ),
          ),

          onLongPress: () => _editItem(doc),

          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),

            onPressed: () async {
              HapticFeedback.mediumImpact();
              await doc.reference.delete();
            },
          ),
        ),
      ),
    );
  }

  // Пустые заглушки для методов, которые у тебя уже были (проверь их наличие выше в коде или добавь)
  void _showRandomItem(String currentStatus) async {
    // 1. Получаем все данные из Firebase
    HapticFeedback.selectionClick();
    var snap = await FirebaseFirestore.instance
        .collection('items')
        .where('userId', isEqualTo: currentUserId)
        .get();

    if (!mounted) return;

    // 2. Фильтруем список по тем же правилам, что и основной экран
    var filteredDocs = snap.docs.where((doc) {
      final data = doc.data();
      final List tags = data['tags'] ?? [];

      // А) Проверка вкладки (статуса)
      bool matchesStatus = false;

      if (currentStatus == 'all') {
        matchesStatus = true;
      } else if (currentStatus == 'archive') {
        matchesStatus = data['done'] == true;
      } else if (currentStatus == 'rewatch') {
        // Пересмотреть = есть тег "Пересмотреть" И не в архиве (done = false)
        matchesStatus = tags.contains('Пересмотреть') && data['done'] == false;
      } else {
        matchesStatus = data['done'] == false && !tags.contains('Пересмотреть');
      }

      // Б) Проверка МНОЖЕСТВЕННЫХ фильтров (Твои книги, сериалы и т.д.)
      // Если выбрано "Все", подходит любая карточка.
      // Иначе проверяем, есть ли у карточки ХОТЯ БЫ ОДИН из выбранных тегов.
      bool matchesCategory =
          selectedFilters.contains('Все') ||
          tags.any((tag) => selectedFilters.contains(tag));

      // В) Проверка поиска (если введено что-то в строку поиска)
      final String title = (data['t'] ?? '').toString().toLowerCase();
      bool matchesSearch = title.contains(searchQuery.toLowerCase());

      return matchesStatus && matchesCategory && matchesSearch;
    }).toList();

    // 3. Если после всех фильтров список пуст
    if (filteredDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'В текущем отфильтрованном списке нет подходящих элементов',
          ),
        ),
      );
      return;
    }

    // 4. Выбираем рандом из того, что реально видишь на экране
    var randomDoc = (filteredDocs..shuffle()).first;

    // 5. Показываем результат (с защитой от отсутствия описания desc)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Случайный выбор'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Как насчет этого?'),
            const SizedBox(height: 10),
            Text(
              randomDoc.get('t') ?? 'Без названия',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Builder(
              builder: (context) {
                final data = randomDoc.data();
                if (data.containsKey('desc') &&
                    data['desc'].toString().isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${data['desc']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Понятно'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRandomItem(currentStatus);
            },
            child: const Text('Другой'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
        // Используем простой стрим без orderBy, чтобы увидеть старые данные
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;

          // Сортируем в памяти для стабильности
          docs.sort((a, b) {
            int aIdx = (a.data() as Map).containsKey('index') ? a['index'] : 0;
            int bIdx = (b.data() as Map).containsKey('index') ? b['index'] : 0;
            return aIdx.compareTo(bIdx);
          });

          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                color: Colors.deepPurple,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'Мои Списки',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "КАТЕГОРИИ",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_box_outlined,
                        color: Colors.deepPurple,
                      ),
                      onPressed: _showAddCategoryDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? const Center(child: Text("Списков пока нет"))
                    : ReorderableListView(
                        onReorder: (oldIdx, newIdx) async {
                          if (newIdx > oldIdx) newIdx -= 1;
                          final List<DocumentSnapshot> list = List.from(docs);
                          final item = list.removeAt(oldIdx);
                          list.insert(newIdx, item);
                          final batch = FirebaseFirestore.instance.batch();
                          for (int i = 0; i < list.length; i++) {
                            batch.update(list[i].reference, {'index': i});
                          }
                          await batch.commit();
                        },
                        children: [
                          for (var doc in docs)
                            ReorderableDelayedDragStartListener(
                              // Обертка для управления перетаскиванием
                              key: ValueKey(doc.id),
                              index: docs.indexOf(doc),
                              child: ListTile(
                                title: Text(doc['name'] ?? ''),
                                selected: selectedFilters.contains(doc['name']),

                                // Долгое нажатие теперь четко открывает редактирование
                                onLongPress: () => _editCategoryName(doc),

                                onTap: () {
                                  setState(
                                    () => selectedFilters = [
                                      doc['name'] as String,
                                    ],
                                  );
                                  Navigator.pop(context);
                                },

                                // Иконка перетаскивания
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _deleteCategory(doc.id),
                                    ),
                                    // Сама "ручка" для перетаскивания
                                    const Icon(
                                      Icons.drag_handle,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),

              // Внутри _buildDrawer -> Column -> children:
            ],
          );
        },
      ),
    );
  }

  void _editCategoryName(DocumentSnapshot doc) {
    final String oldName = doc['name'];
    final TextEditingController editCtrl = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редактировать список'),
        content: TextField(
          controller: editCtrl,
          decoration: const InputDecoration(hintText: 'Новое название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              String newName = editCtrl.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                // 1. Обновляем саму категорию
                await doc.reference.update({'name': newName});
                HapticFeedback.selectionClick();
                // 2. Обновляем все задачи, у которых был этот тег
                var itemsSnap = await FirebaseFirestore.instance
                    .collection('items')
                    .where('tags', arrayContains: oldName)
                    .get();

                WriteBatch batch = FirebaseFirestore.instance.batch();
                for (var itemDoc in itemsSnap.docs) {
                  List tags = List.from(itemDoc['tags']);
                  int index = tags.indexOf(oldName);
                  if (index != -1) {
                    tags[index] = newName;
                    batch.update(itemDoc.reference, {'tags': tags});
                  }
                }
                await batch.commit();

                // 3. Обновляем текущий фильтр на экране
                if (selectedFilters.contains(oldName)) {
                  setState(() {
                    // Находим индекс старого имени в списке и заменяем на новое
                    int idx = selectedFilters.indexOf(oldName);
                    selectedFilters[idx] = newName;
                  });
                }

                // Исправляем ошибку с фигурными скобками (curly_braces)
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },

            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100, // Увеличиваем высоту, чтобы влез поиск и фильтры
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.deepPurple),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Поле поиска
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Поиск...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              ),
              // Секция фильтров с анимацией
              SizedBox(
                width: double.infinity,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    var statusTags = ['В работе', 'Пересмотреть', 'Архив'];
                    var typeTags = snapshot.data!.docs
                        .map((d) => d['name'] as String)
                        .where((name) => !statusTags.contains(name))
                        .toList();

                    bool isAllSelected = selectedFilters.contains('Все');

                    return AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilterChip(
                            label: const Text(
                              "Все",
                              style: TextStyle(fontSize: 12),
                            ),
                            selected: isAllSelected,
                            onSelected: (val) {
                              setState(() {
                                selectedFilters = ['Все'];
                              });
                            },
                          ),
                          if (!isAllSelected)
                            ...typeTags.map(
                              (cat) => FilterChip(
                                label: Text(
                                  cat,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: selectedFilters.contains(cat),
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      selectedFilters.remove('Все');
                                      selectedFilters.add(cat);
                                    } else {
                                      selectedFilters.remove(cat);
                                      if (selectedFilters.isEmpty) {
                                        selectedFilters = ['Все'];
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                          if (isAllSelected)
                            IconButton(
                              icon: const Icon(Icons.tune, size: 20),
                              onPressed: () =>
                                  setState(() => selectedFilters = []),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Все'),
              Tab(text: 'В работе'),
              Tab(text: 'Архив'),
              Tab(text: 'Пересмотреть'),
            ],
          ),
          actions: [
            // Исправленный вызов рандома (Пункт 1)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.casino_outlined),
                onPressed: () {
                  // Определяем текущий статус по индексу таба
                  final tabs = ['all', 'work', 'archive', 'rewatch'];
                  final currentIdx = DefaultTabController.of(context).index;
                  _showRandomItem(tabs[currentIdx]);
                },
              ),
            ),
            IconButton(
              icon: Icon(
                themeNotifier.value == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: () =>
                  themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light,
            ),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return PopupMenuButton<String>(
                  icon: user?.photoURL != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user!.photoURL!),
                          radius: 14,
                        )
                      : const Icon(Icons.account_circle),
                  onSelected: (value) async {
                    if (value == 'switch') {
                      // На Web disconnect() не работает — просто signOut
                      await appGoogleSignIn.signOut();
                      await FirebaseAuth.instance.signOut();
                    } else if (value == 'logout') {
                      await appGoogleSignIn.signOut();
                      await FirebaseAuth.instance.signOut();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Без имени',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'switch',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, size: 18),
                          SizedBox(width: 8),
                          Text('Сменить аккаунт'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            'Выйти',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),

            child: TabBarView(
              children: [
                _buildItemList(status: 'all'),
                _buildItemList(status: 'work'),
                _buildItemList(status: 'archive'),
                _buildItemList(status: 'rewatch'),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddItemSheet,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }
}
