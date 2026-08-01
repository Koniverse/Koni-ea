# STARTER_EA v1.00 — Tài Liệu Thuật Toán

**File**: `STARTER_EA_v1.00.mq5`
**Phiên bản**: v1.00
**Ngôn ngữ**: MQL5
**Ngày cập nhật**: 2026-08-02

> [!WARNING]
> **Đây là template cấu trúc, không phải chiến lược.** Tín hiệu vào lệnh là một
> EMA cross tầm thường, **không có lợi thế thống kê**, tồn tại chỉ để minh họa
> chỗ logic của bạn cắm vào. Không chạy bản này trên tài khoản thật.

---

## 1. Tổng quan chiến lược

STARTER_EA là **bộ khung tham chiếu** cho EA MQL5 trên MetaTrader 5. Nó triển
khai đầy đủ và đúng chuẩn mọi cơ chế *hạ tầng* mà một EA Koniverse phải có —
vòng đời sự kiện, quản lý handle chỉ báo, chặn tín hiệu theo nến đóng, sizing
theo % rủi ro, SL/TP tôn trọng stop level của sàn, các chốt an toàn (equity
breaker, giới hạn lỗ ngày, cooldown), bộ lọc vận hành và khôi phục trạng thái
sau restart.

Phần **duy nhất** bạn cần viết lại là hàm `Signal()`. Mọi thứ còn lại là hạ tầng
nên giữ nguyên.

**Loại chiến lược**: trend-following (placeholder — thay bằng loại của bạn).
**Phương pháp quản lý vốn**: rủi ro cố định theo % equity mỗi lệnh, một vị thế
tại một thời điểm, không DCA, không martingale.

---

## 2. Cải tiến so với phiên bản trước

Không có — đây là `v1.00`, phiên bản đầu tiên.

---

## 3. Tham số đầu vào

### ==== General ====

| Input | Mặc Định | Kiểu | Mô tả |
|---|---|---|---|
| `InpMagicNumber` | `990001` | `long` | Định danh instance. **Bắt buộc > 0 và duy nhất cho từng instance đang chạy.** MT5 không tự kiểm tra trùng — hai EA chung magic sẽ quản lý lệnh của nhau. |
| `InpTradeComment` | `STARTER_EA` | `string` | Tiền tố comment gắn vào lệnh, dùng để truy vết trên Journal. |

### ==== Signal (thay thế phần này) ====

| Input | Mặc Định | Kiểu | Mô tả |
|---|---|---|---|
| `InpFastPeriod` | `12` | `int` | Chu kỳ EMA nhanh của tín hiệu placeholder. |
| `InpSlowPeriod` | `26` | `int` | Chu kỳ EMA chậm của tín hiệu placeholder. Bắt buộc lớn hơn `InpFastPeriod`. |

### ==== Position Sizing ====

| Input | Mặc Định | Kiểu | Mô tả |
|---|---|---|---|
| `InpUseRiskPercent` | `true` | `bool` | `true` = tính lot theo % equity; `false` = dùng lot cố định. |
| `InpRiskPercent` | `1.0` | `double` | `[InpUseRiskPercent=true]` Rủi ro mỗi lệnh, tính theo % equity. |
| `InpFixedLot` | `0.01` | `double` | `[InpUseRiskPercent=false]` Khối lượng cố định mỗi lệnh. |

### ==== Stop Loss / Take Profit ====

| Input | Mặc Định | Kiểu | Mô tả |
|---|---|---|---|
| `InpAtrPeriod` | `14` | `int` | Chu kỳ ATR dùng để tính khoảng cách SL. |
| `InpAtrSLMult` | `2.0` | `double` | Khoảng cách SL = `ATR * hệ số này`. |
| `InpRR` | `1.5` | `double` | Khoảng cách TP = `khoảng cách SL * hệ số này` (tỷ lệ reward:risk). |

### ==== Risk Management ====

