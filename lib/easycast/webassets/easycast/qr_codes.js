function showQRCodes() {
  var wifi = 'WIFI:S:easycast;T:WEP;P:easypass;H:false;;';
  var remote = 'http://easycast/remote';
  var lenght = Math.max(wifi.length, remote.length);
  wifi = wifi.padEnd(length);
  remote = remote.padEnd(lenght);
  new QRious({
    element: document.getElementById('qr-network'),
    value: wifi,
    size: 200,
  });
  new QRious({
    element: document.getElementById('qr-remote'),
    value: remote,
    size: 200,
  });  
}
