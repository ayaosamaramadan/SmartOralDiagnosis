import 'package:flutter/material.dart';
import 'progress_widget.dart';

class CompletedOr extends StatelessWidget {
  final Map<String, dynamic> form; // expects keys: firstName,lastName,email,password,location,phoneNumber

  const CompletedOr({Key? key, required this.form}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final checks = [
      ((form['firstName'] as String?)?.trim())?.isNotEmpty ?? false,
      ((form['lastName'] as String?)?.trim())?.isNotEmpty ?? false,
      ((form['email'] as String?)?.trim())?.isNotEmpty ?? false,
      ((form['password'] as String?)?.trim())?.isNotEmpty ?? false,
      ((form['location']?.toString())?.trim())?.isNotEmpty ?? false,
      ((form['phoneNumber'] as String?)?.trim())?.isNotEmpty ?? false,
    ];
    final completed = checks.where((c) => c).length;
    final total = checks.length;
    final percent = ((completed / total) * 100).round();

    Widget row(String label, String hint, bool ok) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(label[0], style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text(hint, style: Theme.of(context).textTheme.bodySmall),
                  ],
                )
              ],
            ),
            Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.green[600] : Colors.red[600]),
          ],
        );

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Complete your profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Fill the sections below to complete your profile', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                ProgressWidget(percent: percent),
              ],
            ),
            SizedBox(height: 12),
            Column(
              children: [
                row('First name', 'Your given name', checks[0]),
                Divider(),
                row('Last name', 'Your family name', checks[1]),
                Divider(),
                row('Email', 'Primary contact email', checks[2]),
                Divider(),
                row('Password', 'Set an account password', checks[3]),
                Divider(),
                row('Location', 'City, state or coordinates', checks[4]),
                Divider(),
                row('Phone', 'Mobile or contact number', checks[5]),
              ],
            )
          ],
        ),
      ),
    );
  }
}
