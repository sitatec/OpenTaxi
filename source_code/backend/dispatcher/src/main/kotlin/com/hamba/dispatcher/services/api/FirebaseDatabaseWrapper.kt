package com.hamba.dispatcher.services.api

import com.google.firebase.FirebaseApp
import com.google.firebase.database.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.runBlocking
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class FirebaseDatabaseWrapper(val databaseReference: DatabaseReference = FirebaseDatabase.getInstance().reference) {

    init {
        FirebaseApp.initializeApp()
    }

    fun patchData(path: String, jsonData: Map<String, Any>) {
        databaseReference.child(path).updateChildrenAsync(jsonData)
    }

    fun putData(path: String, jsonData: String) {
        databaseReference.child(path).setValueAsync(jsonData)
    }

    fun deleteData(path: String) {
        databaseReference.child(path).removeValueAsync()
    }

    suspend inline fun <reified T> getData(path: String): T {
        return suspendCoroutine { continuation ->
            databaseReference.child(path).addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot?) {
                    snapshot?.let {
                        continuation.resume(it.getValue(T::class.java))
                    }
                }

                override fun onCancelled(error: DatabaseError?) {}
            })
        }
    }


    inline fun <reified T> onUpdate(path: String): Flow<T> {
        return flow {
            databaseReference.child(path).addValueEventListener(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot?) {
                    snapshot?.let {
                        // TODO find a solution to avoid blocking the thread with `runBlocking`
                        runBlocking(Dispatchers.IO) {
                            emit(snapshot.getValue(T::class.java))
                        }
                    }
                }

                override fun onCancelled(error: DatabaseError?) {}
            })
        }
    }

    inline fun <reified T> onChildAdd(path: String): Flow<Pair<String, T>> {
        return flow {
            databaseReference.child(path).addChildEventListener(object : ChildEventListener {
                override fun onChildAdded(snapshot: DataSnapshot?, previousChildName: String?) {
                    snapshot?.let {
                        // TODO find a solution to avoid blocking the thread with `runBlocking`
                        runBlocking {
                            emit(Pair(snapshot.key, snapshot.getValue(T::class.java)))
                        }
                    }
                }

                override fun onChildChanged(snapshot: DataSnapshot?, previousChildName: String?) {}

                override fun onChildRemoved(snapshot: DataSnapshot?) {}

                override fun onChildMoved(snapshot: DataSnapshot?, previousChildName: String?) {}

                override fun onCancelled(error: DatabaseError?) {}
            })
        }
    }

    fun onChildDeleted(path: String): Flow<String> {
        return flow {
            databaseReference.child(path).addChildEventListener(object : ChildEventListener {
                override fun onChildAdded(snapshot: DataSnapshot?, previousChildName: String?) {}

                override fun onChildChanged(snapshot: DataSnapshot?, previousChildName: String?) {}

                override fun onChildRemoved(snapshot: DataSnapshot?) {
                    snapshot?.let {
                        runBlocking {
                            emit(snapshot.key)
                        }
                    }
                }

                override fun onChildMoved(snapshot: DataSnapshot?, previousChildName: String?) {}

                override fun onCancelled(error: DatabaseError?) {}
            })
        }
    }

    fun onChildUpdated(path: String, vararg childrenNames: String): Flow<Map<String, String>> {
        return flow {
            databaseReference.child(path).addChildEventListener(object : ChildEventListener {
                override fun onChildAdded(snapshot: DataSnapshot?, previousChildName: String?) {}

                override fun onChildChanged(snapshot: DataSnapshot?, previousChildName: String?) {
                    snapshot?.let {
                        val result = mutableMapOf<String, String>()
                        for (key in childrenNames.asList()) {
                            result[key] = snapshot.child(key).getValue(String::class.java)
                        }
                        runBlocking {
                            emit(result)
                        }
                    }
                }

                override fun onChildRemoved(snapshot: DataSnapshot?) {}

                override fun onChildMoved(snapshot: DataSnapshot?, previousChildName: String?) {}

                override fun onCancelled(error: DatabaseError?) {}
            })
        }
    }
}

