package com.hamba.dispatcher

import com.hamba.dispatcher.websockets.webSocketsServer
import io.ktor.server.engine.*
import io.ktor.server.netty.*

fun main() {
    embeddedServer(Netty, port = 8080, host = "localhost") {
        webSocketsServer()
    }.start(wait = true)
}
