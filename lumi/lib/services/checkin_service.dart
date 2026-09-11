import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import 'appwrite_client.dart';
import '../models/checkin.dart';

/// IMPORTANT: fill in databaseId with the same database ID used for
/// commitments (this table lives in the same Lumi_DB database).
class CheckInIds {
  static const databaseId = 'YOUR_DATABASE_ID'; // same as AppwriteIds.databaseId
  static const stressEntriesCollectionId = '6aa35469002cb185a520';
}

class CheckInService {
  static Future<CheckIn> createCheckIn(CheckIn checkIn) async {
    final userId = (await Appwrite.account.get()).$id;
    final checkInWithUser = CheckIn(
      stressLevel: checkIn.stressLevel,
      energyLevel: checkIn.energyLevel,
      date: checkIn.date,
      userId: userId,
    );

    final doc = await Appwrite.databases.createDocument(
      databaseId: CheckInIds.databaseId,
      collectionId: CheckInIds.stressEntriesCollectionId,
      documentId: ID.unique(),
      data: checkInWithUser.toMap(),
      // Row-level permissions: only this user can read/update/delete this
      // check-in. The stored userId column is just data here — it's the
      // permissions below that actually enforce access control.
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
    return CheckIn.fromMap(doc.data);
  }

  static Future<List<CheckIn>> listCheckIns({int limit = 30}) async {
    final result = await Appwrite.databases.listDocuments(
      databaseId: CheckInIds.databaseId,
      collectionId: CheckInIds.stressEntriesCollectionId,
      queries: [
        Query.orderDesc('date'),
        Query.limit(limit),
      ],
    );
    return result.documents
        .map((models.Document d) => CheckIn.fromMap(d.data))
        .toList();
  }
}