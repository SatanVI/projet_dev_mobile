import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campus_events_app/pages/favories.dart';
import 'package:campus_events_app/utils.dart';
import 'package:campus_events_app/services/notification_service.dart';

class DetailPage extends StatefulWidget {
  final String? eventId;
  final String imagePath;
  final String title;
  final String description;

  const DetailPage({
    super.key,
    this.eventId,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isReserving = false;
  bool isReserved = false;

  @override
  void initState() {
    super.initState();
    _checkReservationStatus();
    NotificationService().init();
  }

  Future<void> _checkReservationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.eventId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reservations')
          .doc(widget.eventId)
          .get();
      if (mounted) {
        setState(() => isReserved = doc.exists);
      }
    }
  }

  Future<void> _reservePlace() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(context, "Connectez-vous pour réserver", isError: true);
      return;
    }

    if (widget.eventId == null) {
      showMessage(
        context,
        "Impossible de réserver cet événement",
        isError: true,
      );
      return;
    }

    setState(() => isReserving = true);

    try {
      final reservationRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reservations')
          .doc(widget.eventId);

      final doc = await reservationRef.get();

      if (doc.exists) {
        if (mounted) {
          showMessage(
            context,
            "Vous avez déjà réservé une place",
            isError: true,
          );
        }
      } else {
        await reservationRef.set({
          'eventId': widget.eventId,
          'title': widget.title,
          'image_url': widget.imagePath,
          'description': widget.description,
          'reserved_at': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          await NotificationService().showNotification(
            "Réservation confirmée",
            "Votre place pour '${widget.title}' a été réservée.",
          );
          setState(() => isReserved = true);
          showMessage(context, "Place réservée avec succès !");
        }
      }
    } catch (e) {
      if (mounted) showMessage(context, "Erreur : $e", isError: true);
    } finally {
      if (mounted) setState(() => isReserving = false);
    }
  }

  Future<void> _cancelReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.eventId == null) return;

    setState(() => isReserving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reservations')
          .doc(widget.eventId)
          .delete();

      if (mounted) {
        setState(() => isReserved = false);
        showMessage(context, "Réservation annulée");
      }
    } catch (e) {
      if (mounted) showMessage(context, "Erreur : $e", isError: true);
    } finally {
      if (mounted) setState(() => isReserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.orange),
            onPressed: () {
              Favories.favoriteItems.add({
                "id": widget.eventId ?? "",
                "image": widget.imagePath,
                "title": widget.title,
                "description": widget.description,
              });
              showMessage(context, "${widget.title} ajouté aux favoris !");
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE8ECF4),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: displayImage(widget.imagePath),
            ),
            _buildContent(),
          ],
        ),
      ),
      bottomNavigationBar: _buildReservationButton(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Description",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isReserving
            ? null
            : (isReserved ? _cancelReservation : _reservePlace),
        style: ElevatedButton.styleFrom(
          backgroundColor: isReserved
              ? Colors.redAccent
              : const Color(0xFF0F4E7F),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isReserving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isReserved ? "Annuler ma réservation" : "Réserver ma place",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
