package com.hamba.dispatcher.services.api

import com.google.cloud.tasks.v2.*
import com.google.protobuf.ByteString
import com.google.protobuf.Timestamp

private val DEFAULT_QUEUE_PROJECT_ID = "";
private val DEFAULT_QUEUE_LOCATION_ID = "";

fun scheduleTask(
    queueId: String,
    taskHandlerURL: String,
    taskPayload: String,
    taskExecutionTimestamps: List<Long>,
    queueProjectId: String = DEFAULT_QUEUE_PROJECT_ID,
    queueLocationId: String = DEFAULT_QUEUE_LOCATION_ID
) {
    val googleCloudTasksClient = CloudTasksClient.create()
    val queuePath = QueueName.of(queueProjectId, queueLocationId, queueId).toString()
    val httpRequest = HttpRequest.newBuilder()
        .setUrl(taskHandlerURL)
        .setHttpMethod(HttpMethod.POST)
        .setBody(ByteString.copyFromUtf8(taskPayload))
        .build()

    taskExecutionTimestamps.forEach { taskExecutionTimestamp ->
        val task = Task.newBuilder()
            .setScheduleTime(Timestamp.newBuilder().setSeconds(taskExecutionTimestamp))
            .setHttpRequest(httpRequest)
            .build()
        googleCloudTasksClient.createTask(queuePath, task)
    }
}