import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorDetailScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  double _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final id = widget.doctor['id'] ?? '';

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor id missing')),
      );
      return;
    }

    if (_selectedRating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final base = dotenv.env['API_URL'] ?? 'http://10.0.2.2:5000';
    final url = Uri.parse('$base/api/doctors/$id/rating');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rating': _selectedRating,
          'comment': _commentController.text,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully')),
        );

        setState(() {
          _selectedRating = 0;
          _commentController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit rating')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarSelector() {
    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1;
        return IconButton(
          onPressed: () => setState(() => _selectedRating = idx.toDouble()),
          icon: Icon(
            _selectedRating >= idx ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 26,
          ),
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final rating = (d['rating'] as double?) ?? 0.0;
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 480;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Builder(builder: (context) {
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.blue.shade600,
                          child: Text(
                            (d['initials'] ?? '').toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          d['name'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d['specialty'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (i) {
                              if (i < rating.floor()) {
                                return const Icon(Icons.star,
                                    color: Colors.amber, size: 18);
                              }
                              if (i == rating.floor() &&
                                  rating - rating.floor() >= 0.5) {
                                return const Icon(Icons.star_half,
                                    color: Colors.amber, size: 18);
                              }
                              return const Icon(Icons.star_border,
                                  color: Colors.grey, size: 18);
                            }),
                            const SizedBox(width: 6),
                            Text(rating.toStringAsFixed(1)),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          (d['initials'] ?? '').toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d['specialty'] ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(5, (i) {
                                  if (i < rating.floor()) {
                                    return const Icon(Icons.star,
                                        color: Colors.amber, size: 18);
                                  }
                                  if (i == rating.floor() &&
                                      rating - rating.floor() >= 0.5) {
                                    return const Icon(Icons.star_half,
                                        color: Colors.amber, size: 18);
                                  }
                                  return const Icon(Icons.star_border,
                                      color: Colors.grey, size: 18);
                                }),
                                const SizedBox(width: 6),
                                Text(rating.toStringAsFixed(1)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),
            _infoRow(Icons.phone, d['phone'] ?? '—'),
            _infoRow(Icons.email, d['email'] ?? '—'),
            _infoRow(Icons.location_on, d['location'] ?? '—'),
            _infoRow(Icons.work, 'Experience: ${d['experience'] ?? '—'}'),
            _infoRow(Icons.payment, 'Fee: ${d['fee'] ?? '—'}'),

            const SizedBox(height: 24),
            const Text(
              'Rate this doctor',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildStarSelector(),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a comment (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitRating,
                      child: const Text('Submit Rating'),
                    ),
            ),

            const SizedBox(height: 24),
            const Text(
              'About',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(d['about'] ?? '-'),

            const SizedBox(height: 16),
            const Text(
              'Medical Notes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(d['notes'] ?? 'No notes'),
            ),

            const SizedBox(height: 24),

            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('All Doctors'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Book Appointment'),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('All Doctors'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Book Appointment'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
