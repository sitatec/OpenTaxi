package com.hamba.dispatcher.websockets

import io.ktor.http.cio.websocket.*

class Connection(val id: String, val session: DefaultWebSocketSession)