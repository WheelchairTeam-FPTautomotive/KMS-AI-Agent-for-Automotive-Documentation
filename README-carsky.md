# Hướng dẫn Deploy lên Thiết bị AAOS thực tế (Reach Backend)

Thư mục này chứa tool `reach-backend` dùng để tạo đường hầm (Tunnel) kết nối máy tính của bạn (Local) với màn hình Android Automotive OS (AAOS) thực tế đang chạy trên Cloud của ban tổ chức.

## 🛠 Cách kết nối và Deploy App

Để cài đặt App `Wheelchair Copilot` lên xe thật, bạn chỉ cần làm theo 3 bước sau:

### Bước 1: Mở đường hầm kết nối (Tunnel)

Mở Terminal (PowerShell hoặc Command Prompt) trong thư mục `reach_be/reach`, chạy lệnh sau để tool chạy ngầm và mở cổng kết nối `5555`:

```powershell
.\reach-backend.exe adb --gateway https://hackathon-1.carsky.io --key a8k_cGttcnI5cnotdncwcWdzdXBxbm0xLW42
```

*(Cửa sổ dòng lệnh này cứ để nguyên đó, không được tắt)*

### Bước 2: Kết nối ADB vào đường hầm

Mở một cửa sổ Terminal **MỚI**, gõ lệnh sau để Android Debug Bridge (ADB) móc nối vào cổng vừa mở:

```powershell
adb connect localhost:5555
```

*(Nếu thành công, nó sẽ báo `connected to localhost:5555`)*

### Bước 3: Cài đặt và Chạy App

Bây giờ máy tính của bạn đã coi cái màn hình AAOS kia như là một thiết bị cắm dây USB trực tiếp. Bạn có thể cài APK bằng lệnh:

```powershell
adb -s localhost:5555 install -r D:\Hackathon\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk
```

Để tự động bật App lên màn hình xe, chạy lệnh:

```powershell
adb -s localhost:5555 shell am start -n com.wheelchair.cockpit/.MainActivity
```

---

💡 **Mẹo nhỏ cho lúc đi thi:**
Sau khi bạn đã chạy Bước 1 và Bước 2 thành công. Bạn hoàn toàn có thể quay lại **Android Studio**, nhìn lên thanh chọn Device (kế bên nút Run tam giác màu xanh). Bạn sẽ thấy xuất hiện một thiết bị tên là `localhost:5555`. Bạn chỉ việc chọn nó và bấm **Run**, Android Studio sẽ tự động Build và ném thẳng App lên xe thật luôn mà không cần gõ lệnh ở Bước 3 nữa!