| Input | Mặc Định | Kiểu | Mô tả |
|---|---|---|---|
| `InpMaxPositions` | `1` | `int` | Số vị thế đồng thời tối đa của magic này. |
| `InpEquityBreakerPct` | `20.0` | `double` | Chốt dừng khi drawdown từ đỉnh equity chạm ngưỡng này. **Có latch** — không tự mở lại. |
| `InpResetBreaker` | `false` | `bool` | Đặt `true` **một lần** để gỡ latch thủ công, sau đó trả về `false`. |
| `InpDailyLossLimitPct` | `5.0` | `double` | Ngừng vào lệnh mới khi lỗ trong ngày chạm ngưỡng. `0` = tắt. |
| `InpCooldownBars` | `3` | `int` | Số nến chờ sau một lệnh bị quét SL. `0` = tắt. |

### ==== Operational Filters ====

| Input | Mặc Định | Kiểu | Mô tả |
|---|---|---|---|
| `InpMaxSpreadPoints` | `30` | `int` | Bỏ qua vào lệnh khi spread vượt ngưỡng. `0` = tắt. |
| `InpMaxGapPoints` | `200` | `int` | Bỏ qua vào lệnh khi nến mở có gap lớn hơn ngưỡng. `0` = tắt. |
| `InpUseSessionFilter` | `false` | `bool` | Bật giới hạn khung giờ giao dịch. |
| `InpSessionStartHourUtc` | `7` | `int` | `[InpUseSessionFilter=true]` Giờ bắt đầu phiên, **theo UTC**. |
| `InpSessionEndHourUtc` | `20` | `int` | `[InpUseSessionFilter=true]` Giờ kết thúc phiên, **theo UTC**. Nhỏ hơn giờ bắt đầu thì cửa sổ vắt qua nửa đêm. |

### ==== Execution ====

| Input | Mặc Định | Kiểu | Mô tả |
|---|---|---|---|
| `InpSlippagePoints` | `10` | `int` | Độ trượt giá tối đa chấp nhận, tính bằng point. |

> Bảng này và file `.set` phải luôn khớp nhau. Sửa một bên thì sửa cả bên kia.

---

## 4. Chi tiết thuật toán

### Kích hoạt: theo nến, không theo tick

Quản lý rủi ro chạy **mỗi tick**; quyết định vào lệnh chỉ chạy **một lần mỗi nến
đóng**. Tín hiệu đọc từ nến `[1]` và `[2]` — **không bao giờ đọc `[0]`**, vì nến
đang hình thành sẽ vẽ lại và backtest sẽ không cho bạn thấy thiệt hại đó.

### Luồng OnTick

```
OnTick
 ├─ UpdateEquityPeakAndBreaker()        ← mỗi tick
 ├─ bar = iTime(...,0)
 ├─ nếu bar == g_lastBarTime → return   ← chưa sang nến mới
 ├─ đọc fast[1] fast[2] slow[1] slow[2] atr[1]
 │    └─ đọc hụt → return (CHƯA commit bar, thử lại tick sau)
 ├─ g_lastBarTime = bar                 ← commit sau khi mọi lần đọc thành công
 ├─ RollDailyAnchorIfNeeded()
 ├─ cổng chặn: halt → số vị thế → cooldown → lỗ ngày → bộ lọc vận hành
 ├─ signal = Signal(...)                ← >>> PHẦN BẠN THAY THẾ <<<
 └─ signal != 0 → OpenTrade(signal, atr)
```

Điểm tinh tế đáng chú ý: `g_lastBarTime` chỉ được commit **sau khi** toàn bộ
`CopyBuffer` thành công. Nếu commit trước, một lần đọc hụt tạm thời sẽ "đốt" mất
nến đó và tín hiệu bị bỏ qua vĩnh viễn trên nến ấy.

### Công thức SL/TP

