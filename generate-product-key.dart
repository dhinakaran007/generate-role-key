import 'dart:io';
import 'dart:math';
import 'dart:convert';

const int DISTRIBUTOR_ROLE = 1;
const int MILK_ROLE = 2;
const int DELIVERY_ROLE = 4;

void main() {
  print('Product Key Generator with Role Specification');
  print('------------------------------------------------');

  final ipAddress = promptInput('Enter IP address (default: 13.228.232.169): ', '13.228.232.169');
  final identifier = promptInput('Enter identifier (default: ezt): ', 'ezt');
  final type = promptInput('Enter type (default: c): ', 'c');

  print('\nSelect roles (enter y/n for each):');
  final isDistributor = true;
  print("Distributor: $isDistributor (default: true)");
  final isMilkMan = promptYesNo('Milk Man? ');
  final isDeliveryGuy = promptYesNo('Delivery Guy? ');
  
  final roleCode = generateRoleCode(isDistributor, isMilkMan, isDeliveryGuy);

  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final randomNum = 1000000000 + Random().nextInt(1000000000);

  final rawProductKey = '$ipAddress,$identifier,$type,$roleCode,$timestamp-$randomNum';
  final encodedProductKey = encodeProductKey(rawProductKey);
  
  print('\nGenerated Product Key:');
  print('Raw: $rawProductKey');
  print('Encoded: $encodedProductKey');
  
  print('\nRole breakdown:');
  print('Distributor: ${isDistributor ? 'Yes' : 'No'}');
  print('Milk Man: ${isMilkMan ? 'Yes' : 'No'}');
  print('Delivery Guy: ${isDeliveryGuy ? 'Yes' : 'No'}');
  
  try {
    final decodedKey = decodeBase64ProductKey(encodedProductKey);
    print('Decoded: $decodedKey');
    
    final keyInfo = decodeProductKey(decodedKey);
    print('Key information: ${keyInfo.toString()}');
  } catch (e) {
    print('Error decoding: $e');
  }

  print("Encoded product key: $encodedProductKey");
}

String promptInput(String message, String defaultValue) {
  stdout.write(message);
  String? input = stdin.readLineSync();
  return input?.trim().isNotEmpty == true ? input!.trim() : defaultValue;
}

bool promptYesNo(String message) {
  while (true) {
    stdout.write(message + ' (y/n): ');
    String? input = stdin.readLineSync()?.toLowerCase();
    if (input == 'y' || input == 'yes') return true;
    if (input == 'n' || input == 'no') return false;
    print('Please enter y or n.');
  }
}

String generateRoleCode(bool isDistributor, bool isMilkMan, bool isDeliveryGuy) {
  int code = 0;
  if (isDistributor) code |= DISTRIBUTOR_ROLE;
  if (isMilkMan) code |= MILK_ROLE; 
  if (isDeliveryGuy) code |= DELIVERY_ROLE;

  return code.toString();
}

String encodeProductKey(String rawKey) {
  List<int> bytes = utf8.encode(rawKey);
  String base64String = base64.encode(bytes);
  return base64String;
}

String decodeBase64ProductKey(String encodedKey) {
  List<int> bytes = base64.decode(encodedKey);
  String decodedKey = utf8.decode(bytes);
  return decodedKey;
}

Map<String, dynamic> decodeProductKey(String key) {
  if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(key)) {
    try {
      key = decodeBase64ProductKey(key);
    } catch (e) {
    }
  }
  
  final parts = key.split(',');
  if (parts.length < 4) {
    throw FormatException('Invalid product key format');
  }
  
  final ipAddress = parts[0];
  final identifier = parts[1];
  final type = parts[2];
  
  String roleCode;
  String timestampPart;
  
  if (parts.length == 4) {
    roleCode = '000';
    timestampPart = parts[3];
  } else {
    roleCode = parts[3];
    timestampPart = parts[4];
  }
  
  final timestampParts = timestampPart.split('-');
  final timestamp = int.parse(timestampParts[0]);
  final randomNum = int.parse(timestampParts[1]);
  
  final roles = {
    'distributor': (int.parse(roleCode) & DISTRIBUTOR_ROLE) != 0,
    'milkMan': (int.parse(roleCode) & MILK_ROLE) != 0,
    'deliveryGuy': (int.parse(roleCode) & DELIVERY_ROLE) != 0,
  };
  
  return {
    'ipAddress': ipAddress,
    'identifier': identifier,
    'type': type,
    'roleCode': roleCode,
    'timestamp': timestamp,
    'randomNum': randomNum,
    'roles': roles,
  };
}