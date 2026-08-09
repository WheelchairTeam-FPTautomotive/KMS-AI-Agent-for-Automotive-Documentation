# Sprint 2 — Final Optimized Execution Plan (SM)

> **Status**: **FINAL** for team execution (supersedes earlier draft notes in this file)  
> **Author**: Scrum Master / PM (Nguyễn Huỳnh Minh Đức)  
> **As of**: Monday 3 August 2026 (Sprint 2 Day 1)  
> **Freeze**: Implementation complete **Thu 7 Aug EOD** → **Fri 8 Aug = debug only** → **Sat–Sun = last 48h** → **Hard submit before 10 Aug 2026**  
> **KPI order (locked)**: **(1) Accuracy & reliability** → **(2) Latency** → **(3) Budget ($456 AWS)**  
> **Sources reconciled**: [Wheelchair Kanban](https://github.com/orgs/WheelchairTeam-FPTautomotive/projects/1) · [`sprint_2_submission_eval.md`](./sprint_2_submission_eval.md) · demo PRs `demo/judge-rag-locale-hardening` · local judge debug  

---

## 1. Executive decision

Ship a **reliable cited RAG + cockpit path** first. Use **local Chroma ± Ollama** for daily accuracy. Use **Terraform apply → Ansible (Ollama/vLLM/llama.cpp on SageMaker or GPU EC2) → destroy** only in booked windows for cloud demo. Do **not** chase Bedrock Haiku, always-on GPU, or new architecture after Wed noon.

**Merge demo branches by Tue EOD** (CI already green):

| Repo | PR |
|------|-----|
| `kms-core-ai` | [#8](https://github.com/WheelchairTeam-FPTautomotive/kms-core-ai/pull/8) |
| `backend-orchestrator` | [#14](https://github.com/WheelchairTeam-FPTautomotive/backend-orchestrator/pull/14) |
| `cockpit-ui` | [#10](https://github.com/WheelchairTeam-FPTautomotive/cockpit-ui/pull/10) |

---

## 2. Kanban snapshot (Wheelchair Kanban — 29 items)

| Column | Count | Meaning for Sprint 2 |
|--------|------:|----------------------|
| **Done** | 25 | Sprint 1 foundation largely closed on the board |
| **In review** | 1 | `kms-core-ai#3` Verify RAG (Thuận) — **close this Tue** after golden-set evidence |
| **Technical Debt** | 3 | Cloud/latency stretch — **time-box**, do not block Thu freeze |

### 2.1 Done (board) — treat as “built”, still verify in freeze smoke

| Repo | Issues (Done) | Owners (GH) |
|------|---------------|-------------|
| **kms-core-ai** | #1 Init · #2 PDF ingest · #4 OpenSearch/Bedrock RAG path · #5 `run.sh` dynamic eval | Thuận, Bảo |
| **backend-orchestrator** | #1–3 Docker/security · #4–6 Gateway scaffolding/proxy/errors · #7 STT/TTS config · #8 Intent router · #9 Terraform VPC/ECS/AOSS · #10 Ansible deploy · #11 VHAL speed unit | Ân, Bảo, Đức |
| **cockpit-ui** | #1–3 HUD/Retrofit/cards · #4–6 ADB/VHAL/APK · #7 Mic + idle music · #8 VHAL safety checks · #9 placeholder | Bình, Đức |
| **Docs meta** | Documentation `#4` roles/structure | Whole team |

### 2.2 Open on board

| Status | Issue | Owner | Sprint 2 action |
|--------|-------|-------|-----------------|
| **In review** | [kms-core-ai#3](https://github.com/WheelchairTeam-FPTautomotive/kms-core-ai/issues/3) Verify RAG | Thuận | Accept with golden-set log; move **Done** by Tue |
| **Tech debt** | [orchestrator#12](https://github.com/WheelchairTeam-FPTautomotive/backend-orchestrator/issues/12) SageMaker + Ansible models | Bảo | Apply/destroy windows only; Bucket B ≤ ~$180 |
| **Tech debt** | [orchestrator#13](https://github.com/WheelchairTeam-FPTautomotive/backend-orchestrator/issues/13) MCP server/client | Ân | **Defer unless** L3 points require a thin stub by Sat |
| **Tech debt** | [kms-core-ai#6](https://github.com/WheelchairTeam-FPTautomotive/kms-core-ai/issues/6) VI LLM + low-latency TTS | Thuận | **Locked:** `qwen2.5:7b-instruct` (§7); TTS separate |

### 2.3 Kanban hygiene (SM — Mon/Tue)

Board has **no Todo column items** for Sprint 2 submission work. Create cards (or reopen checklists) for the **Must** list in §4 so status is visible. Rule: **Kanban Done ≠ submission-ready** until freeze DoD (§6) passes.

---

## 3. Gap analysis vs `sprint_2_submission_eval.md`

Eval doc goals vs reality (demo + board):

| Eval theme | Board / code reality | Optimal Sprint 2 handling |
|------------|----------------------|---------------------------|
| Page-level citations | Partial in RAG payloads; UI cards incomplete per #3 body | **Must** — Thuận harden schema; Bình finish cards |
| Safety abstention | Present in core + demo locale strings | **Must** — golden negatives; mark verified |
| STT/TTS voice | #7 Done on board; dual path (device + gateway) fragile | **Should** — Ân/Bảo harden one path for video; typed RAG is backup |
| Hybrid BM25 | Not proven in demo (dense Chroma gate path is) | **Defer** if dense+gate passes golden set; else Thuận light hybrid only |
| `run.sh` eval + F1 | #5 Done on board — confirm artifact quality | **Must** — Bảo+Thuận produce real output by Thu |
| Wake-word “Hey Car” | In eval for Bình; **not** a Kanban open card | **Should** — ship if ready Wed; else Fri polish / video without it |
| Day/Night theme | Eval only | **Defer** to Fri polish if time |
| Speed &gt; 80 banner + VHAL | Partial (#8 Done; mirror gate local) | **Must** for demo video — Đức+Bình |
| Docker cold-start &lt; 2s | Infra Done; need measure | **Should** — Bảo Fri if P0 green |
| Demo video + zip | Đức/Bảo weekend | **Must** Sat–Sun |
| Demo PRs (locale, tone-free, intent fold, soft timeout) | **Not on Kanban** | **Must** merge Tue — create tracking card or attach to #3 |

---

## 4. Optimal backlog (cut scope to win KPI #1)

### 4.1 MUST — done by Thu EOD (implementation freeze)

| ID | Work | Owner | Links |
|----|------|-------|-------|
| M1 | Merge demo PRs #8 / #14 / #10; resolve conflicts | Repo owners + SM | Locale, tone-free RAG, intent, soft timeout, APK cache |
| M2 | Close **Verify RAG** (#3) with golden set (30–50 queries) | Thuận (+ Đức smoke) | VI/EN, tone-free, DTC, refuse, free-talk, citations |
| M3 | Citation contract on every RAG `success` + UI cards | Thuận + Bình | Eval Day 1–2 |
| M4 | Safety negatives locked (unsafe / off-topic → `refused`) | Thuận + Ân | Eval Day 3–4 |
| M5 | Reproducible Chroma ingest (`rglob` + `--reset`) documented | Thuận + Bảo | Accuracy parity every machine |
| M6 | `run.sh --input/--output` emits usable eval artifact | Bảo + Thuận | Board #5 verify |
| M7 | E2E typed path: cockpit → :8000 → :8001 on Google APIs AVD | Bình + Đức | Board #3 leftover ACs |
| M8 | VHAL speed alert path ready for demo script | Đức + Bình | Eval + board #8 |

### 4.2 SHOULD — finish if M-list green before Thu noon; else Fri

| ID | Work | Owner | Notes |
|----|------|-------|-------|
| S1 | One voice path stable for video (gateway STT/TTS **or** on-device) | Ân + Bình + Bảo | Prefer reliability over two half-working paths |
| S2 | Wake-word Foreground Service | Bình | Eval stretch; don’t block freeze |
| S3 | Gateway query cache + latency headers | Ân | **After** M2 green; cache key = `hash(query)+language+intent`; never cache `refused` across languages |
| S4 | First Terraform GPU apply/destroy + Ansible model pull | Bảo + Thuận (#12/#6) | Prove parity with local Ollama; then destroy; **max 1 apply/day** unless SM approves |
| S5 | Docker non-root + cold-start note | Bảo | Report cold vs warm separately; cold must not fail KPI #1 demos |

### 4.3 DEFER — after freeze / only if points require

| ID | Work | Owner | Why defer |
|----|------|-------|-----------|
| D1 | MCP server/client (#13) | Ân | XL; thin stub Sat only if rubric L3 demands |
| D2 | Dense+sparse hybrid BM25 | Thuận | Only if golden set fails on retrieval |
| D3 | Day/Night theme | Bình | Polish |
| D4 | Always-on AOSS / Bedrock Sonnet / multi-agent | — | Budget + latency killers |
| D5 | Model shopping beyond one frozen OSS weights | Thuận | Burns #6 and $456 |

---

## 5. Calendar (optimal)

| Day | Date | Mode | Focus |
|-----|------|------|--------|
| **Mon** | 3 Aug | Build | SM plan lock; open Sprint 2 Kanban cards; start M1 merges |
| **Tue** | 4 Aug | Build | **M1 merged**; M2 golden set; M5 ingest doc; close #3 In review |
| **Wed** | 5 Aug | Build | M3–M4–M7; optional S4 cloud GPU window → **destroy** |
| **Thu** | 6–7 Aug* | **Freeze** | Close all Must; tag `sprint2-impl-freeze`; no new features after EOD |
| **Fri** | 8 Aug | **Debug only** | Flakes, distance-gate evidence retune, voice/wake polish (S1–S2) |
| **Sat** | 9 Aug | Package | Demo video (Đức); zip (Bảo); README; optional MCP stub (D1) |
| **Sun** | 9–10 Aug | Submit | Final sanity; portal upload; **destroy all GPU** |

\*Align Thu freeze to **7 Aug EOD** per SM cadence (implementation through Thursday).

---

## 6. Freeze Definition of Done (Thu EOD gate)

Sign off in team chat when **all** true:

**KPI #1 — Accuracy & reliability**

1. Golden set ≥ **90%** expected status (success / refused / not_found) on **local** stack (`qwen2.5:7b-instruct` or documented fallback).  
2. Every RAG success shows **≥1 citation** in API and cockpit.  
3. Unsafe queries **refused** in VI and EN UI modes.  
4. Demo PRs merged (or explicitly cherry-picked) onto integration branch.  
5. `run.sh` produces a committed or artifact-uploaded eval output sample.  
6. Emulator E2E typed query works with correct **UI language**.  
7. Wrong-PDF / hallucinated citations on golden RAG subset = **fail freeze** (fix before any latency work).

**KPI #2 — Latency** (measured only after #1 green; never gate freeze on cold start)

8. **Warm** typed RAG p95 documented: extractive/`none` **&lt; 2.0s** gateway→answer **or** Qwen warm **&lt; 5.0s** p95 on golden RAG subset (pick one stack for the scorecard; state which).  
9. Soft gateway timeout (≤120s) remains a **reliability** ceiling, not the latency target.  
10. Any latency change (cache, fewer expansions, vLLM) must **re-pass** golden set §6.1–6.3 before merge.

**KPI #3 — Budget**

11. Cost Explorer: **no orphan GPU/SageMaker** left running overnight; cumulative AWS **&lt; $410** entering Sunday (keep ~$46 contingency).  
12. Every cloud GPU session has apply time, owner, and destroy confirmation in the on-hours log.

---

## 7. Model freeze (SM decision — locked)

> Replaces ad-hoc `llama3.2:3b` for submission week. Maps to Kanban **kms-core-ai#6**.

### 7.1 Primary (use everywhere)

| Field | Value |
|-------|--------|
| **Model** | **Qwen2.5-7B-Instruct** |
| **Ollama tag** | `qwen2.5:7b-instruct` |
| **HF / vLLM id** | `Qwen/Qwen2.5-7B-Instruct` |
| **Quant (GPU)** | Ollama default **Q4_K_M** (or AWQ/GPTQ 4-bit under vLLM) |
| **Why** | Explicit **Vietnamese + English**; strong instruction-following for grounded RAG; fits **one** g4dn/g5 / consumer 16GB-class GPU; Apache-2.0-friendly 7B line; no “reasoning” chain that kills latency KPI |

**Runtime config (core-ai):**

```env
LLM_PROVIDER=ollama
OPENAI_BASE_URL=http://localhost:11434/v1
OPENAI_MODEL=qwen2.5:7b-instruct
LLM_TEMPERATURE=0.0
LLM_MAX_TOKENS=400
```

Cloud/vLLM: same weights via OpenAI-compatible URL; set `LLM_PROVIDER=openai_compatible` + `OPENAI_MODEL=Qwen/Qwen2.5-7B-Instruct`.

### 7.2 Fallback ladder (only if primary blocked)

| Priority | Model | When |
|----------|--------|------|
| **F1** | `qwen2.5:3b-instruct` | Laptop CPU/low VRAM; accuracy may dip — golden-set must still refuse/not_found correctly |
| **F2** | `LLM_PROVIDER=none` (extractive) | GPU destroyed / Ollama down — **reliability over fluency** |
| **Do not use** | `llama3.2:3b` as submission primary | Weak VI; current local default — retire for demo |
| **Do not use** | 14B / 32B / 70B, DeepSeek-R1-class | Budget + latency; violates “zero reasoning tokens” intent of #6 |
| **Do not use** | Bedrock Haiku/Sonnet as required path | Not in team stack this week |

### 7.3 Serving choice

| Context | Runtime |
|---------|---------|
| Local daily / single judge | **Ollama** + `qwen2.5:7b-instruct` |
| Booked AWS demo / concurrent | **vLLM** on SageMaker or GPU EC2 (same HF id), then **terraform destroy** |
| Emergency | **llama.cpp** Q4 of same 7B instruct if Ollama/vLLM broken |

**TTS** stays out of this freeze (Polly / edge-tts / on-device) — do not couple TTS model shopping to the RAG LLM.

### 7.4 Owner actions

- **Thuận**: pull weights once; prompt-test golden set; no further model swaps after **Wed EOD**.  
- **Bảo**: Ansible/`OPENAI_MODEL` default = `qwen2.5:7b-instruct`; document pull time in apply runbook.  
- **Ân**: gateway unchanged; point at core only.  
- **SM**: reject PRs that change submission model without golden-set re-pass.

---

## 8. AWS $456 — optimized (no Haiku)

**Policy:** `$456` = **scheduled OSS LLM GPU hours** (SageMaker **or** EC2) via **Terraform apply / destroy** + Ansible, plus light speech/API host — **not** always-on inference.

| Bucket | Cap | Use |
|--------|----:|-----|
| A Retrieval | ~$100 | Chroma-on-box preferred; AOSS only if destroyable & cheap |
| B GPU LLM | ~$180 | Ollama/vLLM/llama.cpp on-demand (#12/#6) |
| C Speech | ~$60 | Transcribe/Polly for video only |
| D API host | ~$70 | Gateway+core CPU |
| E Contingency | ~$46 | Locked |

**Lifecycle:** demand → `terraform apply` → Ansible model/runtime → warm → work → **`terraform destroy` (mandatory)**.  
**Daily accuracy = local.** Cloud = Wed/Thu proof + Sat–Sun demo windows only.

---

## 9. Owner RACI (submission week)

| Person | Must own | Support |
|--------|----------|---------|
| **Thuận** | M2–M5, model freeze (#6), eval metrics | Cloud parity with Bảo |
| **Ân** | M4 gateway behavior, S1/S3, intent tests stay green | MCP D1 only if required |
| **Bảo** | M6, S4/S5, $456 / TF destroy, zip | Whisper sidecars if S1 needs |
| **Bình** | M3 UI, M7, S2 wake-word | Video UI assist |
| **Đức (SM + VHAL)** | M1 chase, M8, golden smoke, video, Kanban hygiene | Unblock merges |

---

## 10. Mapping to eval doc (do not edit eval file blindly)

Use this plan as the **execution filter** over [`sprint_2_submission_eval.md`](./sprint_2_submission_eval.md):

- Eval **Day 1–2** → **M3, M7, S1, S2** (wake-word = Should).  
- Eval **Day 3–4** → **M4, M6, M8** (+ Ân cache = Should).  
- Eval **Day 5–6** → shift: **Thu = freeze**, **Fri = debug**, video mostly **Sat** (Đức).  
- Eval **Day 7** → Sat–Sun packaging (unchanged intent).

When updating the eval doc later: replace “hybrid BM25 required” with “dense + distance gate + optional hybrid if golden fails”; replace Bedrock-centric wording with **OSS LLM + apply/destroy**; replace “RAG &lt; 300ms” with **warm scorecard in §6** (extractive &lt; 2s **or** Qwen &lt; 5s) — raw 300ms end-to-end with 7B generation is **not** KPI-compliant (it forces extractive-only or fake metrics).

---

## 11. Risks (SM watchlist)

1. **Board overstates Done** — re-verify #7 voice, #5 run.sh, #3 citations under golden set.  
2. **Merge lag** past Tue → Fri becomes conflict day.  
3. **GPU left up** → budget death; destroy is a DoD item.  
4. **Wake-word + dual STT** soak Bình/Ân — typed RAG must remain demo-safe.  
5. **MCP XL (#13)** — do not start before Must green.  
6. **Eval doc “RAG &lt; 300ms”** — conflicts with KPI order if enforced on Qwen path; use §6 scorecard.  
7. **AOSS from board #9 Done** — provisioning scripts exist; **do not apply AOSS** unless Bucket A math clears (prefer Chroma).

---

## 12. One-line team charter

**Freeze a correct, cited, bilingual RAG cockpit on Qwen2.5-7B-Instruct by Thursday; debug Friday; film and submit on the weekend — spend AWS only on destroyed-after-use OSS GPU hours inside $456.**

---

## 13. KPI compliance verification (full-plan audit)

Audit date: **3 Aug 2026**. Verdict: **COMPLIANT with fixes applied in §6 / §4.2 / §10** — residual risks tracked below.

### 13.1 KPI #1 Accuracy & reliability — **PASS**

| Plan element | Compliant? | Evidence |
|--------------|:----------:|----------|
| Must backlog M1–M8 | Yes | Citations, safety, golden set, locale, ingest, E2E before freeze |
| Should voice/wake as non-blocking | Yes | Typed RAG remains demo spine |
| Defer BM25 / MCP / model thrash | Yes | Avoids accuracy churn |
| Qwen2.5-7B + extractive fallback | Yes | VI/EN + reliability ladder F2 |
| Distance gate / tone-free in M1 | Yes | Reduces wrong-PDF answers |
| Freeze DoD golden 90% + citation + refuse | Yes | §6.1–6.7 |
| Soft 120s timeout (via M1) | Yes | Prefer soft answer over 5xx (**reliability**) |

**Residual risk:** Board marks voice/run.sh Done without golden proof — mitigated by M2/M6 and Risk #1.

### 13.2 KPI #2 Latency — **PASS (conditional)**

| Plan element | Compliant? | Evidence |
|--------------|:----------:|----------|
| Latency only after accuracy green | Yes | S3/S4/S5 gated; §6.10 re-pass golden |
| 7B not 70B / no R1 | Yes | §7 |
| Warm Ollama local / vLLM on booked GPU | Yes | §7.3, §8 |
| Cache language-aware | Yes | S3 note |
| Multi-query expansion retained for accuracy | Partial → OK | Accepts latency cost for tone-free VI; SLA uses warm scorecard not “expand always under 300ms” |
| Eval doc &lt;300ms / &lt;1s car-control | **Conflict resolved** | §10: do not enforce 300ms on Qwen E2E; use §6.8–6.9 |
| Soft timeout 120s | OK | Ceiling ≠ target; document warm p95 separately |

**Residual risk:** First Qwen pull/cold start looks “slow” in demos — mitigate with warm script + pre-roll before video (Fri/Sat).

### 13.3 KPI #3 Budget ($456) — **PASS**

| Plan element | Compliant? | Evidence |
|--------------|:----------:|----------|
| No Haiku/Sonnet required path | Yes | §7, §8 |
| Apply/destroy lifecycle | Yes | §1, §8, DoD §6.11–6.12 |
| Soft caps A–E sum ≈ $456 | Yes | §8 |
| Daily accuracy on local $0 | Yes | Charter |
| AOSS/always-on deferred | Yes | D4 + Risk #7 |
| S4 max 1 apply/day | Yes | §4.2 tightened |
| Contingency $46 | Yes | Enter Sunday &lt; $410 |

**Residual risk:** Accidental AOSS apply from existing Terraform (#9 Done) — SM/Bảo checklist before any `terraform apply`.

### 13.4 Cross-KPI conflict matrix

| If we optimize… | Effect on others | Plan rule |
|-----------------|------------------|-----------|
| Accuracy (more retrieval expansions, stricter gate) | Latency ↑ | Allowed; measure warm p95 after |
| Latency (cache, fewer expansions, smaller model) | Accuracy may ↓ | Only after golden green; re-run M2 |
| Budget (destroy GPU, extractive) | Fluency ↓, latency may ↑ on CPU | F2 fallback; never skip refuse/not_found |

**Illegal trades (explicitly banned):** cut citations to save tokens · leave GPU up to “feel fast” · enforce 300ms by disabling the distance gate · switch models after Wed without golden re-pass.

### 13.5 Final SM sign-off

| KPI | Status |
|-----|--------|
| #1 Accuracy & reliability | **Compliant** |
| #2 Latency | **Compliant** (targets realistic for 7B; eval 300ms superseded) |
| #3 Budget $456 | **Compliant** (destroy discipline mandatory) |

**Overall: plan is KPI-compliant for Sprint 2 execution.**

---

*End of Final Optimized Sprint 2 Execution Plan.*
