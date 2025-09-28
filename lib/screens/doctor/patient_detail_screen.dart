import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medinotesapp/apis/endpoint_file.dart';
import 'package:medinotesapp/config/Shared_Preference_Data_Handling.dart';
import 'package:medinotesapp/config/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  final Dio _dio = Dio();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool isRecording = false;
  bool isPaused = false;
  String? sessionId;
  int chunkIndex = 0;
  String? currentChunkPath;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
    _recoverOrClearSession();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _recoverOrClearSession() async {
    SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
    await sharedPreferenceData.initialize();

    String? oldSession = await sharedPreferenceData.getCurrentSessionID();
    int? oldChunkIndex = await sharedPreferenceData.getCurrentChunkIndex();

    if (oldSession != null && oldSession.isNotEmpty) {
      await sharedPreferenceData.setCurrentSessionID('');
      await sharedPreferenceData.setCurrentChunkIndex(0);

      setState(() {
        sessionId = null;
        chunkIndex = 0;
        currentChunkPath = null;
        isRecording = false;
        isPaused = false;
      });
    }
  }

  Future<void> startSession() async {
    SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
    await sharedPreferenceData.initialize();
    String docID = await sharedPreferenceData.getUserID();

    await requestMicPermission();

    try {
      var response = await _dio.post(uploadSession, data: {
        "patientId": widget.patient["user_id"],
        "doctorId": docID,
        "patientName": widget.patient["name"],
        "templateId": "Regular Visit",
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        sessionId = response.data["sessionId"];
        chunkIndex = 0;

        await sharedPreferenceData.setCurrentSessionID(sessionId ?? '');
        await sharedPreferenceData.setCurrentChunkIndex(chunkIndex);

        setState(() {
          isRecording = true;
          isPaused = false;
        });

        await _startNextChunk();
      }
    } catch (e) {
      debugPrint("Error starting session: $e");
    }
  }


  Future<bool> requestMicPermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startNextChunk() async {
    if (!isRecording || isPaused || sessionId == null) return;

    final dir = await getTemporaryDirectory();
    currentChunkPath = '${dir.path}/chunk_$chunkIndex.aac';

    await _recorder.startRecorder(
      toFile: currentChunkPath,
      codec:Codec.aacADTS,
      sampleRate: 44100,
      numChannels: 1,
    );

    Future.delayed(const Duration(seconds: 5), () async {
      if (!isRecording || isPaused) return;

      await _recorder.stopRecorder();
      await uploadChunk(currentChunkPath!, chunkIndex++);

      SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
      await sharedPreferenceData.initialize();
      await sharedPreferenceData.setCurrentChunkIndex(chunkIndex);

      if (isRecording && !isPaused) {
        await _startNextChunk();
      }
    });
  }

  Future<void> pauseRecording() async {
    if (!isRecording || isPaused) return;
    setState(() => isPaused = true);

    try {
      await _recorder.stopRecorder();
      await uploadChunk(currentChunkPath!, chunkIndex++);
    } catch (e) {
      debugPrint("Error pausing: $e");
    }
  }

  Future<void> resumeRecording() async {
    if (!isRecording || !isPaused) return;
    setState(() => isPaused = false);
    await _startNextChunk();
  }

  Future<void> stopSession() async {
    if (!isRecording) return;

    setState(() {
      isRecording = false;
      isPaused = false;
    });

    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        await uploadChunk(currentChunkPath!, chunkIndex++);
      }

      await _dio.patch(
        "$uploadSession/$sessionId",
        data: {"sessionId": sessionId},
      );

      SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
      await sharedPreferenceData.initialize();
      await sharedPreferenceData.setCurrentSessionID('');
      await sharedPreferenceData.setCurrentChunkIndex(0);

      sessionId = null;
      chunkIndex = 0;
      currentChunkPath = null;

      Fluttertoast.showToast(
        msg: "Session successfully stopped",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
        fontSize: 16,
      );
    } catch (e) {
      debugPrint("Error stopping session: $e");
    }
  }

  Future<void> uploadChunk(String filePath, int chunkNumber) async {
    FormData formData = FormData.fromMap({
      "sessionId": sessionId,
      "chunkNumber": chunkNumber,
      "audio": await MultipartFile.fromFile(filePath,
          filename: "chunk_$chunkNumber.wav"),
    });

    try {
      await _dio.post(
        uploadChunkEndPoint,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );
    } catch (e) {
      debugPrint("Error uploading chunk: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        title: Text(
          patient["name"],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, size: 40, color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      patient["name"],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      patient["email"],
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetail("Patient ID", patient["user_id"]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// Recording Controls
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                child: Column(
                  children: [
                    Icon(
                      !isRecording
                          ? Icons.mic_none
                          : (isPaused ? Icons.pause_circle_filled : Icons.mic),
                      size: 64,
                      color: !isRecording
                          ? Colors.grey
                          : (isPaused ? Colors.orange : Colors.red),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      !isRecording
                          ? "Ready to Start Recording"
                          : (isPaused ? "Recording Paused" : "Recording..."),
                      style: TextStyle(
                        fontSize: 16,
                        color: isPaused ? Colors.orange : Colors.blueGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    /// 🎶 Animated Waveform
                    if (isRecording && !isPaused)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return AnimatedBuilder(
                              animation: _waveController,
                              builder: (_, __) {
                                double value = (index % 2 == 0
                                    ? _waveController.value
                                    : 1 - _waveController.value) *
                                    20;
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: 6,
                                  height: 20 + value,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),

                    const SizedBox(height: 25),

                    ElevatedButton.icon(
                      onPressed: () {
                        if (!isRecording) {
                          startSession();
                        } else if (isPaused) {
                          resumeRecording();
                        } else {
                          pauseRecording();
                        }
                      },
                      icon: Icon(
                        !isRecording
                            ? Icons.mic
                            : (isPaused ? Icons.play_arrow : Icons.pause),
                      ),
                      label: Text(
                        !isRecording
                            ? "Start Recording"
                            : (isPaused ? "Resume Recording" : "Pause Recording"),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: !isRecording
                            ? Colors.green
                            : (isPaused ? Colors.blue : Colors.orange),
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Stop Button
                    if (isRecording)
                      ElevatedButton.icon(
                        onPressed: stopSession,
                        icon: const Icon(Icons.stop),
                        label: const Text("Stop Session"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
