import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/exceptions.dart';

DateTime parseTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      throw (ServerException(message: "Fail to parse Timestamp from String"));
    }
  }
  throw (ServerException(message: "Unknown Timestamp runtime: ${timestamp.runtimeType}"));
}
