// Generates a unique BUILD_ID, writes web/app_build.json with the same id,
// then builds web with the id baked in via --dart-define.
//
// Usage:
//   dart run tool/build_web.dart [-- <extra flutter build args>]
//
// The running app compares its baked-in BUILD_ID against a freshly fetched
// web/app_build.json (see lib/services/web_update_service.dart). Always
// deploy with this script (or replicate its two steps) — otherwise the
// update banner can never trigger (id mismatch impossible) or, worse,
// always triggers (stale app_build.json from a previous deploy).
import 'dart:io';

Future<void> main(List<String> args) async {
  // Split off extra args after `--` to forward to `flutter build web`.
  final extra = <String>[];
  final sep = args.indexOf('--');
  if (sep >= 0) extra.addAll(args.sublist(sep + 1));

  final now = DateTime.now().toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  var buildId =
      '${now.year}${two(now.month)}${two(now.day)}'
      'T${two(now.hour)}${two(now.minute)}${two(now.second)}Z';

  // Append short git sha when available (best-effort, never fatal).
  try {
    final sha = await Process.run('git', ['rev-parse', '--short', 'HEAD']);
    final s = (sha.stdout as String).trim();
    if (sha.exitCode == 0 && s.isNotEmpty) buildId += '-$s';
  } catch (_) {}

  File('web/app_build.json').writeAsStringSync(
    '{"build_id":"$buildId"}\n',
  );
  stdout.writeln('BUILD_ID=$buildId -> web/app_build.json');

  final result = await Process.run('flutter', [
    'build',
    'web',
    '--release',
    '--pwa-strategy=none',
    '--dart-define=BUILD_ID=$buildId',
    ...extra,
  ], runInShell: true);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exit(result.exitCode);
}
