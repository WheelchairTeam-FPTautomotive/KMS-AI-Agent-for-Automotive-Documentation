# 🚗 Wheelchair Copilot - Hackathon Project

Dự án Wheelchair Copilot tích hợp Trợ lý ảo (AI) và hệ thống điều khiển phần cứng của xe (Android Automotive VHAL) dành riêng cho Carsky Platform.

---

## 📂 Cấu trúc dự án

- `cockpit-ui/`: Source code Android (Kotlin, Jetpack Compose) dành cho màn hình xe.
- `backend-orchestrator/`: FastAPI Gateway (Port 8000) xử lý Text-To-Speech, Speech-To-Text và định tuyến các lệnh điều khiển xe.
- `kms-core-ai/`: Dịch vụ RAG và AI xử lý ngôn ngữ tự nhiên (Port 8001).
- `reach_be/`: Công cụ tạo luồng kết nối ADB (Tunnel) tới xe ảo trên đám mây.

---

## 🚀 Hướng dẫn khởi chạy (Dành cho Dev)

Để toàn bộ hệ thống hoạt động hoàn hảo từ A-Z (bao gồm cả STT, TTS, điều khiển VHAL), bạn cần mở **4 Terminal** theo đúng thứ tự sau:

### 1️⃣ Khởi chạy AI Services (Terminal 1)

```powershell
cd d:\Hackathon\kms-core-ai
python -m uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8001
```

### 2️⃣ Khởi chạy Backend Orchestrator (Terminal 2)

```powershell
cd d:\Hackathon\backend-orchestrator
python -m uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8000
```

*(Thêm cờ `--reload` ở cuối nếu bạn muốn code tự động cập nhật khi sửa).*

### 3️⃣ Chạy 9router - Local Routing (Terminal 3)

```powershell
cd d:\Hackathon
9router
```

*(Công cụ này giúp định tuyến và ổn định luồng dữ liệu cục bộ).*

### 4️⃣ Kết nối ADB tới Xe ảo Carsky (Terminal 4)

```powershell
cd d:\Hackathon\reach_be\reach
.\reach-backend.exe adb --gateway https://hackathon-1.carsky.io --key a8k_aTEteDJ1eGF3cHgtcGN5ZHh3eGMxLW42
```

*(Lệnh này sẽ chạy liên tục để duy trì mạng tới xe ảo).*

### 5️⃣ ⚠️ BƯỚC BẮT BUỘC: Kết nối & Mở hầm ngược (Terminal 5)

Sau khi Terminal 4 báo connected, hãy **mở một cửa sổ gõ lệnh mới (Terminal 5)** và gõ:

```powershell
cd d:\Hackathon
adb connect localhost:5555
```

Tiếp theo, vì xe nằm trên mây (Carsky) còn Backend nằm ở máy bạn, bạn **bắt buộc** phải map port 8000 của xe về port 8000 của máy laptop để STT/TTS gọi được API:

```powershell
adb reverse tcp:8000 tcp:8000
```

*(Nếu thành công, terminal sẽ in ra số `8000`. **Lưu ý:** Mỗi lần bạn chạy script `push_privapp.ps1` để đẩy App mới, cái hầm này sẽ sập, bạn phải quay lại Terminal 5 và chạy lại lệnh `adb reverse` này một lần!)*

### 6️⃣ 🎤 Cấu hình Microphone (Đón nhận âm thanh)

1. Trên nền tảng web **Carsky**, tìm biểu tượng **Microphone** và bật lên (Cho phép trình duyệt sử dụng Mic).
2. Lần đầu mở app Wheelchair Copilot trên màn hình xe, app sẽ hỏi quyền **Record Audio**. Hãy bấm **Allow** (Cho phép).

---

## ⚠️ Hướng dẫn Build & Deploy UI (RẤT QUAN TRỌNG)

Vì ứng dụng Copilot điều khiển phần cứng của xe (AC, Cửa, Gương) nên nó cần đặc quyền của hệ thống (System Privileged App).

