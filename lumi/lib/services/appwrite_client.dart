
import 'package:appwrite/appwrite.dart';
import '../config/environment.dart';

class Appwrite {
  static final Client client = Client()
      .setEndpoint(LUMI_APPWRITE_ENDPOINT)
      .setProject(LUMI_APPWRITE_PROJECT_ID);

  static final Account account = Account(client);
  static final Databases databases = Databases(client);
} 