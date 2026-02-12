import 'package:flutter/material.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'Name A→Z';

  final List<Map<String, dynamic>> _allDoctors = List.generate(
    9,
    (i) => {
      'id': 'doc$i',
      'name': i == 2
          ? 'Aya Esraa'
          : (i == 3 ? 'Aya Osama' : 'Doctor $i'),
      'initials': i == 2
          ? 'AE'
          : (i == 3 ? 'AO' : 'D$i'),
      'specialty': 'General',
      'rating': (i % 5) + 1.0 - (i % 2 == 0 ? 0.5 : 0.0),
    },
  );

  List<Map<String, dynamic>> get _filteredDoctors {
    final q = _searchController.text.toLowerCase();

    var list = _allDoctors
        .where((d) => d['name'].toLowerCase().contains(q))
        .toList();

    switch (_sortOption) {
      case 'Name Z→A':
        list.sort((a, b) => b['name'].compareTo(a['name']));
        break;
      case 'Rating High → Low':
        list.sort((a, b) =>
            (b['rating'] as double).compareTo(a['rating']));
        break;
      case 'Rating Low → High':
        list.sort((a, b) =>
            (a['rating'] as double).compareTo(b['rating']));
        break;
      default:
        list.sort((a, b) => a['name'].compareTo(b['name']));
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
          return const Icon(Icons.star, color: Colors.amber, size: 14);
        } else if (i == full && half) {
          return const Icon(Icons.star_half,
              color: Colors.amber, size: 14);
        } else {
          return const Icon(Icons.star_border,
              color: Colors.grey, size: 14);
        }
      }),
    );
  }

  void _showSortMenu() async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
      items: const [
        PopupMenuItem(value: 'Name A→Z', child: Text('Name A→Z')),
        PopupMenuItem(value: 'Name Z→A', child: Text('Name Z→A')),
        PopupMenuItem(
            value: 'Rating High → Low',
            child: Text('Rating High → Low')),
        PopupMenuItem(
            value: 'Rating Low → High',
            child: Text('Rating Low → High')),
      ],
    );

    if (selected != null) {
      setState(() => _sortOption = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔹 Search + tiny sort icon
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle:
                            const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white12
                                : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness ==
                                Brightness.dark
                            ? Colors.white12
                            : Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.sort,
                      size: 18,
                    ),
                    onPressed: _showSortMenu,
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final d = doctors[index];

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    Colors.blue.shade50,
                                child: Text(
                                  d['initials'],
                                  style:
                                      const TextStyle(
                                    color: Colors.blue,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                d['name'],
                                textAlign:
                                    TextAlign.center,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d['specialty'],
                                style:
                                    const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildStars(
                                  d['rating']),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context,
                                      '/doctorDetail',
                                      arguments: d);
                                },
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                          horizontal:
                                              10),
                                  minimumSize:
                                      const Size(0, 30),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                18),
                                  ),
                                ),
                                child:
                                    const Text(
                                  'View',
                                  style:
                                      TextStyle(
                                          fontSize:
                                              11),
                                ),
                              ),
                              const SizedBox(
                                  width: 6),
                              SizedBox(
                                height: 30,
                                width: 30,
                                child:
                                    OutlinedButton(
                                  onPressed:
                                      () {},
                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    padding:
                                        EdgeInsets
                                            .zero,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  18),
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons.call,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
