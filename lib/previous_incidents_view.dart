import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PreviousIncidentsView extends StatefulWidget {
  const PreviousIncidentsView({super.key});

  @override
  State<PreviousIncidentsView> createState() => _PreviousIncidentsViewState();
}

class _PreviousIncidentsViewState extends State<PreviousIncidentsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.yellow.withOpacity(0.3),
        title: const Text(
          "Previous Incidents Reported",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
        color: Colors.yellow.withOpacity(0.3),
        height: double.infinity,
        width: double.infinity,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('uploads_report')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No reported incidents found'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                
                // Format the date
                final date = DateTime.parse(data['date']);
                final formattedDate = '${date.day}/${date.month}/${date.year}';

                return Container(
                  padding: const EdgeInsets.all(20),
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Date: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black
                              ),
                              children: [
                                TextSpan(
                                  text: formattedDate,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal
                                  )
                                )
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "Need Help: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black
                              ),
                              children: [
                                TextSpan(
                                  text: data['need_help'] ?? 'Not specified',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal
                                  )
                                )
                              ]
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 10, right: 5, top: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.4),
                                      width: 1
                                    )
                                  ),
                                  height: 70,
                                  child: SingleChildScrollView(
                                    child: Text(data['description'] ?? 'No description provided'),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (data['image'] != null && data['image'].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: data['image'],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
