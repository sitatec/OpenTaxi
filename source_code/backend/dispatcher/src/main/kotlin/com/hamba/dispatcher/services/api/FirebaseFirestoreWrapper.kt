package com.hamba.dispatcher.services.api

import com.google.auth.oauth2.GoogleCredentials
import com.google.cloud.firestore.DocumentReference
import com.google.cloud.firestore.DocumentSnapshot
import com.google.cloud.firestore.Firestore
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.cloud.FirestoreClient
import com.google.firebase.database.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.future.await
import kotlinx.coroutines.runBlocking
import java.io.FileInputStream
import java.util.concurrent.CompletionStage
import java.util.concurrent.Future
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine


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

    suspend inline fun <reified T> Future<T>.await(timeoutMs: Int = 60_000): T? {
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

fun initializeFirebase(
    secretsPath: String = "",
    projectId: String = "hamba-project",
    databaseUrl: String = "https://hamba-project-default-rtdb.firebaseio.com/"
) {
    val firebaseOptions = FirebaseOptions.builder().setDatabaseUrl(databaseUrl).setProjectId(projectId)
    if (secretsPath.isNotBlank()) {
        val refreshToken = FileInputStream(secretsPath)
        firebaseOptions.setCredentials(GoogleCredentials.fromStream(refreshToken))
    }
    FirebaseApp.initializeApp(firebaseOptions.build())
}

