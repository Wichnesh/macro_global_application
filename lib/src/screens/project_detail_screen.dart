import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../model/ProjectModel.dart';
import '../service/media_compressor.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen(this.project, {super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  String? imageBase64;
  String? videoBase64;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    imageBase64 = widget.project.imageBase64;
    videoBase64 = widget.project.videoBase64;

    // Make sure to delay video player setup after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (videoBase64 != null) {
        _loadVideoPlayer();
      }
    });
  }

  Future<void> _loadVideoPlayer() async {
    try {
      final file = await writeBase64VideoToTempFile(videoBase64!);
      final controller = VideoPlayerController.file(file);

      await controller.initialize();
      setState(() {
        _videoController = controller;
        _videoController!.play();
      });
    } catch (e) {
      print('❌ Video player error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading video player: ${e.toString()}')),
      );
    }
  }

  Future<File> writeBase64VideoToTempFile(String base64Data) async {
    final bytes = base64Decode(base64Data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp_video.mp4');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> uploadFileToFirestore(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type == 'image' ? FileType.image : FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!file.existsSync()) throw Exception("File not found");

        String base64;
        if (type == 'image') {
          base64 = await MediaCompressor.compressImageToBase64(file);
        } else {
          base64 = await MediaCompressor.compressVideoToBase64(file);
        }

        final base64Bytes = (base64.length * 3 / 4);
        if (base64Bytes > 950000) {
          throw Exception("⚠️ Compressed $type is too large (${(base64Bytes / 1024).round()} KB)");
        }

        final field = type == 'image' ? 'imageBase64' : 'videoBase64';

        await FirebaseFirestore.instance.collection('projects').doc(widget.project.id).update({field: base64});

        setState(() {
          if (type == 'image') {
            imageBase64 = base64;
          } else {
            videoBase64 = base64;
          }
        });

        if (type == 'video') {
          await _loadVideoPlayer();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$type uploaded and saved in Firestore!')),
        );
      }
    } catch (e) {
      print('❌ Upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(project.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('People Working: ${project.peopleWorking}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Projected Revenue:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...project.projectedRevenue.entries.map((e) => Text('${e.key}: ${e.value}')),
            const SizedBox(height: 20),
            if (imageBase64 != null) ...[
              const Text('Image Preview:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Image.memory(base64Decode(imageBase64!), height: 200),
            ],
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => uploadFileToFirestore('image'),
              icon: const Icon(Icons.image),
              label: const Text('Upload/Replace Image'),
            ),
            const SizedBox(height: 20),
            if (_videoController != null && _videoController!.value.isInitialized) ...[
              const Text('Video Preview:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              IconButton(
                icon: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                  });
                },
              ),
            ],
            ElevatedButton.icon(
              onPressed: () => uploadFileToFirestore('video'),
              icon: const Icon(Icons.upload),
              label: const Text('Upload/Replace Video'),
            ),
          ],
        ),
      ),
    );
  }
}