**✅ Nếu bạn CHỈ SỬA CODE (Logic, UI):**
Bạn hoàn toàn có thể bấm nút **Run/Play (màu xanh)** trong Android Studio để chạy và test nhanh! Vì app đã được nạp vào hệ thống trước đó nên quyền đã được ghi nhớ.

**❌ KHI NÀO PHẢI DÙNG SCRIPT ĐỂ DEPLOY?**
Bạn **BẮT BUỘC** phải dùng Script dưới đây nếu:
1. Bạn chạy app trên một chiếc xe ảo hoàn toàn mới (hoặc vừa reset data).
2. Bạn vừa thêm quyền (Permission) mới vào file `AndroidManifest.xml` hoặc file `privapp-permissions-wheelchair.xml`.
*(Nếu cố tình bấm Play trong 2 trường hợp này, xe sẽ từ chối quyền, dẫn đến lỗi app không đọc được trạng thái VHAL và crash ngầm).*

**CÁCH CHẠY SCRIPT (Deploy mức Hệ thống):**
1. Trong Android Studio: **Build** -> **Build Bundle(s) / APK(s)** -> **Build APK(s)**.
2. Mở Terminal (PowerShell), chạy file script:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File d:\Hackathon\KMS-AI-Agent-for-Automotive-Documentation\push_privapp.ps1
   ```
3. Script sẽ đẩy file APK vào `/system/priv-app/WheelchairCopilot/` và reboot UI. Đợi vài giây là bạn có thể test!

---

## 🛠 Xử lý sự cố (Troubleshooting)

- **UI điều hòa luôn hiển thị OFF dù xe đang bật:** Do app bị mất đặc quyền hệ thống. Hãy làm lại bước **Deploy đúng** ở trên.
- **Trợ lý ảo nói "Lỗi xử lý âm thanh. Đã về Standby" ngay khi nghe "Hey Car":** Kiểm tra lại Terminal 2 (Backend Orchestrator) xem server có đang chạy và đang nhận lệnh trên cổng 8000 hay không.
- **Không đẩy được APK vào xe (báo Read-only filesystem):** Chạy lệnh `adb root` sau đó `adb remount` trước khi chạy script `push_privapp.ps1`.

---

## 🔒 Cơ chế Cấp Quyền Hệ Thống (System Permissions)

Trong Android Automotive, một số quyền can thiệp sâu vào phần cứng xe (như bật tắt máy lạnh, mở khóa cửa) bị khóa chặt bằng cơ chế `signature|privileged`. Người dùng (User) không thể tự cấp quyền này.

Đó là lý do chúng ta có 2 file cấu hình đặc biệt nằm trong thư mục `KMS-AI-Agent-for-Automotive-Documentation`:

1. **`privapp-permissions-wheelchair.xml` (Danh sách trắng - Whitelist)**:

   - Đây là file cấu hình bảo mật của hệ điều hành. Nó báo cho Android OS biết rằng: *"Hãy cho phép ứng dụng `com.wheelchair.cockpit` được dùng các quyền `CONTROL_CAR_CLIMATE` và `CONTROL_CAR_DOORS`"*.
   - Nếu không có file này ở thư mục `/system/etc/permissions/`, HĐH xe sẽ chặn quyền hoặc thậm chí treo luôn màn hình khởi động (bootloop).
2. **`push_privapp.ps1` (Script tự động hóa deploy)**:

   - Thay vì cài app bình thường, file script này sẽ dùng ADB đẩy thẳng file XML danh sách trắng ở trên và file APK của chúng ta vào sâu trong phân vùng hệ thống (`/system/priv-app/`).
   - Sau đó, nó tự động khởi động lại giao diện xe (`stop` và `start` shell) để xe nhận diện app của chúng ta như một "ứng dụng hệ thống mặc định của xe" (System App), qua đó được cấp trọn vẹn đặc quyền điều khiển xe.
