# 🧠 AI AWS Architecture & Scaling Strategy (MCP vs Multi-Agent)

This document presents the detailed architectural specifications, comparative analysis, and scaling roadmaps for both **Option 1 (Multi-Agent)** and **Option 2 (Agent with MCP)** under a **$456 USD quota** and strict **low-latency requirements**.

---

## 📌 Comparative Overview

| Metric / Criteria | Option 1: Multi-Agent System | Option 2: Agent with MCP Tools (Recommended) |
| :--- | :--- | :--- |
| **AWS Token Cost** | **High** (Multiple sequential LLM reasoning calls per query, fast quota drainage). | **Very Low** (Single LLM invocation per request using Claude 3.5 Haiku). |
| **Response Latency** | **Slow** (2x LLM API roundtrips result in $> 1.5$ seconds latency). | **Fast** (Single LLM call executes under $300\text{ ms}$). |
| **Architectural Complexity** | **High** (Requires orchestrating agent-to-agent states, handoffs, and memory). | **Low** (Single controller orchestrating tasks via JSON schema function calling). |
| **Ecosystem Alignment** | Standard microservices flow. | **L3 Grade (Max Points)**. Matches FPT regulations page 9 requiring callable **MCP tools**. |
| **Production Realism** | High compute overhead per car. | **Lightweight & Scalable** (Zero-state agent consuming vehicle APIs). |

---

## 📂 Option 1: Multi-Agent System (RAG Agent + Speech Formatting Agent)

In this setup, responsibilities are split between two distinct, decoupled agents running in series.

### A. Architectural Blueprint & Data Flow
```
[ Driver Voice Query ]
       │ (1) Audio stream
       ▼
[ Amazon Transcribe (STT) ]
       │ (2) Text query
       ▼
┌────────────────────────────────────────────────────────┐
│ [ Agent A: RAG & Manual Specialist ]                   │
│ - Analyzes text query.                                 │
│ - Calls Retriever to query vector database.            │
│ - Formulates technical answer with citations.          │
└────────────────────────┬───────────────────────────────┘
                         │ (3) Raw text answer + citations
                         ▼
┌────────────────────────────────────────────────────────┐
│ [ Agent B: Speech Formatting & Safety Agent ]          │
│ - Strip citations (e.g. [1]) for voice synthesis.     │
│ - Check VHAL Speed to block physical car executions.   │
│ - Formats text strictly for natural TTS generation.    │
└────────────────────────┬───────────────────────────────┘
                         │ (4) Formatted voice script
                         ▼
[ Amazon Polly (TTS) ]
       │ (5) Audio response.mp3
       ▼
[ Cockpit HUD / Speakers ]
```

### B. Feasibility Analysis & Quota Math
* **Token Overhead**: If a query consumes 1,000 input tokens and generates 300 output tokens:
  * **Agent A**: 1,000 input + 300 output.
  * **Agent B**: 1,300 input (Agent A output + instructions) + 150 output.
  * **Total**: 2,300 input tokens + 450 output tokens per query.
* **Latency Overhead**: Calling Agent A takes ~600ms. Forwarding the result to Agent B takes another ~450ms. Total latency: **~1050ms** (fails the mentor's $<1.0\text{s}$ target for voice responses).

---

## 📂 Option 2: Single Agent with MCP Tools (RECOMMENDED)

In this setup, a single LLM (Claude 3.5 Haiku) acts as the central brain, invoking specialized vehicle and database tools directly via the **Model Context Protocol (MCP)**.

### A. Architectural Blueprint & Data Flow
```
[ Driver Voice Query ] ──► [ Amazon Transcribe (STT) ] ──► [ KMS AI Agent (Haiku) ]
                                                                 │
                                                   ┌─────────────┼─────────────┐
                                                   │ (Call Tool) │ (Call Tool) │ (Call Tool)
                                                   ▼             ▼             ▼
                                            [ search_manual ] [ get_speed ] [ set_hvac ]
                                                   │             │             │
                                                   ▼             ▼             ▼
                                             OpenSearch      VHAL Read     VHAL Write
                                                   │             │             │
                                                   └─────────────┼─────────────┘
                                                                 ▼
                                                       [ Plain Text Output ]
                                                                 │
                                                       (Fast Regex Strip)
                                                                 │ (No LLM Cost)
                                                                 ▼
                                                       [ Amazon Polly (TTS) ]
```

### B. Feasibility Analysis & Quota Math
* **Token Overhead**:
  * **Single Invocation**: 1,000 input tokens + 300 output tokens.
  * **Regex formatting**: $0\text{ tokens}$ ($0.1\text{ ms}$ processing duration).
  * **Total**: 1,000 input tokens + 300 output tokens. Saves over **50% of the AWS token cost** compared to Option 1.
* **Latency Overhead**:
  * Single LLM invocation on Bedrock takes ~300ms.
  * Total latency: **~350ms** (comfortably under the mentor's 1.0s target).
* **Platform L3 Extra Points**: This approach utilizes **MCP tools** directly consumable by external testing harnesses, qualifying the team for L3 (Complete) in the scoring rubric.

---

## 🛠️ MCP Tool Definitions (For Option 2)

We specify three core tools the Agent can call dynamically:

### 1. `search_automotive_manual`
* **Purpose**: Query vector index database.
* **Args**: `{"query": "User query string"}`
* **Returns**: Grounded document text, page numbers, and document names.

### 2. `get_car_telemetry`
* **Purpose**: Read live vehicle metrics from AOSP VHAL.
* **Args**: None.
* **Returns**: Speed, HVAC temperature, and Diagnostic Trouble Codes (DTC).

### 3. `execute_car_action`
* **Purpose**: Send speed-sensitive control commands to the vehicle.
* **Args**: `{"device": "mirror_fold|hvac_temp", "value": "fold|unfold|22.0"}`
* **Returns**: Confirmation status (`success` or `refused_due_to_speed`).

---

## 💡 Recommendation

While **Option 1** offers clean modularity between document QA and speech logic, **Option 2 (Agent with MCP)** is strongly recommended. It is twice as fast, costs half as much token money, and directly aligns with the **L3 Platform scoring criteria** of the Hackathon regulations.
