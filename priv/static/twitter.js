// Phoenix Socket - Simple implementation
class Socket {
  constructor(endPoint) {
    this.endPoint = endPoint;
    this.ws = null;
    this.channels = [];
    this.sendBuffer = [];
    this.ref = 0;
  }

  connect() {
    this.ws = new WebSocket(this.endPoint);
    this.ws.onopen = () => this.onConnOpen();
    this.ws.onclose = () => this.onConnClose();
    this.ws.onmessage = (event) => this.onConnMessage(event);
    this.ws.onerror = (error) => this.onConnError(error);
  }

  onConnOpen() {
    this.flushSendBuffer();
    this.channels.forEach((channel) => channel.rejoin());
  }

  onConnClose() {
    this.channels.forEach((channel) => channel.onClose());
  }

  onConnMessage(event) {
    const msg = JSON.parse(event.data);
    this.channels.forEach((channel) => {
      if (channel.topic === msg.topic) {
        channel.onMessage(msg);
      }
    });
  }

  onConnError(error) {
    console.error('WebSocket error:', error);
  }

  channel(topic) {
    const channel = new Channel(topic, this);
    this.channels.push(channel);
    return channel;
  }

  push(msg) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(msg));
    } else {
      this.sendBuffer.push(msg);
    }
  }

  flushSendBuffer() {
    this.sendBuffer.forEach((msg) => this.ws.send(JSON.stringify(msg)));
    this.sendBuffer = [];
  }

  makeRef() {
    return ++this.ref;
  }
}

class Channel {
  constructor(topic, socket) {
    this.topic = topic;
    this.socket = socket;
    this.bindings = {};
    this.joinRef = null;
  }

  join() {
    this.joinRef = this.socket.makeRef();
    const msg = {
      topic: this.topic,
      event: 'phx_join',
      payload: {},
      ref: this.joinRef,
    };
    this.socket.push(msg);
    return this;
  }

  rejoin() {
    if (this.joinRef) {
      this.join();
    }
  }

  on(event, callback) {
    if (!this.bindings[event]) {
      this.bindings[event] = [];
    }
    this.bindings[event].push(callback);
  }

  push(event, payload) {
    const msg = {
      topic: this.topic,
      event: event,
      payload: payload,
      ref: this.socket.makeRef(),
    };
    this.socket.push(msg);
  }

  onMessage(msg) {
    if (this.bindings[msg.event]) {
      this.bindings[msg.event].forEach((callback) => callback(msg.payload));
    }
  }

  onClose() {
    // Handle channel close
  }
}

// Configuration - X (Twitter) OAuth version
const CONFIG = {
  twitterClientId: 'RG5ZOVoydWJlZ3FOSnVTa1dDTnA6MTpjaQ', // X OAuth 2.0 Client ID
  backendUrl: 'http://localhost:4000',
  redirectUri: 'http://localhost:4000/index.html', // Exact match with backend
  websocketUrl: 'ws://localhost:4000/socket/websocket',
};

// DOM elements
const dashboard = document.getElementById('dashboard');
const loginBtn = document.getElementById('loginBtn');
const logoutBtn = document.getElementById('logoutBtn');
const userAvatar = document.getElementById('userAvatar');
const userName = document.getElementById('userName');
const userLogin = document.getElementById('userLogin');
const pointsDisplay = document.getElementById('pointsDisplay');
const pointsInput = document.getElementById('pointsInput');
const addPointsBtn = document.getElementById('addPointsBtn');
const loading = document.getElementById('loading');
const message = document.getElementById('message');
const websocketMessages = document.getElementById('websocketMessages');
const websocketMessages = document.getElementById('websocketMessages');

// State
let currentUser = null;
let authToken = null;
let socket = null;
let channel = null;

// Functions
function showLogin() {
  loginSection.style.display = 'block';
  dashboard.style.display = 'none';
}

function showDashboard() {
  loginSection.style.display = 'none';
  dashboard.style.display = 'block';
}

function showLoading(show) {
  loading.style.display = show ? 'block' : 'none';
}

function showMessage(text, type = 'info') {
  message.innerHTML = `<div class="${type}">${text}</div>`;
  setTimeout(() => {
    message.innerHTML = '';
  }, 5000);
}

