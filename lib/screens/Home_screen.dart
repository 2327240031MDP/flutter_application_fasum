import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fasum/screens/add_post_screen.dart';
import 'package:flutter_application_fasum/screens/detail_screen.dart';
import 'package:flutter_application_fasum/screens/sign_in_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} secs ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inHours < 48) {
      return '1 day ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Belum ada laporan'));
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,

              itemBuilder: (context, index) {
                final data = posts[index].data() as Map<String, dynamic>;

                final imageBase64 = data['image'] ?? '';
                final description = data['description'] ?? '';
                final createdAtStr = data['createdAt'] ?? '';
                final fullName = data['fullName'] ?? 'Anonim';
                final latitude = data['latitude'] ?? 0.0;
                final longitude = data['longitude'] ?? 0.0;
                final category = data['category'] ?? 'Lainnya';

                final createdAt = DateTime.parse(createdAtStr);

                final heroTag = 'fasum-image-${posts[index].id}';

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          imageBase64: imageBase64,
                          description: description,
                          createdAt: createdAt,
                          fullName: fullName,
                          latitude: latitude.toDouble(),
                          longitude: longitude.toDouble(),
                          category: category,
                          heroTag: heroTag,
                        ),
                      ),
                    );
                  },

                  child: Card(
                    elevation: 1,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,

                    shadowColor: Theme.of(context).colorScheme.shadow,

                    margin: const EdgeInsets.all(10),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        if (imageBase64.isNotEmpty)
                          Hero(
                            tag: heroTag,

                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),

                              child: Image.memory(
                                base64Decode(imageBase64),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                formatTime(createdAt),

                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                fullName,

                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                description,

                                style: const TextStyle(fontSize: 16),

                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.category,
                                    size: 18,
                                    color: Colors.red,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
