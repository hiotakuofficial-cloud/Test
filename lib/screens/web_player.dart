import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class WebPlayerScreen extends StatelessWidget {
  final String streamUrl;
  final String title;
  final bool? isBypassed;

  WebPlayerScreen({required this.streamUrl, required this.title, this.isBypassed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBypassed == true)
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 16),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Protection Bypassed Successfully!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Text(
              'Stream URL:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                streamUrl,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: streamUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('URL copied to clipboard!')),
                      );
                    },
                    icon: Icon(Icons.copy),
                    label: Text('Copy URL'),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Instructions:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              isBypassed == true 
                ? '✅ Protection bypassed! This URL should work in:\n\n'
                  '1. VLC Media Player\n'
                  '2. MX Player\n'
                  '3. Any HLS-compatible player\n'
                  '4. Web browsers (may work directly)\n\n'
                  'Copy the URL and paste it in your preferred player.'
                : '1. Copy the URL above\n'
                  '2. Open VLC Media Player or MX Player\n'
                  '3. Go to "Open Network Stream"\n'
                  '4. Paste the URL and play\n\n'
                  'Note: URLs may expire after some time.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
