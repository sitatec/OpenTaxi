package com.hamba.dispatcher.plugins

import io.ktor.routing.*
import io.ktor.application.*
import io.ktor.response.*

fun Application.configureRouting() {

    routing {
        get("/dispatch") {
                call.respondText("Hello World!")
            }

        route("driver_data") {
            post {

            }

            put {

            }

            delete {

            }
        }
    }
}