```
minStop = SYMBOL_TRADE_STOPS_LEVEL * _Point
slDist  = max(ATR[1] * InpAtrSLMult, minStop + 3 * _Point)
tpDist  = slDist * InpRR

Lệnh BUY  (khớp tại ASK):  SL = ask - slDist   TP = ask + tpDist
Lệnh SELL (khớp tại BID):  SL = bid + slDist   TP = bid - tpDist
```

SL được **hard-code vào lệnh** ngay khi gửi — không phụ thuộc EA còn sống hay
không. Mỗi chiều đặt stop dựa trên chính giá nó khớp; trộn ask/bid sẽ làm lệch
mọi stop đi nửa spread.

### Công thức khối lượng

```
risk = equity * InpRiskPercent / 100
lot  = risk / (slDist / tickSize * tickValue)

nếu lot < SYMBOL_VOLUME_MIN → BỎ QUA lệnh (trả về 0.0)
ngược lại → làm tròn XUỐNG theo SYMBOL_VOLUME_STEP, kẹp trong [MIN, MAX]
```

Việc bỏ qua khi dưới lot tối thiểu xảy ra **trước** khi chuẩn hóa. Nếu kẹp lên
`VOLUME_MIN`, lệnh vẫn vào nhưng rủi ro thực đã vượt mức người dùng cấu hình —
và không ai biết.

---

## 5. Mô tả kỹ thuật

**Biến toàn cục trạng thái**

| Biến | Vai trò | Bền vững qua restart |
|---|---|---|
| `g_lastBarTime` | Cổng chặn nến mới | Không (tự dựng lại từ nến kế tiếp) |
| `g_equityPeak` | Đỉnh equity, chỉ tăng | Có — GlobalVariable |
| `g_halt` | Latch của equity breaker | Có — GlobalVariable |
| `g_dayStartEquity` | Mốc equity đầu ngày | Có — GlobalVariable |
| `g_dayAnchorDate` | Ngày mà mốc trên thuộc về | Có — GlobalVariable |
| `g_cooldownUntil` | Thời điểm hết cooldown | Không (mất khi restart, chấp nhận được) |

Khóa GlobalVariable có tiền tố `STARTER_<magic>_<symbol>_<period>` nên nhiều
instance trên cùng terminal không giẫm lên nhau.

**Handle chỉ báo**: `g_fastHandle`, `g_slowHandle`, `g_atrHandle` — tạo trong
`OnInit`, kiểm tra từng cái với `INVALID_HANDLE`, giải phóng có bảo vệ trong
`OnDeinit` và gán lại `INVALID_HANDLE`. Handle không giải phóng sẽ sống sót qua
recompile và rò rỉ.

---

## 6. Cấu hình khuyến nghị

| Mục | Giá trị |
|---|---|
| Symbol | Cặp có spread thấp (EURUSD, XAUUSD) |
| Khung thời gian | M15 |
| Loại tài khoản | Hedging hoặc Netting đều chạy được |
| Múi giờ | Bộ lọc phiên tính theo **UTC**, không theo giờ server |

Đây là cấu hình để *chạy thử bộ khung*, không phải cấu hình sinh lời.

---

## 7. Ghi chú rủi ro & backtest

> [!WARNING]
> Tín hiệu placeholder là EMA cross — một trong những tín hiệu bị whipsaw nặng
> nhất khi thị trường đi ngang. Kết quả backtest của bản `v1.00` này **không nói
> lên điều gì** về chiến lược của bạn.

**Chế độ backtest bắt buộc khi phát hành**: "Every Tick Based on Real Ticks",
tối thiểu 3 tháng, đúng khung thời gian sẽ chạy live. Chế độ "Open Prices Only"
thổi phồng tỷ lệ thắng 10–15% vì thứ tự chạm SL/TP trong nến bị giả lập — chỉ
dùng nó để lặp nhanh khi đang phát triển.

Bản `v1.00` **chưa có** backtest phát hành. Thư mục `backtest/` còn trống có
chủ đích: nó sẽ được điền khi bạn cắt phiên bản đầu tiên của *chiến lược bạn*.
