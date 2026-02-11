import 'package:flutter/material.dart';
import 'package:campus_events_app/pages/detail_page.dart';
import 'package:campus_events_app/utils.dart';

class Favories extends StatefulWidget {
  const Favories({super.key});

  @override
  State<Favories> createState() => _FavoritesState();

  // Liste statique pour stocker les favoris
  static List<Map<String, String>> favoriteItems = [];
}

class _FavoritesState extends State<Favories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mes Favoris",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Serif'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: Favories.favoriteItems.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "Aucun favori pour le moment",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: Favories.favoriteItems.length,
      itemBuilder: (context, index) {
        final item = Favories.favoriteItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: SizedBox(
              width: 60,
              height: 60,
              child: displayImage(item['image'], radius: 8),
            ),
            title: Text(
              item['title'] ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item['description'] ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.orange),
              onPressed: () {
                setState(() => Favories.favoriteItems.removeAt(index));
                showMessage(context, "Favori supprimé");
              },
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  eventId: item['id'],
                  imagePath: item['image'] ?? "",
                  title: item['title'] ?? "",
                  description: item['description'] ?? "",
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
