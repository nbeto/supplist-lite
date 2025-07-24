import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Remove o appBar!
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  l10n.about,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.appTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.appVersion, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text(l10n.aboutDescription, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              Text('${l10n.author}: Norberto Marques', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('${l10n.contact}: info@supplist.app', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.link),
                  label: Text(l10n.githubRepo),
                  onPressed: () async {
                    final url = Uri.parse('https://github.com/nbeto');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.license,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}