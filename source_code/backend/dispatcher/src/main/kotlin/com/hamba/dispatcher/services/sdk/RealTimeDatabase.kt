package com.hamba.dispatcher.services.sdk

import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase

class FirebaseDatabaseWrapper(private val firebaseDatabase: DatabaseReference = FirebaseDatabase.getInstance().reference){

    fun putData(path: String, data: Map<String, Any>){
        firebaseDatabase.child(path).setValueAsync(data)
    }

    fun deleteData(path: String){
        firebaseDatabase.child(path).removeValueAsync()
    }
}