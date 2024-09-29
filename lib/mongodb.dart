import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:crebrew/constant.dart';

class MongoDatabase {
  static Db? db;
  static DbCollection? bpmCollection;
  static DbCollection? gasesCollection; // New collection for gases data

  static Future<void> connect() async {
    try {
      db = await Db.create(MONGO_URL);
      await db!.open();
      inspect(db);
      var status = await db!.serverStatus();
      print(status);
      bpmCollection = db!.collection(COLLECTION_NAME);
      gasesCollection =
          db!.collection(GASES_COLLECTION_NAME); // Initialize gases collection
    } catch (e) {
      print("MongoDB connection error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      final data = await bpmCollection!.find().toList();
      return data;
    } catch (e) {
      print("MongoDB fetch error: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchGasesData() async {
    try {
      final gasesData =
          await gasesCollection!.find().toList(); // Fetch gases data
      return gasesData;
    } catch (e) {
      print("MongoDB fetch error (gases): $e");
      return [];
    }
  }
}
