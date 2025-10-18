import 'package:flutter/material.dart';
import '../data/orals.dart';

class AlldiseasesScreen extends StatelessWidget {
	const AlldiseasesScreen({Key? key}) : super(key: key);

	String _assetPath(String path) => path.startsWith('/') ? path.substring(1) : path;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('All Diseases'),
			),
			body: ListView.builder(
				padding: const EdgeInsets.symmetric(vertical: 8),
				itemCount: orals.length,
				itemBuilder: (context, index) {
					final item = orals[index];
					final title = item['title'] as String? ?? '';
					final short = item['shortTitle'] as String? ?? '';
					final desc = item['description'] as String? ?? '';
					final imgList = item['img'] as List<dynamic>?;
					final rawImg = (imgList != null && imgList.isNotEmpty) ? (imgList.first as String) : null;
					final imgAsset = rawImg != null ? _assetPath(rawImg) : null;

					return Card(
						margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
						child: ListTile(
							contentPadding: const EdgeInsets.all(8),
							leading: imgAsset != null
									? Image.asset(
											imgAsset,
											width: 64,
											height: 64,
											fit: BoxFit.cover,
											errorBuilder: (ctx, err, st) => Container(
												width: 64,
												height: 64,
												color: Colors.grey.shade200,
												child: const Icon(Icons.broken_image, color: Colors.grey),
											),
										)
									: CircleAvatar(child: Text(short)),
							title: Text(title),
							subtitle: Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
							onTap: () {
								// placeholder: show overview in a dialog
								final overview = item['overview'] as String? ?? '';
								showDialog(
									context: context,
									builder: (_) => AlertDialog(
										title: Text(title),
										content: SingleChildScrollView(child: Text(overview)),
										actions: [
											TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
										],
									),
								);
							},
						),
					);
				},
			),
		);
	}
}

