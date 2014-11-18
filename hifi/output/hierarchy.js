function change_hierarchy_link() {
  document.getElementById('hierarchy-link').text = String.fromCharCode('0x25bc') + " Browse Hierarchy"
}

window.onload = change_hierarchy_link;
