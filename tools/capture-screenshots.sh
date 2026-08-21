#!/usr/bin/env bash
#
#  capture-screenshots.sh — chụp ảnh màn hình cho trang hinh-anh.html
#
#  Cách dùng:
#    1. Chạy colorburst trong máy ảo, cửa sổ 1920x1200 để ảnh đủ nét
#       và giao diện hiện đầy đủ:
#         CB_WINDOW=1920x1200 ./start-vm.sh
#       (thêm CB_HIDPI=1 nếu màn hình của bạn để scale 200%)
#    2. Chạy script này từ thư mục gốc của kho colorburst-site:
#         ./tools/capture-screenshots.sh
#    3. Với mỗi ảnh, sắp xếp màn hình VM theo gợi ý, rồi Enter.
#       Script đếm ngược 5 giây để bạn kịp đưa chuột về cửa sổ VM.
#
#  Ảnh được lưu vào images/ với đúng tên mà hinh-anh.html trỏ tới.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$HERE/images"
mkdir -p "$OUT"

# ----- tìm công cụ chụp có trên máy -----------------------------------------
# Mỗi lệnh chụp CỬA SỔ đang được chọn (active window) nếu tool hỗ trợ;
# với grim (wlroots/sway) thì bạn quét vùng cửa sổ bằng chuột.
capture() {
    local file="$1"
    if command -v gnome-screenshot >/dev/null; then
        gnome-screenshot -w -f "$file"          # GNOME: cửa sổ đang chọn
    elif command -v spectacle >/dev/null; then
        spectacle -b -a -n -o "$file"           # KDE: cửa sổ đang chọn
    elif command -v grim >/dev/null && command -v slurp >/dev/null; then
        grim -g "$(slurp)" "$file"              # sway/wlroots: quét vùng
    else
        echo "Không tìm thấy công cụ chụp màn hình." >&2
        echo "Cài một trong: gnome-screenshot, spectacle, grim+slurp." >&2
        exit 1
    fi
}

# ----- dọn ảnh cho gọn: bỏ metadata, thu về tối đa 1920px ngang -------------
polish() {
    local file="$1"
    if command -v magick >/dev/null; then
        magick "$file" -strip -resize '1920x>' "$file"
    elif command -v convert >/dev/null; then
        convert "$file" -strip -resize '1920x>' "$file"
    fi
}

# ----- danh sách ảnh, khớp với hinh-anh.html --------------------------------
#  tên tệp | cảnh cần dựng
shots=(
  "man-hinh-chinh.png|Màn hình chính sau khi đăng nhập. Mở sẵn 1-2 cửa sổ cho tự nhiên, đồng hồ và khay hệ thống hiện tiếng Việt."
  "tao-tai-khoan.png|Màn hình chào lần đầu khởi động (CB_FRESH=1 để quay lại từ đầu), đang ở bước 'Create a local account'."
  "go-telex.png|Một trình soạn thảo đang mở, đã gõ vài câu tiếng Việt có dấu; biểu tượng VI hiện ở góc dưới phải."
  "doc-bao.png|Trình duyệt mở vnexpress.net, một bài báo đang đọc dở, cuộn qua khỏi quảng cáo đầu trang."
  "facebook.png|Trình duyệt mở facebook.com, đã đăng nhập tài khoản thử nghiệm, bảng tin hiện bài tiếng Việt."
  "zalo.png|Zalo web (chat.zalo.me) đang mở một cuộc trò chuyện tiếng Việt; che/làm mờ số điện thoại nếu lộ."
  "quan-ly-don-hang.png|Kênh người bán Shopee (banhang.shopee.vn) với gian hàng thử nghiệm, đang ở trang danh sách đơn hàng."
  "cai-dat.png|Trang Cài đặt (Settings) bằng tiếng Việt, mục tổng quan."
)

echo
echo "Sẽ chụp ${#shots[@]} ảnh vào $OUT"
echo "Mẹo: chạy VM với CB_WINDOW=1920x1200 để các ảnh cùng cỡ và đủ nét."
echo

for entry in "${shots[@]}"; do
    name="${entry%%|*}"
    hint="${entry#*|}"
    echo "--> $name"
    echo "    Cảnh: $hint"
    read -rp "    Dựng xong màn hình rồi nhấn Enter (s để bỏ qua): " ans
    [ "$ans" = "s" ] && { echo "    Bỏ qua."; continue; }
    echo -n "    Chụp sau: "
    for i in 5 4 3 2 1; do echo -n "$i "; sleep 1; done
    echo
    capture "$OUT/$name"
    polish  "$OUT/$name"
    echo "    Đã lưu $OUT/$name"
    echo
done

echo "Xong. Mở hinh-anh.html để xem lại các ảnh."
