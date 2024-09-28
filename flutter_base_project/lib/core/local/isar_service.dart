import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Define a typedef for the collection getter
typedef CollectionGetter<T> = IsarCollection<T> Function(Isar isar);

class IsarService<T> {
  late Future<Isar> _db;
  final CollectionGetter<T> getCollection;
  final CollectionSchema<T> schema;

  // Constructor that accepts a function to get the collection and the schema
  IsarService(this.getCollection, this.schema) {
    _db = open();
  }

  Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [schema], // Use the schema passed in the constructor
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> deleteData(int id) async {
    final isar = await _db;
    // Perform a write transaction to delete the object with the specified ID.
    isar.writeTxnSync(() => getCollection(isar).deleteSync(id));
  }

  Future<void> deleteAllData(List<int> ids) async {
    final isar = await _db;

    // Perform a write transaction to delete all objects from all collections
    await isar.writeTxnSync(() async {
      getCollection(isar).deleteAllSync(ids);
    });
  }

  Future<List<T>> getAllData() async {
    final isar = await _db;
    // Find all objects in the collection and return the list.
    final data = await getCollection(isar).where().findAll();
    return data;
  }

  Stream<List<T>> listenData() async* {
    final isar = await _db;
    // Watch the collection for changes and yield the updated list.
    yield* getCollection(isar).where().watch(fireImmediately: true);
  }

  Future<void> saveData(T object) async {
    final isar = await _db;
    // Perform a synchronous write transaction to add the object to the database.
    isar.writeTxn(() => getCollection(isar).put(object));
  }

  Future<void> updateData(T object) async {
    final isar = await _db;
    await isar.writeTxnSync(() async {
      // Perform a write transaction to update the object in the database.
      getCollection(isar).putSync(object);
    });
  }
}
