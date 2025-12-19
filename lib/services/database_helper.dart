import 'package:sqflite/sqflite.dart' hide Batch; // ✅ FIX: Hides the conflict
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/batch.dart'; // ✅ Ensure this import exists

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chitale_erp.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    // 1. USERS TABLE
    await db.execute('''
CREATE TABLE users (
  username TEXT PRIMARY KEY,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  name TEXT NOT NULL
)
''');

    // 2. BATCHES TABLE
    await db.execute('''
CREATE TABLE batches (
  batchNo TEXT PRIMARY KEY, 
  material TEXT NOT NULL,
  vendor TEXT NOT NULL,
  grn TEXT NOT NULL,
  regDate TEXT NOT NULL,
  mfgDate TEXT NOT NULL,
  expDate TEXT NOT NULL,
  status TEXT NOT NULL,
  shelfLocation TEXT,
  initialQty $realType,
  currentQty $realType,
  unit TEXT NOT NULL,
  sampleQty TEXT
)
''');

    // 3. QC RECORDS TABLE
    await db.execute('''
CREATE TABLE qc_records (
  id $idType,
  batchNo TEXT NOT NULL,
  status TEXT NOT NULL,
  remarks TEXT NOT NULL,
  reviewedBy TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  FOREIGN KEY (batchNo) REFERENCES batches (batchNo)
)
''');

    // 4. MASTER MATERIALS TABLE
    await db.execute('''
CREATE TABLE materials (
  id $idType,
  name TEXT NOT NULL,
  standardQtyPerPallet $realType,
  unit TEXT NOT NULL
)
''');

    print("📦 Database Created Successfully");

    // Seed Data
    await db.insert('users', {'username': 'arun', 'password': '123', 'role': 'ADMIN', 'name': 'Arun Jadhav'});
    await db.insert('users', {'username': 'aditi', 'password': '123', 'role': 'QC', 'name': 'Aditi Kadam'});
    await db.insert('materials', {'name': 'Sugar (Fine Grade)', 'standardQtyPerPallet': 50.0, 'unit': 'Kg'});
    await db.insert('materials', {'name': 'Cashew Nuts (W320)', 'standardQtyPerPallet': 25.0, 'unit': 'Kg'});
    await db.insert('materials', {'name': 'Buffalo Milk', 'standardQtyPerPallet': 100.0, 'unit': 'L'});
  }

  // ---------------- AUTH METHODS ----------------
  Future<User?> login(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // ---------------- INVENTORY METHODS ----------------
  Future<void> insertBatch(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('batches', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getBatch(String batchNo) async {
    final db = await instance.database;
    final maps = await db.query('batches', where: 'batchNo = ?', whereArgs: [batchNo]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // ✅ This fixes the "getMaterials not defined" error
  Future<List<Map<String, dynamic>>> getMaterials() async {
    final db = await instance.database;
    return await db.query('materials');
  }

  // ✅ This fixes the "getBatchesForMaterial" error
  Future<List<Batch>> getBatchesForMaterial(String materialName) async {
    final db = await instance.database;
    final result = await db.query(
      'batches',
      where: 'material = ? AND status = ? AND currentQty > 0',
      whereArgs: [materialName, 'approved'],
      orderBy: 'expDate ASC', // FEFO
    );
    // This line was crashing before because of the naming conflict
    return result.map((json) => Batch.fromMap(json)).toList();
  }

  // ✅ This fixes the "issueBatchQty" requirement
  Future<void> issueBatchQty(String batchNo, double issueQty) async {
    final db = await instance.database;
    final batchMap = await getBatch(batchNo);
    if (batchMap == null) return;

    double current = batchMap['currentQty'];
    double newQty = current - issueQty;

    await db.update(
      'batches',
      {'currentQty': newQty < 0 ? 0 : newQty},
      where: 'batchNo = ?',
      whereArgs: [batchNo],
    );
  }

  // ---------------- STATS & OTHERS ----------------
  Future<Map<String, int>> getAdminStats() async {
    final db = await instance.database;
    final putAwayCount = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM batches WHERE status = 'approved' AND (shelfLocation IS NULL OR shelfLocation = '')")) ?? 0;
    final pendingQcCount = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM batches WHERE status = 'newBatch' OR status = 'onHold'")) ?? 0;
    final lowStockCount = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM batches WHERE initialQty > 0 AND (currentQty / initialQty) < 0.2")) ?? 0;
    final totalCount = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM batches")) ?? 0;

    return {'putAway': putAwayCount, 'pendingQC': pendingQcCount, 'lowStock': lowStockCount, 'total': totalCount};
  }

  Future<List<Map<String, dynamic>>> getAllBatches() async {
    final db = await instance.database;
    return await db.query('batches');
  }

  Future<void> updateBatchStatus(String batchNo, String status, {String? shelf}) async {
    final db = await instance.database;
    Map<String, dynamic> values = {'status': status};
    if (shelf != null) values['shelfLocation'] = shelf;
    await db.update('batches', values, where: 'batchNo = ?', whereArgs: [batchNo]);
  }
  // ---------------- QC HISTORY METHODS ----------------

  // ✅ Fixes "insertQCRecord" error
  Future<void> insertQCRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('qc_records', row);
  }

  // ✅ Fixes "getQCRecords" error
  Future<List<Map<String, dynamic>>> getQCRecords() async {
    final db = await instance.database;
    return await db.query('qc_records', orderBy: 'timestamp DESC');
  }
}