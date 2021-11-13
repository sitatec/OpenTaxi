package com.hamba.dispatcher.services.sdk

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import java.io.FileInputStream


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