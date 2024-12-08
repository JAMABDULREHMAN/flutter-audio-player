import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:avatar_glow/avatar_glow.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _playlist = [];
  int _currentIndex = 0;
  bool isPlaying = false;
  bool isGlowing = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _playlist = result.paths
              .where((path) => path != null)
              .cast<String>()
              .toList();
          _currentIndex = 0; // Start with the first file.
        });

        if (_playlist.isNotEmpty) {
          _togglePlayPause(); // Automatically start playing the first file.
        }
      }
    } catch (e) {
      print("Error picking files: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
        isGlowing = false; // Stop glowing when paused.
      });
    } else {
      if (_playlist.isNotEmpty) {
        await _audioPlayer.play(DeviceFileSource(_playlist[_currentIndex]));
        setState(() {
          isPlaying = true;
          isGlowing = true; // Start glowing when playback begins.
        });
      }
    }
  }

  Future<void> _playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _togglePlayPause(); // Play the next song.
    } else {
      print("No more songs in the playlist.");
    }
  }

  Future<void> _playPrevious() async {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _togglePlayPause(); // Play the previous song.
    } else {
      print("No previous songs in the playlist.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Big Music Player"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AvatarGlow(
              glowColor: Colors.blue,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              animate: isGlowing,
              child: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 60.0,
                child: Icon(
                  Icons.music_note,
                  size: 60.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _playlist.isNotEmpty
                  ? "Playing: ${_playlist[_currentIndex].split('/').last}"
                  : "No File Selected",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFiles,
              child: const Text("Pick Audio Files"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous,
                      size: 64, color: Colors.orange),
                  onPressed: _playlist.isEmpty ? null : _playPrevious,
                ),
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 64,
                    color: isPlaying ? Colors.red : Colors.green,
                  ),
                  onPressed: _playlist.isEmpty ? null : _togglePlayPause,
                ),
                IconButton(
                  icon:
                      const Icon(Icons.skip_next, size: 64, color: Colors.blue),
                  onPressed: _playlist.isEmpty ? null : _playNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