async function initiateXLogin() {
  // X OAuth 2.0 with PKCE
  const codeVerifier = generateCodeVerifier();
  const codeChallenge = await generateCodeChallenge(codeVerifier);

  // Store code verifier for later use
  localStorage.setItem('twitter_code_verifier', codeVerifier);

  console.log('Code Challenge:', codeChallenge);
  const twitterUrl =
    `https://twitter.com/i/oauth2/authorize?` +
    `response_type=code&` +
    `client_id=${CONFIG.twitterClientId}&` +
    `redirect_uri=${encodeURIComponent(CONFIG.redirectUri)}&` +
    `scope=tweet.read%20users.read%20follows.read&` +
    `state=state&` +
    `code_challenge=${codeChallenge}&` +
    `code_challenge_method=S256`;

  window.location.href = twitterUrl;
}

// Helper functions for PKCE (required by X OAuth 2.0)
function generateCodeVerifier() {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return base64URLEncode(array);
}

async function generateCodeChallenge(verifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(verifier);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return base64URLEncode(new Uint8Array(hash));
}

function base64URLEncode(buffer) {
  return btoa(String.fromCharCode(...buffer))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

async function handleXCallback(code) {
  showLoading(true);

  try {
    const response = await fetch(`${CONFIG.backendUrl}/auth/twitter`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ code: code }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();

    console.log(data, 'data');
    if (data.token && data.user) {
      authToken = data.token;
      currentUser = data.user;

      // Store token for future sessions
      console.log(authToken, 'auth token');
      localStorage.setItem('authToken', authToken);

      // Clear URL parameters
      window.history.replaceState({}, document.title, window.location.pathname);

      updateUserInterface();
      loadUserProfile();
      showMessage('Successfully logged in on X!', 'success');
    } else {
      throw new Error('Invalid response from server');
    }
  } catch (error) {
    console.error('Login error:', error);
    showMessage('Login failed. Please try again.', 'error');
    showLogin();
  } finally {
    showLoading(false);
  }
}

async function loadUserProfile() {
  showLoading(true);

  try {
    const response = await fetch(`${CONFIG.backendUrl}/api/v1/user/profile`, {
      headers: {
        Authorization: `Bearer ${authToken}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      if (response.status === 401) {
        // Token expired or invalid
        logout();
        return;
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const userData = await response.json();
    currentUser = userData;
    updateUserInterface();
    showDashboard();
  } catch (error) {
    console.error('Profile load error:', error);
    showMessage('Failed to load profile. Please try logging in again.', 'error');
    logout();
  } finally {
    showLoading(false);
  }
}

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

function updateUserInterface() {
  const userProfileJson = document.getElementById('userProfileJson');
  console.log(currentUser, 'current user');
  if (userProfileJson && currentUser) {
    userProfileJson.innerHTML = syntaxHighlight(currentUser);
  }
}

function logout() {
  authToken = null;
  currentUser = null;
  localStorage.removeItem('authToken');
  disconnectWebSocket();
  showLogin();
  showMessage('Logged out successfully', 'success');
}

// WebSocket functions
function connectWebSocket() {
  if (currentUser) {
    try {
      displayWebSocketMessage('Attempting to connect...', 'outgoing');

      // Create Phoenix Socket connection
      socket = new Socket(CONFIG.websocketUrl);

      // Set up WebSocket event handlers before connecting
      socket.ws = new WebSocket(CONFIG.websocketUrl);

      socket.ws.onopen = function (event) {
        console.log('WebSocket connected');
        displayWebSocketMessage('Connected to WebSocket', 'incoming');

        console.log('current user', currentUser);
        // Join echo channel
        console.log('joining echo channel', `echo:${currentUser.user.id}`);
        channel = socket.channel(`echo:${currentUser.user.id}`);

        // Set up channel event handlers
        channel.on('echo', function (payload) {
          displayWebSocketMessage('Received echo: ' + JSON.stringify(payload), 'incoming');
          handleWebSocketMessage(payload);
        });

        channel.on('update', function (payload) {
          console.log('user updated');
          console.log(payload.user_data, 'points');
          currentUser = payload.user_data;
          updateUserInterface();
          // displayWebSocketMessage('Received echo: ' + JSON.stringify(payload), 'incoming');
          // handleWebSocketMessage(payload);
        });

        channel.on('auth_success', function (payload) {
          displayWebSocketMessage('Authentication success: ' + JSON.stringify(payload), 'incoming');
          handleAuthSuccess(payload);
        });

        channel.on('auth_error', function (payload) {
          displayWebSocketMessage('Authentication error: ' + JSON.stringify(payload), 'error');
          showMessage('Authentication failed: ' + payload.message, 'error');
          showLogin();
        });

        channel.on('phx_reply', function (payload) {
          displayWebSocketMessage('Channel joined: ' + JSON.stringify(payload), 'incoming');
        });

        // Join the channel
        channel.join();
        displayWebSocketMessage('Joining echo:lobby channel', 'outgoing');
      };

      socket.ws.onerror = function (error) {
        console.error('WebSocket error:', error);
        displayWebSocketMessage('WebSocket error: ' + error, 'error');
      };

      socket.ws.onclose = function (event) {
        console.log('WebSocket disconnected');
        displayWebSocketMessage('WebSocket disconnected', 'error');
        socket = null;
        channel = null;
      };

      socket.ws.onmessage = function (event) {
        displayWebSocketMessage('Raw message: ' + event.data, 'incoming');
        socket.onConnMessage(event);
      };
    } catch (error) {
      console.error('WebSocket connection error:', error);
      displayWebSocketMessage('Connection error: ' + error.message, 'error');
    }
  } else {
    console.log('current user is null, not connecting to websocket');
  }
}

function disconnectWebSocket() {
  if (socket && socket.ws) {
    socket.ws.close();
    socket = null;
    channel = null;
  }
}

function handleWebSocketMessage(data) {
  switch (data.type) {
    case 'points_update':
      if (currentUser && data.points !== undefined) {
        currentUser.points = data.points;
        pointsDisplay.textContent = data.points;
      }
      break;
    default:
      console.log('Unknown WebSocket message:', data);
  }
}

function displayWebSocketMessage(message, type = 'incoming') {
  const timestamp = new Date().toLocaleTimeString();
  const messageDiv = document.createElement('div');
  messageDiv.className = `websocket-message ${type}`;
  messageDiv.innerHTML = `<span class="timestamp">[${timestamp}]</span> ${message}`;

  websocketMessages.appendChild(messageDiv);
  websocketMessages.scrollTop = websocketMessages.scrollHeight;
}

function clearMessages() {
  console.log('clearing messages');
  if (websocketMessages) {
    websocketMessages.innerHTML = '';
    // Add a visible confirmation message
    const clearedDiv = document.createElement('div');
    clearedDiv.className = 'websocket-message info';
    clearedDiv.textContent = 'Messages cleared!';
    websocketMessages.appendChild(clearedDiv);
  } else {
    console.warn('websocketMessages element not found!');
  }
}

function handleAuthSuccess(payload) {
  console.log(payload, 'payload');
  // Store user data and token
  if (payload.token) {
    authToken = payload.token;
    localStorage.setItem('authToken', authToken);
    console.log(authToken, 'auth token');
  }

  console.log(payload.user, 'current user');
  if (payload.user) {
    currentUser = payload.user;
    updateUserInterface();
    showDashboard();
    showMessage('Successfully authenticated via WebSocket!', 'success');
  }
}

// Initialize app
document.addEventListener('DOMContentLoaded', async function () {
  console.log(localStorage.getItem('authToken'), 'access token here');

  //----------------------------------------------------------------------------
  // Connect to the websocket

  // Check if returning from GitHub OAuth
  const urlParams = new URLSearchParams(window.location.search);
  const code = urlParams.get('code');

  //----------------------------------------------------------------------------
  // Check if this page is a result of the auth callback,
  //
  // If this is a callback, take the code. If this is not a callback, see if
  // there is a token in local storage and fetch the profile.

  if (code) {
    // there is a code query parameter in the url, so X redirected the user here.
    // Call the new API endpoint with code and code_verifier
    const codeVerifier = localStorage.getItem('twitter_code_verifier');
    // const codeVerifier = "OcqXmf5yZdvumC_1hqXusuFKU5kjncXMsq5L0CqJIkE";
    if (!codeVerifier) {
      showMessage('Missing code verifier. Please try logging in again.', 'error');
      showLogin();
    } else {
      showLoading(true);
      try {
        const response = await fetch(`${CONFIG.backendUrl}/api/user/code`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ code: code, code_verifier: codeVerifier }),
        });
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        if (data.success && data.token && data.user) {
          authToken = data.token;
          currentUser = data.user;
          localStorage.setItem('authToken', authToken);
          window.history.replaceState({}, document.title, window.location.pathname);
          updateUserInterface();
          showDashboard();
          showMessage('Successfully logged in on X!', 'success');
          connectWebSocket();
        } else {
          throw new Error('Invalid response from server');
        }
      } catch (error) {
        console.error('Login error:', error);
        showMessage('Login failed. Please try again.', 'error');
        showLogin();
      } finally {
        showLoading(false);
      }
    }
  } else {
    // there was no query parameter, so this is a first page load.
    // check if there is a token in local storage.
    //
    // if there is a token in storage, use that to fetch the profile.
    //
    // if there is no token in storage, show login buttons.
    const storedToken = localStorage.getItem('authToken');
    if (storedToken) {
      authToken = storedToken;
      await loadUserProfile();
      console.log('current user', currentUser);
      // Connect WebSocket
      connectWebSocket();
    } else {
      showLogin();
    }
  }

  //----------------------------------------------------------------------------
  // Add the callback for the add point button.

  const addOnePointBtn = document.getElementById('addOnePointBtn');
  if (addOnePointBtn) {
    addOnePointBtn.addEventListener('click', async function () {
      console.log('add one point btn clicked');
      if (!authToken) {
        showMessage('You must be logged in to add points.', 'error');
        return;
      }
      showLoading(true);
      try {
        const response = await fetch(`${CONFIG.backendUrl}/api/v1/user/points`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${authToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ points: 1 }),
        });
        if (!response.ok) {
          if (response.status === 401) {
            logout();
            return;
          }
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        // Update local points display
        if (currentUser) {
          currentUser.points = (currentUser.points || 0) + 1;
          if (pointsDisplay) pointsDisplay.textContent = currentUser.points;
        }
        showMessage('Successfully added 1 point!', 'success');
      } catch (error) {
        console.error('Add 1 point error:', error);
        showMessage('Failed to add 1 point. Please try again.', 'error');
      } finally {
        showLoading(false);
      }
    });
  }

  //----------------------------------------------------------------------------
  // Add the callback to refresh the json for the profile.

  const refreshProfileBtn = document.getElementById('refreshProfileBtn');
  if (refreshProfileBtn) {
    refreshProfileBtn.addEventListener('click', function () {
      if (!authToken) {
        showMessage('You must be logged in to refresh profile.', 'error');
        return;
      }
      loadUserProfile();
    });
  }

  // Event listeners
  loginBtn.addEventListener('click', initiateXLogin);
  logoutBtn.addEventListener('click', logout);

  // Connect Ethereum Wallet button logic
  const connectWalletBtn = document.getElementById('connectWalletBtn');
  if (connectWalletBtn) {
    connectWalletBtn.addEventListener('click', async function () {
      if (!window.ethereum) {
        showMessage('MetaMask is not installed!', 'error');
        return;
      }
      try {
        // Request account access
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const publicAddress = accounts[0];
        // Send the public address to the backend
        await fetch('/api/v1/user/ethereum-address', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${authToken}`,
          },
          body: JSON.stringify({ address: publicAddress }),
        });
        showMessage('Ethereum address sent to backend: ' + publicAddress, 'success');
      } catch (error) {
        showMessage('Error connecting wallet: ' + error.message, 'error');
      }
    });
  }

  const clearMessagesBtn = document.getElementById('clearMessagesBtn');
  if (clearMessagesBtn) {
    console.log('clear messages btn found');
    clearMessagesBtn.addEventListener('click', clearMessages);
  }
});
