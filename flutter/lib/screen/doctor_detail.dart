import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/doctor.dart';
import '../services/api.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;
  
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
    final doctorId = widget.doctor.id;

    if (doctorId.isEmpty) {
      _showMessage('Doctor ID missing', isError: true);
      return;
    }

    if (_selectedRating <= 0) {
      _showMessage('Please select a rating', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      final body = {
        'doctorId': doctorId,
        'score': _selectedRating, // Send as double, backend will handle conversion
        'comment': _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
      };

      debugPrint('Submitting rating to ${Api.baseUrl}/api/doctors/ratings');
      debugPrint('Request body: $body');

      final response = await http.post(
        Uri.parse('${Api.baseUrl}/api/doctors/ratings'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - backend not responding');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response headers: ${response.headers}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showMessage('✓ Rating submitted successfully!', isSuccess: true);
        setState(() {
          _selectedRating = 0;
          _commentController.clear();
        });
      } else if (response.statusCode == 400) {
        final message = response.body.isNotEmpty 
            ? response.body 
            : 'Invalid rating - please check your input';
        _showMessage(message, isError: true);
      } else if (response.statusCode == 401) {
        _showMessage('Unauthorized - please login again', isError: true);
      } else {
        _showMessage('Error: ${response.statusCode} - ${response.body}', isError: true);
      }
    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      _showMessage('Network error - check your internet connection', isError: true);
    } catch (e) {
      debugPrint('Error: $e');
      _showMessage('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message, {bool isError = false, bool isSuccess = false}) {
    final snack = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : (isError ? Colors.red : Colors.blue),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Widget _buildStarSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final index = i + 1;
        return IconButton(
          onPressed: () => setState(() => _selectedRating = index.toDouble()),
          icon: Icon(
            _selectedRating >= index ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        );
      }),
    );
  }

  Widget _buildStarDisplay(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return const Icon(Icons.star, color: Colors.amber, size: 18);
          }
          if (i == rating.floor() && (rating - rating.floor()) >= 0.5) {
            return const Icon(Icons.star_half, color: Colors.amber, size: 18);
          }
          return const Icon(Icons.star_border, color: Colors.grey, size: 18);
        }),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final isMobile = MediaQuery.of(context).size.width < 600;

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
            // Doctor Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Photo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade100, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          doctor.photo ?? doctor.getPlaceholder(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              doctor.getPlaceholder(),
                              fit: BoxFit.cover,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      doctor.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Specialty
                    Text(
                      doctor.specialty ?? 'General',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Rating
                    _buildStarDisplay(doctor.rate ?? 0.0),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Information Section
            const Text(
              'Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _infoRow(Icons.location_on, 'Location', doctor.location ?? 'Not specified'),
                    const Divider(),
                    _infoRow(Icons.school, 'Experience', 
                        doctor.experienceYears != null ? '${doctor.experienceYears} years' : 'Not specified'),
                    const Divider(),
                    _infoRow(Icons.payment, 'Consultation Fee',
                        doctor.consultationFee != null ? '\$${doctor.consultationFee}' : 'Not specified'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rating Section
            const Text(
              'Rate this Doctor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(child: _buildStarSelector()),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Rating', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Doctors'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/book-appointment',
                        arguments: widget.doctor,
                      );
                    },
                    child: const Text('Book Appointment'),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Doctors'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/book-appointment',
                          arguments: widget.doctor,
                        );
                      },
                      child: const Text('Book Appointment'),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
