import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import 'appwrite_client.dart';
import '../models/commitment.dart';

class AppwriteIds {
  static const databaseId = '6aa3529000108350f603';
  static const commitmentsCollectionId = '6aa3530300134025dc1b';
}

/// Assumes `Appwrite.databases` exposes a `Databases` instance the same
/// way `Appwrite.account` exposes `Account` in appwrite_client.dart.
class CommitmentService {
  static Future<Commitment> createCommitment(Commitment commitment) async {
    final doc = await Appwrite.databases.createDocument(
      databaseId: AppwriteIds.databaseId,
      collectionId: AppwriteIds.commitmentsCollectionId,
      documentId: ID.unique(),
      data: commitment.toMap(),
      // Row-level permissions: only this user can read, update, or delete
      // the row they just created. Table-level CREATE (granted to "All
      // users") is what allows this call to succeed in the first place.
      permissions: [
        Permission.read(Role.user(commitment.userId)),
        Permission.update(Role.user(commitment.userId)),
        Permission.delete(Role.user(commitment.userId)),
      ],
    );
    return Commitment.fromMap(doc.data);
  }

  static Future<List<Commitment>> listCommitments() async {
    final result = await Appwrite.databases.listDocuments(
      databaseId: AppwriteIds.databaseId,
      collectionId: AppwriteIds.commitmentsCollectionId,
      queries: [
        Query.orderAsc('date'),
      ],
    );
    return result.documents
        .map((models.Document d) => Commitment.fromMap(d.data))
        .toList();
  }

  static Future<Commitment> updateCommitment(Commitment commitment) async {
    assert(commitment.id != null, 'Cannot update a commitment without an id');
    final doc = await Appwrite.databases.updateDocument(
      databaseId: AppwriteIds.databaseId,
      collectionId: AppwriteIds.commitmentsCollectionId,
      documentId: commitment.id!,
      data: commitment.toMap(),
    );
    return Commitment.fromMap(doc.data);
  }

  static Future<void> deleteCommitment(String documentId) async {
    await Appwrite.databases.deleteDocument(
      databaseId: AppwriteIds.databaseId,
      collectionId: AppwriteIds.commitmentsCollectionId,
      documentId: documentId,
    );
  }
}