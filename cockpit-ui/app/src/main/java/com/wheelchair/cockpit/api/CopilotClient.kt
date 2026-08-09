package com.wheelchair.cockpit.api

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST

interface CopilotService {
    @POST("api/v1/copilot/query")
    suspend fun queryCopilot(
        @Body request: QueryRequest,
        @Header("X-Session-Reset") sessionReset: String? = null,
    ): QueryResponse
}

// --- START MODIFICATION ---
data class QueryRequest(
    val query: String,
    val language: String = "vi",
    val session_id: String? = null,
    val session_ttl_min: Int? = 5,
)
// --- END MODIFICATION ---

data class CitationInfo(
    val document_id: String,
    val document_name: String,
    val section: String,
    val page: Int,
    val matched_text: String
)

data class QueryResponse(
    val query: String,
    val answer: String,
    val citations: List<CitationInfo>,
    val status: String,
    val session_id: String? = null,
    val session_active: Boolean? = null,
    val stm_turns: Int? = null,
)

object CopilotClient {
    // Port 8000 mapped from local RAG backend.
    // In Android Emulator, 10.0.2.2 points to host's localhost loopback.
    private const val BASE_URL = "http://10.0.2.2:8000/"

    val service: CopilotService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(CopilotService::class.java)
    }
}
