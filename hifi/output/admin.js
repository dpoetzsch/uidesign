function admin(site) {
  document.getElementById('login-fields').visibility = 'hidden';
  var ll = document.getElementById('login-link')
  
  ll.text = 'Sign Out (admin)';
  ll.href = site;
  ll.onclick = '';
}
