import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

class LocalMessages extends Table {
  IntColumn get id => integer().autoIncrement();
  TextColumn get messageId => text().unique();
  TextColumn get senderId => text();
  TextColumn get recipientId => text();
  TextColumn get content => text();
  DateTimeColumn get timestamp => dateTime();
  TextColumn get status => text(); // SENT, DELIVERED, READ, QUEUED
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(true));
}

@DriftDatabase(tables: [LocalMessages])
class NexusDatabase extends _$NexusDatabase {
  NexusDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'nexus_secure_chat.sqlite'));

      const secureStorage = FlutterSecureStorage();
      String? encryptionKey = await secureStorage.read(key: 'db_cipher_key');
      if (encryptionKey == null) {
        encryptionKey = DateTime.now().microsecondsSinceEpoch.toString();
        await secureStorage.write(key: 'db_cipher_key', value: encryptionKey);
      }

      return NativeDatabase(file);
    });
  }

  Future<void> insertMessage(LocalMessagesCompanion message) =>
      into(localMessages).insertOnConflictUpdate(message);

  Stream<List<LocalMessage>> watchChatHistory(String peerId) =>
      (select(localMessages)..where((t) => t.senderId.equals(peerId) | t.recipientId.equals(peerId))
        ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .watch();
}
