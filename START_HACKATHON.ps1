# BẢN BACKUP KHỞI CHẠY NHANH CHO HACKATHON
# Kịch bản này tự động bật tất cả các dịch vụ Backend lên các cửa sổ riêng biệt để bạn đỡ phải gõ lệnh.

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   🚀 HACKATHON BACKEND AUTO-STARTER 🚀   " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Đang bật các dịch vụ ngầm (Terminal 1, 2, 3)..."

# 1. Bật AI Core (Terminal 1)
Start-Process powershell.exe -ArgumentList "-NoExit -Command `"cd d:\Hackathon\kms-core-ai; python -m uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8001`"" -WindowStyle Normal

# 2. Bật Backend Orchestrator (Terminal 2)
Start-Process powershell.exe -ArgumentList "-NoExit -Command `"cd d:\Hackathon\backend-orchestrator; python -m uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8000`"" -WindowStyle Normal

# 3. Bật 9router (Terminal 3)
Start-Process powershell.exe -ArgumentList "-NoExit -Command `"cd d:\Hackathon; 9router`"" -WindowStyle Normal

Write-Host "`n✅ Đã bật xong 3 dịch vụ Backend!" -ForegroundColor Green

Write-Host "`nBƯỚC TIẾP THEO (BẠN PHẢI TỰ LÀM):" -ForegroundColor Yellow
Write-Host "1. Mở cửa sổ Terminal 4, chạy lệnh sau để kết nối xe:"
Write-Host "   cd d:\Hackathon\reach_be\reach"
Write-Host "   .\reach-backend.exe adb --gateway https://hackathon-1.carsky.io --key a8k_aTEteDJ1eGF3cHgtcGN5ZHh3eGMxLW42"
Write-Host ""
Write-Host "2. Sau khi Terminal 4 báo Connected, mở Terminal 5 để Đẩy code lên xe và đục hầm:"
Write-Host "   powershell.exe -ExecutionPolicy Bypass -File `"d:\Hackathon\KMS-AI-Agent-for-Automotive-Documentation\push_privapp.ps1`" -Backend Local"
Write-Host "   (Chú ý: TUYỆT ĐỐI KHÔNG BẤM NÚT RUN TRONG ANDROID STUDIO!)"
Write-Host "================================================" -ForegroundColor Cyan
