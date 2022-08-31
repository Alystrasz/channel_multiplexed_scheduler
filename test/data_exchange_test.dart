import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/implementation/data_channel.dart';
import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/file_channel.dart';
import 'mock/scheduler/mock_scheduler.dart';

void main() {
  late Scheduler scheduler;
  late Receiver receiver;
  late File file;
  late String destination;

  setUpAll(() {
    file = File('test/assets/paper.pdf');
    destination = "${Directory.systemTemp.path}${Platform.pathSeparator}received.pdf";
  });
  setUp(() {
    scheduler = MockScheduler();
    receiver = Receiver();
  });

  test('scheduler should exchange file with receiver', () async {
    // we use temporary storage to act as network
    Directory chunksFilesDir = Directory(Directory.systemTemp.path + Platform.pathSeparator + DateTime.now().millisecondsSinceEpoch.toString());
    chunksFilesDir.createSync();

    // sending part
    DataChannel sendChannel = FileChannel(directory: chunksFilesDir);
    scheduler.useChannel(sendChannel);

    // receiving end
    DataChannel receiveChannel = FileChannel(directory: chunksFilesDir);
    receiver.useChannel(receiveChannel);

    // Wait for both data sending and reception to end.
    await Future.wait([
      receiver.receiveFile(destination),
      scheduler.sendFile(file, 100000)
    ]);
    
    File receivedFile = File(destination);
    expect(receivedFile.existsSync(), true);
    expect(receivedFile.lengthSync() != 0, true);
  });
}