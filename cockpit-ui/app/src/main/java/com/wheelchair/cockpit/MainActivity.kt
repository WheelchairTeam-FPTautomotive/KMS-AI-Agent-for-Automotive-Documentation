package com.wheelchair.cockpit

import android.os.Bundle
import android.car.VehiclePropertyIds
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.wheelchair.cockpit.api.CitationInfo
import com.wheelchair.cockpit.api.CopilotClient
import com.wheelchair.cockpit.api.QueryRequest
import java.util.UUID
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var carPropertyHelper: CarPropertyHelper
    // --- START MODIFICATION ---
    private var sessionId: String = UUID.randomUUID().toString()
    private var sessionTtlMin: Int = 5
    private var pausedAtMs: Long = 0L
    // --- END MODIFICATION ---

    override fun onPause() {
        super.onPause()
        pausedAtMs = System.currentTimeMillis()
    }

    override fun onResume() {
        super.onResume()
        if (pausedAtMs > 0L && sessionTtlMin > 0) {
            val idleMs = System.currentTimeMillis() - pausedAtMs
            if (idleMs > sessionTtlMin * 60_000L) {
                sessionId = UUID.randomUUID().toString()
            }
        }
        pausedAtMs = 0L
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            var vehicleSpeed by remember { mutableStateOf(0.0f) }
            var isHvacOn by remember { mutableStateOf(false) }
            var queryInput by remember { mutableStateOf("") }
            var copilotAnswer by remember { mutableStateOf("") }
            var citations by remember { mutableStateOf<List<CitationInfo>>(emptyList()) }
            var isRecording by remember { mutableStateOf(false) }
            var isLoading by remember { mutableStateOf(false) }
            var ttlMin by remember { mutableStateOf(sessionTtlMin) }
            var stmTurns by remember { mutableStateOf(0) }
            val coroutineScope = rememberCoroutineScope()

            fun syncTtl(v: Int) {
                ttlMin = v
                sessionTtlMin = v
                if (v == 0) {
                    sessionId = UUID.randomUUID().toString()
                    stmTurns = 0
                }
            }

            fun newChat() {
                sessionId = UUID.randomUUID().toString()
                stmTurns = 0
                copilotAnswer = ""
                citations = emptyList()
            }

            // Initialize VHAL signal listener
            DisposableEffect(Unit) {
                carPropertyHelper = CarPropertyHelper(this@MainActivity) { propId, value ->
                    when (propId) {
                        VehiclePropertyIds.PERF_VEHICLE_SPEED -> {
                            // Value is usually Float in m/s or km/h, convert as needed
                            vehicleSpeed = (value as? Float) ?: 0.0f
                        }
                        VehiclePropertyIds.HVAC_AC_ON -> {
                            isHvacOn = (value as? Boolean) ?: false
                        }
                    }
                }
                onDispose {
                    carPropertyHelper.shutdown()
                }
            }

            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color(0xFF0F172A) // Sleek dark surface background
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(24.dp)
                ) {
                    // Header Bar
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Copilot Cockpit UI",
                            fontSize = 24.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF38BDF8)
                        )
                        // --- START MODIFICATION ---
                        TextButton(onClick = { newChat() }) {
                            Text("New chat", color = Color(0xFF94A3B8), fontSize = 14.sp)
                        }
                        // --- END MODIFICATION ---
                        
                        // Status Panel displaying VHAL metrics
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Vận tốc: ${"%.1f".format(vehicleSpeed)} km/h",
                                color = if (vehicleSpeed > 80f) Color(0xFFFB7185) else Color(0xFF34D399),
                                fontWeight = FontWeight.SemiBold
                            )
                            Button(
                                onClick = { 
                                    carPropertyHelper.setHvacState(0, !isHvacOn)
                                },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = if (isHvacOn) Color(0xFF10B981) else Color(0xFF475569)
                                )
                            ) {
                                Text(if (isHvacOn) "HVAC: ON" else "HVAC: OFF", color = Color.White)
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // Alert Panel for High Speed Warning
                    if (vehicleSpeed > 80f) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(Color(0xFF881337), RoundedCornerShape(8.dp))
                                .padding(12.dp)
                        ) {
                            Text(
                                text = "⚠️ CẢNH BÁO: Tốc độ xe vượt quá 80km/h. Hạn chế sử dụng màn hình trung tâm để bảo đảm an toàn.",
                                color = Color.White,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        Spacer(modifier = Modifier.height(16.dp))
                    }

                    // Answer Content Area
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxWidth()
                            .background(Color(0xFF1E293B), RoundedCornerShape(12.dp))
                            .padding(16.dp)
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                modifier = Modifier.align(Alignment.Center),
                                color = Color(0xFF38BDF8)
                            )
                        } else {
                            LazyColumn(modifier = Modifier.fillMaxSize()) {
                                item {
                                    Text(
                                        text = if (copilotAnswer.isEmpty()) "Nhấn vào nút Micro để nói hoặc nhập câu hỏi bên dưới." else "Trợ lý ảo phản hồi:",
                                        fontSize = 14.sp,
                                        color = Color(0xFF94A3B8)
                                    )
                                    Spacer(modifier = Modifier.height(8.dp))
                                    Text(
                                        text = copilotAnswer,
                                        fontSize = 18.sp,
                                        color = Color.White,
                                        lineHeight = 26.sp
                                    )
                                    Spacer(modifier = Modifier.height(20.dp))
                                }
                                
                                if (citations.isNotEmpty()) {
                                    item {
                                        Text(
                                            text = "Nguồn trích dẫn nguồn gốc (Traceability):",
                                            fontSize = 14.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color(0xFFF59E0B)
                                        )
                                        Spacer(modifier = Modifier.height(8.dp))
                                    }
                                    items(citations) { citation ->
                                        Card(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .padding(vertical = 4.dp),
                                            colors = CardDefaults.cardColors(containerColor = Color(0xFF334155))
                                        ) {
                                            Column(modifier = Modifier.padding(12.dp)) {
                                                Text(
                                                    text = "${citation.document_name} • Trang ${citation.page} (${citation.section})",
                                                    fontSize = 12.sp,
                                                    fontWeight = FontWeight.Bold,
                                                    color = Color(0xFF38BDF8)
                                                )
                                                Spacer(modifier = Modifier.height(4.dp))
                                                Text(
                                                    text = "\"${citation.matched_text}\"",
                                                    fontSize = 13.sp,
                                                    color = Color(0xFFCBD5E1)
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // --- START MODIFICATION ---
                    // STM idle TTL: Off / 3 / 5 / 10 minutes
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("STM", color = Color(0xFF94A3B8), fontSize = 13.sp)
                        listOf(0, 3, 5, 10).forEach { opt ->
                            val selected = ttlMin == opt
                            Button(
                                onClick = { syncTtl(opt) },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = if (selected) Color(0xFF38BDF8) else Color(0xFF1E293B)
                                ),
                                contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                                modifier = Modifier.height(36.dp)
                            ) {
                                Text(
                                    text = if (opt == 0) "Off" else "${opt}m",
                                    color = if (selected) Color(0xFF0F172A) else Color(0xFFE2E8F0),
                                    fontSize = 12.sp
                                )
                            }
                        }
                        Text(
                            text = "turns=$stmTurns",
                            color = Color(0xFF64748B),
                            fontSize = 12.sp
                        )
                    }
                    Spacer(modifier = Modifier.height(12.dp))
                    // --- END MODIFICATION ---

                    // Input Controls Panel
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        // Text Input
                        TextField(
                            value = queryInput,
                            onValueChange = { queryInput = it },
                            placeholder = { Text("Nhập câu hỏi tra cứu...") },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(8.dp),
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = Color(0xFF1E293B),
                                unfocusedContainerColor = Color(0xFF1E293B),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White
                            )
                        )

                        // Send Button
                        Button(
                            onClick = {
                                if (queryInput.isNotEmpty()) {
                                    isLoading = true
                                    coroutineScope.launch {
                                        try {
                                            val response = CopilotClient.service.queryCopilot(
                                                QueryRequest(
                                                    query = queryInput,
                                                    language = "vi",
                                                    session_id = sessionId,
                                                    session_ttl_min = ttlMin,
                                                )
                                            )
                                            copilotAnswer = response.answer
                                            citations = response.citations
                                            response.session_id?.let { sessionId = it }
                                            stmTurns = response.stm_turns ?: stmTurns
                                        } catch (e: Exception) {
                                            copilotAnswer = "Lỗi kết nối đến Backend: ${e.message}"
                                            citations = emptyList()
                                        } finally {
                                            isLoading = false
                                        }
                                    }
                                }
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF38BDF8)),
                            modifier = Modifier.height(56.dp)
                        ) {
                            Text("Gửi", color = Color(0xFF0F172A), fontWeight = FontWeight.Bold)
                        }

                        // Voice Trigger Button
                        Button(
                            onClick = {
                                isRecording = !isRecording
                                if (isRecording) {
                                    copilotAnswer = "Đang lắng nghe..."
                                    citations = emptyList()
                                } else {
                                    // Trigger mocked speech RAG query
                                    isLoading = true
                                    coroutineScope.launch {
                                        try {
                                            val response = CopilotClient.service.queryCopilot(
                                                QueryRequest(
                                                    query = "Làm cách nào để bật hệ thống điều hòa HVAC trên buồng lái?",
                                                    language = "vi",
                                                    session_id = sessionId,
                                                    session_ttl_min = ttlMin,
                                                )
                                            )
                                            copilotAnswer = response.answer
                                            citations = response.citations
                                            response.session_id?.let { sessionId = it }
                                            stmTurns = response.stm_turns ?: stmTurns
                                        } catch (e: Exception) {
                                            copilotAnswer = "Lỗi xử lý câu nói: ${e.message}"
                                        } finally {
                                            isLoading = false
                                        }
                                    }
                                }
                            },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (isRecording) Color(0xFFEF4444) else Color(0xFFF59E0B)
                            ),
                            modifier = Modifier.height(56.dp)
                        ) {
                            Text(
                                text = if (isRecording) "Stop" else "Nói",
                                color = Color.White,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }
        }
    }
}
