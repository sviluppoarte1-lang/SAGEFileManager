import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Official project repository (releases + source).
const String kSageFileManagerGithubUrl =
    'https://github.com/sviluppoarte1-lang/SAGEFileManager';

const String kSageFileManagerDonateUrl =
    'https://www.paypal.com/paypalme/fearescape/';

const String _repoApiPrefix =
    'https://api.github.com/repos/sviluppoarte1-lang/SAGEFileManager';

const String _latestReleaseApi = '$_repoApiPrefix/releases/latest';
const String _tagsApi = '$_repoApiPrefix/tags?per_page=10';

const Map<String, String> _githubHeaders = {
  'Accept': 'application/vnd.github+json',
  'X-GitHub-Api-Version': '2022-11-28',
  'User-Agent': 'SAGE-File-Manager/1.0',
};

/// Parsed latest GitHub release or tag (tag compared as semantic-ish version).
class GithubLatestRelease {
  GithubLatestRelease({
    required this.tagVersion,
    required this.htmlUrl,
    this.name,
  });

  final String tagVersion;
  final String htmlUrl;
  final String? name;
}

class GithubAppUpdateService {
  GithubAppUpdateService._();

  static String normalizeVersionTag(String raw) {
    var s = raw.trim();
    if (s.startsWith('v') || s.startsWith('V')) {
      s = s.substring(1);
    }
    final plus = s.indexOf('+');
    if (plus >= 0) s = s.substring(0, plus);
    final dash = s.indexOf('-');
    if (dash >= 0) s = s.substring(0, dash);
    return s.trim();
  }

  static List<int> _versionParts(String v) {
    final norm = normalizeVersionTag(v);
    final parts = <int>[];
    for (final seg in norm.split(RegExp(r'[.\s]+'))) {
      if (seg.isEmpty) continue;
      final m = RegExp(r'^(\d+)').firstMatch(seg);
      if (m != null) {
        parts.add(int.tryParse(m.group(1)!) ?? 0);
      }
    }
    return parts.isEmpty ? <int>[0] : parts;
  }

  /// > 0 if [a] is newer than [b].
  static int compareVersions(String a, String b) {
    final pa = _versionParts(a);
    final pb = _versionParts(b);
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < n; i++) {
      final da = i < pa.length ? pa[i] : 0;
      final db = i < pb.length ? pb[i] : 0;
      if (da != db) return da.compareTo(db);
    }
    return 0;
  }

  static bool isRemoteNewer(String remoteTag, String currentVersion) {
    return compareVersions(
          normalizeVersionTag(remoteTag),
          normalizeVersionTag(currentVersion),
        ) >
        0;
  }

  static GithubLatestRelease? _fromReleaseJson(String body) {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final tagName = map['tag_name'] as String?;
    if (tagName == null || tagName.isEmpty) return null;
    final htmlUrl = map['html_url'] as String? ?? kSageFileManagerGithubUrl;
    final name = map['name'] as String?;
    return GithubLatestRelease(
      tagVersion: tagName,
      htmlUrl: htmlUrl,
      name: name,
    );
  }

  /// Latest release if any; otherwise newest tag (repo may have tags but no formal release).
  static Future<GithubLatestRelease?> fetchLatestRelease() async {
    try {
      var response = await http
          .get(Uri.parse(_latestReleaseApi), headers: _githubHeaders)
          .timeout(const Duration(seconds: 18));
      if (response.statusCode == 200) {
        return _fromReleaseJson(response.body);
      }
      // 404 = no releases; try tags (lightweight, works without GitHub "Release" objects).
      response = await http
          .get(Uri.parse(_tagsApi), headers: _githubHeaders)
          .timeout(const Duration(seconds: 18));
      if (response.statusCode != 200) return null;
      final list = jsonDecode(response.body);
      if (list is! List<dynamic> || list.isEmpty) return null;
      GithubLatestRelease? best;
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final name = item['name'] as String?;
        if (name == null || name.isEmpty) continue;
        if (best == null ||
            compareVersions(name, best.tagVersion) > 0) {
          final tagEnc = Uri.encodeComponent(name);
          best = GithubLatestRelease(
            tagVersion: name,
            htmlUrl: '$kSageFileManagerGithubUrl/releases/tag/$tagEnc',
            name: name,
          );
        }
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// If GitHub has a newer release/tag than [PackageInfo.version], show a snackbar.
  static Future<void> checkAndMaybeNotify({
    required void Function(String version, String releaseUrl) onNewer,
  }) async {
    final info = await PackageInfo.fromPlatform();
    final latest = await fetchLatestRelease();
    if (latest == null) return;
    if (isRemoteNewer(latest.tagVersion, info.version)) {
      onNewer(normalizeVersionTag(latest.tagVersion), latest.htmlUrl);
    }
  }
}
