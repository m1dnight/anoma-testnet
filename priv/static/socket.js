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
        this.channels.forEach(channel => channel.rejoin());
    }

    onConnClose() {
        this.channels.forEach(channel => channel.onClose());
    }

    onConnMessage(event) {
        console.log("onConnMessage", event.data);
        const msg = JSON.parse(event.data);
        this.channels.forEach(channel => {
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
        this.sendBuffer.forEach(msg => this.ws.send(JSON.stringify(msg)));
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

    join(jwt) {
        this.joinRef = this.socket.makeRef();
        const msg = {
            topic: this.topic,
            event: "phx_join",
            payload: {jwt: jwt},
            ref: this.joinRef
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
            ref: this.socket.makeRef()
        };
        this.socket.push(msg);
    }

    onMessage(msg) {
        if (this.bindings[msg.event]) {
            this.bindings[msg.event].forEach(callback => callback(msg.payload));
        }
    }

    onClose() {
        // Handle channel close
    }
}