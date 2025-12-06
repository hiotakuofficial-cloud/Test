import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebPlayerScreen extends StatelessWidget {
  final String streamUrl;
  final String title;

  WebPlayerScreen({required this.streamUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stream URL:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                streamUrl,
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
            SizedBox(height: 20),
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Copy the URL above\n'
              '2. Open VLC Media Player or MX Player\n'
              '3. Go to "Open Network Stream"\n'
              '4. Paste the URL and play\n\n'
              'Note: URLs may expire after some time.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
