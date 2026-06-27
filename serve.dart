import 'dart:io';

void main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('M-Practice 运行在 http://localhost:8080');

  await for (final request in server) {
    var path = request.uri.path;
    if (path == '/') path = '/index.html';

    final file = File('build/web$path');
    if (await file.exists()) {
      final ext = path.split('.').last;
      final contentType = switch (ext) {
        'html' => 'text/html',
        'js' => 'application/javascript',
        'wasm' => 'application/wasm',
        'css' => 'text/css',
        'json' => 'application/json',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'svg' => 'image/svg+xml',
        'ttf' => 'font/ttf',
        'otf' => 'font/otf',
        'woff' || 'woff2' => 'font/woff2',
        _ => 'application/octet-stream',
      };
      request.response.headers.set('Content-Type', contentType);
      request.response.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      request.response.headers.set('Cross-Origin-Embedder-Policy', 'require-corp');
      await request.response.addStream(file.openRead());
    } else {
      request.response.statusCode = 404;
    }
    await request.response.close();
  }
}
