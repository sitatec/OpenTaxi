package com.hamba.dispatcher.services.sdk

import com.google.cloud.firestore.Firestore
import com.google.firebase.cloud.FirestoreClient
import kotlinx.coroutines.delay
import java.util.concurrent.Future


class FirebaseFirestoreWrapper(val firestoreClient: Firestore = FirestoreClient.getFirestore()) {
    // TODO implement error handling

    fun patchData(path: String, jsonData: Map<String, Any>) {
        firestoreClient.document(path).update(jsonData)
    }

    fun putData(path: String, jsonData: Any) {
        firestoreClient.document(path).set(jsonData)
    }

    fun deleteData(path: String) {
        firestoreClient.document(path).delete()
    }

    suspend inline fun <reified T> getData(path: String): T? {
        val futureResponse = firestoreClient.document(path).get()
        return futureResponse.await()?.toObject(T::class.java)
    }

    suspend fun getCollection(path: String): List<Map<String, Any>>? {
        val futureResponse = firestoreClient.collection(path).get()
        return futureResponse.await()?.documents?.map {
            (it.toObject(Any::class.java) as MutableMap<String, Any>).apply {
                this["id"] = it.id
            }
        }
    }

    suspend inline fun <reified T> Future<T>.await(timeoutMs: Int = 30_000/* 30s timeout in case it a huge data*/): T? {
        val start = System.currentTimeMillis()
        while (!isDone) {
            if (System.currentTimeMillis() - start > timeoutMs) {
                return null
            }
            delay(1)
        }
        return get()
    }
}


