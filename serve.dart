import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('M-Practice 服务已启动');
  for (final iface in await NetworkInterface.list()) {
    for (final addr in iface.addresses) {
      if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
        print('  iPhone 访问: http://${addr.address}:8080');
      }
    }
  }
  print('  本机访问: http://localhost:8080');

  await for (final request in server) {
    var path = request.uri.path;
    if (path == '/') path = '/index.html';

    final file = File('build/web$path');
    if (await file.exists()) {
      final ext = path.split('.').last;
      final contentType = switch (ext) {
        'html' => 'text/html; charset=utf-8',
        'js' => 'application/javascript',
        'wasm' => 'application/wasm',
        'css' => 'text/css',
        'json' => 'application/manifest+json',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'svg' => 'image/svg+xml',
        'ttf' => 'font/ttf',
        'otf' => 'font/otf',
        'woff' || 'woff2' => 'font/woff2',
        _ => 'application/octet-stream',
      };
      try {
        request.response.headers.set('Content-Type', contentType);
        await request.response.addStream(file.openRead());
        await request.response.close();
      } catch (_) {
        // 客户端断开连接，忽略
      }
    } else {
      request.response.statusCode = 404;
      await request.response.close();
    }
  }
}
