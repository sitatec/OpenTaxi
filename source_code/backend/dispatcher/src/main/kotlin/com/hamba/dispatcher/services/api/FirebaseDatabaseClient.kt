package com.hamba.dispatcher.services.api

import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

//TODO put all api keys and secret in local.properties
class FirebaseDatabaseClient(
    private val httpClient: HttpClient = HttpClient(CIO),
    private val baseUrl: String = "https://hamba-project-default-rtdb.firebaseio.com/"
) {
    suspend fun getData(queryBuilder: QueryBuilder): String {
        val url = baseUrl + queryBuilder.build()
        return withContext(Dispatchers.IO) {
            httpClient.get(url)
        }
    }

    suspend fun putData(queryBuilder: QueryBuilder, jsonData: String) {
        val url = baseUrl + queryBuilder.build()
        withContext(Dispatchers.IO) {
            httpClient.put<HttpResponse>(url){
                body = jsonData
            }
        }
    }

    suspend fun patchData(queryBuilder: QueryBuilder, jsonData: String) {
        val url = baseUrl + queryBuilder.build()
        withContext(Dispatchers.IO) {
            httpClient.patch<HttpResponse>(url){
                body = jsonData
            }
        }
    }

    suspend fun deleteData(queryBuilder: QueryBuilder) {
        val url = baseUrl + queryBuilder.build()
        withContext(Dispatchers.IO) {
            httpClient.delete<HttpResponse>(url)
        }
    }

    fun release() = httpClient.close()

    class QueryBuilder(private var path: String, timeout: String = "1s") {
        private var authSet = false

        init {
            path += ".json?timeout=$timeout&"
        }

        fun orderBy(child: String) = apply {
            path += "orderBy=$child&"
        }

        fun limitToFirst(n: Int) = apply {
            path += "limitToFirst=$n&"
        }

        fun limitToLast(n: Int) = apply {
            path += "limitToLast=$n&"
        }

        fun startAt(value: Number) = apply {
            path += "startAt=$value&"
        }

        fun startAt(value: String) = apply {
            path += "startAt=$value&"
        }

        fun endAt(value: Number) = apply {
            path += "endAt=$value&"
        }

        fun endAt(value: String) = apply {
            path += "endAt=$value&"
        }

        fun equalTo(value: Number) = apply {
            path += "equalTo=$value&"
        }

        fun equalTo(value: String) = apply {
            path += "equalTo=$value&"
        }

        fun auth(secret: String) = apply {
            path += "auth=$secret&"
            authSet = true
        }

        fun build(): String {
            if(!authSet){
                auth("TBgdTNbAZjCSEKkwFvVLTw0L75876p8fwaRWsLsZ")
            }
            return path.dropLast(1) // Remove the last "&" character.
        }

    }
}