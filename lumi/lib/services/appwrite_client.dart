
import 'package:appwrite/appwrite.dart';
import '../config/environment.dart';

class Appwrite {
  static final Client client = Client()
      .setEndpoint(APPWRITE_ENDPOINT)
      .setProject(APPWRITE_PROJECT_ID);

  static final Account account = Account(client);
  static final Databases databases = Databases(client);
}