import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YaoVideo extends StatefulWidget {
  const YaoVideo({
    super.key,
  });

  @override
  State<YaoVideo> createState() => _YaoVideoState();
}

class _YaoVideoState extends State<YaoVideo> {
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();

  void _addVideo() {
    String videoUrl = _videoUrlController.text;
    String title = _judulController.text;

    if (videoUrl.isNotEmpty) {
      FirebaseFirestore.instance.collection('yaovideos').add({
        'url': videoUrl,
        'title': title,
      });

      _videoUrlController.clear();
      _judulController.clear();
    }
  }

  void _shareVideo(String vidUrl) {
    Share.share('Cek Video Terbaru Saya: $vidUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Podcast List"),
        actions: const [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Video URL',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addVideo,
            child: const Text('Add Video'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('yaovideos')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String videoUrl = data['url'];
                    String title = data['title'];

                    return ListTile(
                      title: Text(title),
                      trailing: IconButton(
                        onPressed: () {
                          _shareVideo(videoUrl);
                        },
                        icon: const Icon(
                          Icons.share,
                          color: Colors.black,
                          size: 24.0,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  YaoVideoPlayerPage(myVideoUrl: videoUrl)),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class YaoVideoList extends StatelessWidget {
  const YaoVideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Stream'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('yaovideos').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String videoUrl = data['url'];
              String title = data['title'];

              return ListTile(
                title: Text(title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YaoVideoPlayerPage(
                        myVideoUrl: videoUrl,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class YaoVideoPlayerPage extends StatelessWidget {
  final String myVideoUrl;
  const YaoVideoPlayerPage({super.key, required this.myVideoUrl});

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(myVideoUrl).toString(),
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          progressColors: const ProgressBarColors(
            playedColor: Colors.blue,
            handleColor: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
