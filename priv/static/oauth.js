/*
Helper function to encode a buffer to url encoding.
*/
function base64URLEncode(buffer) {
    return btoa(String.fromCharCode(...buffer))
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}

/*
Generate a code verified for the X OAuth 2.0 flow.
*/
function generateCodeVerifier() {
    const array = new Uint8Array(32);
    crypto.getRandomValues(array);
    return base64URLEncode(array);
}

/*
Generate a code challenge for the X OAuth 2.0 flow.
*/
async function generateCodeChallenge(verifier) {
    const encoder = new TextEncoder();
    const data = encoder.encode(verifier);
    const hash = await crypto.subtle.digest('SHA-256', data);
    return base64URLEncode(new Uint8Array(hash));
}

async function exchangeCodeForToken(code, codeVerifier) {
    const response = await fetch(`${CONFIG.backendUrl}/api/user/code`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code: code, code_verifier: codeVerifier })
    });
}