function syntaxHighlight(json) {
  if (typeof json != 'string') {
    json = JSON.stringify(json, undefined, 2);
  }
  json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return json.replace(
    /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g,
    function (match) {
      var cls = 'number';
      if (/^"/.test(match)) {
        if (/:$/.test(match)) {
          cls = 'key';
        } else {
          cls = 'string';
        }
      } else if (/true|false/.test(match)) {
        cls = 'boolean';
      } else if (/null/.test(match)) {
        cls = 'null';
      }
      return '<span class="json-' + cls + '">' + match + '</span>';
    }
  );
}

function updateUserData() {
  const userProfileJson = document.getElementById('userProfileJson');
  if (userProfileJson && currentUser) {
    userProfileJson.innerHTML = syntaxHighlight(currentUser);
    hideLogin();
  }
  else {
    showLogin();
  }
}

function hideLogin() {
  const loginSection = document.getElementById('loginSection');
  loginSection.style.display = 'none';
  const dashboard = document.getElementById('dashboard');
  dashboard.style.display = 'block';
}

function showLogin() {
  const loginSection = document.getElementById('loginSection');
  loginSection.style.display = 'block';
  const dashboard = document.getElementById('dashboard');
  dashboard.style.display = 'none';
}

/*
Log the websocket message in the UI.
*/
function logMessage(message, type = 'incoming', channel = 'websocketMessages') {
  log = document.getElementById(channel);

  const timestamp = new Date().toLocaleTimeString();
  const messageDiv = document.createElement('div');
  messageDiv.className = `websocket-message ${type}`;
  messageDiv.innerHTML = `<span class="timestamp">[${timestamp}]</span> ${message}`;

  log.appendChild(messageDiv);
  log.scrollTop = log.scrollHeight;
}
