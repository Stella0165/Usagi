const String APPWRITE_ENDPOINT = String.fromEnvironment(
  'LUMI_APPWRITE_ENDPOINT',
);

const String APPWRITE_PROJECT_ID = String.fromEnvironment(
  'LUMI_APPWRITE_PROJECT_ID',
);

const String GEMINI_API_KEY = String.fromEnvironment(
  'GEMINI_API_KEY',
);

const String GEMINI_MODEL = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-3.1-flash-lite',
);
