import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_events_app/pages/detail_page.dart';
import 'package:campus_events_app/pages/favories.dart';
import 'package:campus_events_app/utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECF4),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("events").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Une erreur est survenue"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.requireData;
            final featuredEvents = data.docs
                .where((doc) => doc['is_featured'] == true)
                .toList();
            final allEvents = data.docs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  if (featuredEvents.isNotEmpty)
                    _buildFeaturedSection(featuredEvents),
                  _buildAllEventsSection(allEvents),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Image.asset("assets/images/logorond.jpg", height: 40),
          const SizedBox(height: 5),
          const Text(
            "Campus Events",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            "Que voulez vous faire aujourd'hui ?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(List<DocumentSnapshot> events) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        _buildSectionHeader("À la une"),
        const SizedBox(height: 15),
        SizedBox(
          height: screenHeight * 0.35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _buildFeaturedCard(
                events[index],
                screenWidth,
                screenHeight,
              );
            },
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildAllEventsSection(List<DocumentSnapshot> events) {
    return Column(
      children: [
        _buildSectionHeader("Tous les événements"),
        const SizedBox(height: 15),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) => _buildWideCard(events[index]),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(
    DocumentSnapshot doc,
    double screenWidth,
    double screenHeight,
  ) {
    Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
    event['id'] = doc.id; // Ajout de l'ID au map
    return GestureDetector(
      onTap: () => _navigateToDetail(event),
      child: SizedBox(
        width: screenWidth * 0.6,
        child: Card(
          margin: const EdgeInsets.only(right: 15, bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: displayImage(
                  event["image_url"],
                  height: screenHeight * 0.2,
                  width: double.infinity,
                ),
              ),
              ListTile(
                title: Text(
                  event["title"] ?? "Sans titre",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.orange),
                  onPressed: () => _addToFavorites(event),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(DocumentSnapshot doc) {
    Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
    event['id'] = doc.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        onTap: () => _navigateToDetail(event),
        leading: SizedBox(
          width: 60,
          height: 60,
          child: displayImage(event["image_url"], radius: 8),
        ),
        title: Text(
          event["title"] ?? "Sans titre",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          event["description"] ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.grey),
          onPressed: () => _addToFavorites(event),
        ),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          eventId: event["id"],
          imagePath: event["image_url"] ?? "assets/images/image5.jpg",
          title: event["title"] ?? "Sans titre",
          description: event["description"] ?? "",
        ),
      ),
    );
  }

  void _addToFavorites(Map<String, dynamic> event) {
    Map<String, String> favEvent = {
      "id": event["id"]?.toString() ?? "",
      "image": event["image_url"]?.toString() ?? "assets/images/image5.jpg",
      "title": event["title"]?.toString() ?? "Sans titre",
      "description": event["description"]?.toString() ?? "",
    };
    setState(() {
      Favories.favoriteItems.add(favEvent);
    });
    showMessage(context, "${event["title"]} ajouté aux favoris");
  }
}
