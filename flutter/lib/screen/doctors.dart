import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../services/auth.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'name_asc';
  List<Doctor> _allDoctors = [];
  bool _loading = true;
  String? _error;

  final DoctorService _doctorService = DoctorService();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

Future<void> _fetchDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await readToken();
    print('TOKEN: $token');

    try {
      final doctors = await _doctorService.getAll();

      if (!mounted) return;

      if (doctors.isNotEmpty) {
        try {
          final doctorsWithRatings = await Future.wait(
            doctors.map((doctor) async {
              final rating = await _doctorService.getAverageRating(doctor.id);
              return Doctor(
                id: doctor.id,
                firstName: doctor.firstName,
                lastName: doctor.lastName,
                specialty: doctor.specialty,
                photo: doctor.photo,
                location: doctor.location,
                rate: (rating['average'] as num?)?.toDouble() ?? 0.0,
                experienceYears: doctor.experienceYears,
                consultationFee: doctor.consultationFee,
              );
            }),
          );

          if (mounted) {
            setState(() {
              _allDoctors = doctorsWithRatings;
              _loading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _allDoctors = doctors;
              _loading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _allDoctors = doctors;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Doctor> get _filteredDoctors {
    final q = _searchController.text.toLowerCase();

    var list = _allDoctors.where((d) {
      final searchText =
          '${d.firstName} ${d.lastName} ${d.specialty ?? ''} ${d.location ?? ''}'
              .toLowerCase();
      return searchText.contains(q);
    }).toList();

    switch (_sortOption) {
      case 'name_desc':
        list.sort((a, b) => b.fullName.compareTo(a.fullName));
        break;
      case 'rate_desc':
        list.sort((a, b) => (b.rate ?? 0).compareTo(a.rate ?? 0));
        break;
      case 'rate_asc':
        list.sort((a, b) => (a.rate ?? 0).compareTo(b.rate ?? 0));
        break;
      case 'name_asc':
      default:
        list.sort((a, b) => a.fullName.compareTo(b.fullName));
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildStars(double rating) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (i == full && half) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.grey, size: 16);
        }
      }),
    );
  }

  void _showSortMenu() async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
      items: const [
        PopupMenuItem(value: 'name_asc', child: Text('Name A→Z')),
        PopupMenuItem(value: 'name_desc', child: Text('Name Z→A')),
        PopupMenuItem(value: 'rate_desc', child: Text('Rating High → Low')),
        PopupMenuItem(value: 'rate_asc', child: Text('Rating Low → High')),
      ],
    );

    if (selected != null) {
      setState(() => _sortOption = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1000;

    int crossAxisCount = 4;
    if (isMobile) crossAxisCount = 1;
    if (isTablet && !isMobile) crossAxisCount = 2;
    if (!isTablet && MediaQuery.of(context).size.width < 1400)
      crossAxisCount = 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Doctors'), elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchDoctors,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search and Sort Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search by name, specialty or location',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white12
                                  : Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.sort, size: 20),
                          onPressed: _showSortMenu,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Doctors Grid
                  Expanded(
                    child: doctors.isEmpty
                        ? Center(
                            child: Text(
                              'No doctors found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),
                        itemCount: doctors.length,
                        itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
                   )
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDoctorCard(Doctor doc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Doctor Info
            Column(
              children: [
                // Photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      doc.photo ?? doc.getPlaceholder(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          doc.getPlaceholder(),
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
                const SizedBox(height: 12),
                // Name
                Text(
                  doc.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Specialty
                Text(
                  doc.specialty ?? 'General',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Location
                if (doc.location != null)
                  Text(
                    doc.location!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                // Stars
                _buildStars(doc.rate ?? 0.0),
              ],
            ),
            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/book-appointment',
                        arguments: doc,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.green.shade600,
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/doctorDetail',
                            arguments: doc,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Profile',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/doctorChat');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Icon(Icons.call, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
