//+------------------------------------------------------------------+
//|                                             STARTER_EA_v1.00.mq5 |
//|            Starter EA — a correct-by-construction MQL5 skeleton  |
//+------------------------------------------------------------------+
//| WHAT THIS IS                                                     |
//|   A structural template, not a strategy. Every lifecycle, risk    |
//|   and safety mechanic a Koniverse EA must have is implemented and |
//|   correct. The ENTRY SIGNAL is a deliberately trivial placeholder |
//|   marked with  >>> REPLACE THIS <<<  — that is the one part you   |
//|   are meant to rewrite.                                           |
//|                                                                   |
//| DO NOT RUN THIS ON A REAL ACCOUNT AS-IS. The placeholder signal   |
//|   has no edge. It exists to show where your logic plugs in.       |
//|                                                                   |
//| Standard: koni-ea-dev. Release lifecycle: koni-ea-ops.            |
//+------------------------------------------------------------------+
#property version     "1.00"
#property description "Starter EA — structural skeleton with placeholder signal. Replace Signal(). M15."
#property copyright   "Your Name / Your Company"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| 1. INPUTS                                                        |
//+------------------------------------------------------------------+
input group "==== General ===="
input long   InpMagicNumber        = 990001;  // unique per running instance, must be > 0
input string InpTradeComment       = "STARTER_EA";  // order comment prefix

input group "==== Signal (REPLACE THIS SECTION) ===="
input int    InpFastPeriod         = 12;      // fast EMA period (placeholder signal)
input int    InpSlowPeriod         = 26;      // slow EMA period (placeholder signal)

input group "==== Position Sizing ===="
input bool   InpUseRiskPercent     = true;    // true = risk-% of equity, false = fixed lot
input double InpRiskPercent        = 1.0;     // [InpUseRiskPercent=true] risk per trade, % of equity
input double InpFixedLot           = 0.01;    // [InpUseRiskPercent=false] fixed lot size

input group "==== Stop Loss / Take Profit ===="
input int    InpAtrPeriod          = 14;      // ATR period used for SL distance
input double InpAtrSLMult          = 2.0;     // SL distance = ATR * this multiplier
input double InpRR                 = 1.5;     // TP distance = SL distance * this (reward:risk)

input group "==== Risk Management ===="
input int    InpMaxPositions       = 1;       // max concurrent positions for this magic
input double InpEquityBreakerPct   = 20.0;    // latched halt at this % drawdown from equity peak
input bool   InpResetBreaker       = false;   // set true once to manually clear a latched halt
input double InpDailyLossLimitPct  = 5.0;     // block new entries after this % daily loss (0 = off)
input int    InpCooldownBars       = 3;       // bars to wait after an SL-closed trade (0 = off)

input group "==== Operational Filters ===="
input int    InpMaxSpreadPoints    = 30;      // skip entry when spread exceeds this (0 = off)
input int    InpMaxGapPoints       = 200;     // skip entry on an open gap this large (0 = off)
input bool   InpUseSessionFilter   = false;   // restrict trading to a UTC hour window
input int    InpSessionStartHourUtc= 7;       // [InpUseSessionFilter=true] session start hour, UTC
input int    InpSessionEndHourUtc  = 20;      // [InpUseSessionFilter=true] session end hour, UTC

input group "==== Execution ===="
input int    InpSlippagePoints     = 10;      // max deviation in points

//+------------------------------------------------------------------+
//| 2. GLOBALS                                                       |
//+------------------------------------------------------------------+
CTrade   g_trade;

int      g_fastHandle    = INVALID_HANDLE;
int      g_slowHandle    = INVALID_HANDLE;
int      g_atrHandle     = INVALID_HANDLE;

datetime g_lastBarTime   = 0;      // new-bar gate, committed only after successful reads
double   g_equityPeak    = 0.0;    // ratchets upward, persisted
bool     g_halt          = false;  // latched equity breaker, persisted
double   g_dayStartEquity= 0.0;    // daily-loss anchor, persisted
datetime g_dayAnchorDate = 0;      // the day g_dayStartEquity belongs to
datetime g_cooldownUntil = 0;      // no entries before this bar time

string   g_gvPrefix      = "";     // GlobalVariable key prefix, built in OnInit

//+------------------------------------------------------------------+
//| 3. LIFECYCLE                                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- 3.1 validate inputs -----------------------------------------
   if(!ValidateInputs())
      return(INIT_PARAMETERS_INCORRECT);

   //--- 3.2 create indicator handles, check every one ---------------
   g_fastHandle = iMA(_Symbol, _Period, InpFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   g_slowHandle = iMA(_Symbol, _Period, InpSlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   g_atrHandle  = iATR(_Symbol, _Period, InpAtrPeriod);

   if(g_fastHandle == INVALID_HANDLE ||
      g_slowHandle == INVALID_HANDLE ||
      g_atrHandle  == INVALID_HANDLE)
   {
      Print("[INIT] failed to create an indicator handle");
      return(INIT_FAILED);
   }

   //--- 3.3 configure CTrade ----------------------------------------
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(InpSlippagePoints);
   g_trade.SetTypeFillingBySymbol(_Symbol);

   //--- 3.4 recover state that must survive a restart ---------------
   g_gvPrefix = StringFormat("STARTER_%I64d_%s_%d", InpMagicNumber, _Symbol, (int)_Period);
   RecoverState();

   //--- 3.5 prove which instance started -----------------------------
   PrintFormat("[INIT] %s %s magic=%I64d equityPeak=%.2f halt=%s",
               _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period), InpMagicNumber,
               g_equityPeak, (g_halt ? "true" : "false"));

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   PersistState();

   if(g_fastHandle != INVALID_HANDLE) { IndicatorRelease(g_fastHandle); g_fastHandle = INVALID_HANDLE; }
   if(g_slowHandle != INVALID_HANDLE) { IndicatorRelease(g_slowHandle); g_slowHandle = INVALID_HANDLE; }
   if(g_atrHandle  != INVALID_HANDLE) { IndicatorRelease(g_atrHandle);  g_atrHandle  = INVALID_HANDLE; }

   Comment("");
}

//+------------------------------------------------------------------+
//| OnTick — Shape A: manage every tick, enter on a closed bar        |
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateEquityPeakAndBreaker();          // risk latches run every tick

   //--- new-bar gate: PEEK here, COMMIT only after every read succeeds
   datetime bar = iTime(_Symbol, _Period, 0);
   if(bar == g_lastBarTime)
      return;

   //--- read every value this bar needs BEFORE committing the bar ----
   double fast1, fast2, slow1, slow2, atr1;
   if(!BufferValue(g_fastHandle, 1, fast1) || !BufferValue(g_fastHandle, 2, fast2) ||
      !BufferValue(g_slowHandle, 1, slow1) || !BufferValue(g_slowHandle, 2, slow2) ||
      !BufferValue(g_atrHandle,  1, atr1))
      return;                             // short read — bar NOT committed, retry next tick

   g_lastBarTime = bar;                   // commit: this bar is now processed

   //--- once-per-bar housekeeping ------------------------------------
   RollDailyAnchorIfNeeded();

   //--- entry gates ---------------------------------------------------
   if(g_halt && !InpResetBreaker)                return;
   if(CountMyPositions() >= InpMaxPositions)     return;
   if(TimeCurrent() < g_cooldownUntil)           return;
   if(!PassesDailyLossLimit())                   return;
   if(!PassesOperationalFilters())               return;

   int signal = Signal(fast1, fast2, slow1, slow2);
   if(signal != 0)
      OpenTrade(signal, atr1);
}

//+------------------------------------------------------------------+
//| 4. SIGNAL  >>> REPLACE THIS <<<                                  |
//+------------------------------------------------------------------+
//| This is the ONLY function you are expected to rewrite. Everything |
//| else in this file is infrastructure that should stay as it is.    |
//|                                                                   |
//| Contract you must honour when you replace it:                     |
//|   - Read CLOSED bars only. Index [1] is the last closed bar and   |
//|     [2] the one before it. NEVER read index [0] — the forming bar |
//|     repaints and a backtest will not show you the damage.         |
//|   - Return +1 to go long, -1 to go short, 0 to stand aside.       |
//|   - Do not place orders here. Do not mutate global state here.    |
//|     Keep it a pure decision so it stays testable.                 |
//|                                                                   |
//| The placeholder below is a naive EMA cross. It has no edge and is |
//| here only to make the wiring visible end to end.                  |
//+------------------------------------------------------------------+
int Signal(const double fast1, const double fast2,
           const double slow1, const double slow2)
{
   //=================== REPLACE FROM HERE ==========================
   bool crossedUp   = (fast2 <= slow2) && (fast1 > slow1);
   bool crossedDown = (fast2 >= slow2) && (fast1 < slow1);

   if(crossedUp)   return(1);
   if(crossedDown) return(-1);
   return(0);
   //==================== REPLACE TO HERE ===========================
}

//+------------------------------------------------------------------+
//| 5. ENTRY                                                         |
//+------------------------------------------------------------------+
void OpenTrade(const int direction, const double atr)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0)
   {
      Print("[ENTRY] no valid quote — skipping");
      return;
   }

   //--- SL distance, clamped to the broker minimum -------------------
   double minStop = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double slDist  = MathMax(atr * InpAtrSLMult, minStop + 3 * _Point);
   double tpDist  = slDist * InpRR;

   //--- size the position --------------------------------------------
   double lot = CalcLotSize(slDist);
   if(lot <= 0.0)
      return;                              // CalcLotSize already logged the reason

   //--- margin PRE-check, never post-check ---------------------------
   if(!PassesMarginPreCheck(direction, lot, (direction > 0 ? ask : bid)))
      return;

   //--- base each side's stops on the price it actually fills at -----
   double sl, tp;
   bool   ok;

   if(direction > 0)
   {
      sl = NormalizeDouble(ask - slDist, _Digits);
      tp = NormalizeDouble(ask + tpDist, _Digits);
      ok = g_trade.Buy(lot, _Symbol, 0.0, sl, tp, InpTradeComment);
   }
   else
   {
      sl = NormalizeDouble(bid + slDist, _Digits);
      tp = NormalizeDouble(bid - tpDist, _Digits);
      ok = g_trade.Sell(lot, _Symbol, 0.0, sl, tp, InpTradeComment);
   }

   //--- the boolean is NOT the verdict — the retcode is --------------
   if(!ok || g_trade.ResultRetcode() != TRADE_RETCODE_DONE)
   {
      PrintFormat("[ENTRY] failed dir=%d lot=%.2f retcode=%d %s",
                  direction, lot, g_trade.ResultRetcode(),
                  g_trade.ResultRetcodeDescription());
      return;
   }

   PrintFormat("[ENTRY] %s lot=%.2f sl=%.*f tp=%.*f ticket=%I64u",
               (direction > 0 ? "BUY" : "SELL"), lot,
               _Digits, sl, _Digits, tp, g_trade.ResultOrder());
}

//+------------------------------------------------------------------+
//| 6. POSITION SIZING                                               |
//+------------------------------------------------------------------+
double CalcLotSize(const double slDistPrice)
{
   if(!InpUseRiskPercent)
      return(NormLot(InpFixedLot));

   double tickVal  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickVal <= 0.0 || tickSize <= 0.0 || slDistPrice <= 0.0)
   {
      Print("[SIZE] invalid tick value/size or SL distance — skipping");
      return(0.0);
   }

   double risk = AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskPercent / 100.0;
   double lot  = risk / (slDistPrice / tickSize * tickVal);

   //--- skip BEFORE NormLot: clamping up to VOLUME_MIN would silently
   //--- break the risk contract the user configured.
   if(lot < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
   {
      PrintFormat("[SIZE] risk %.2f%% too small for one min-lot — skipping trade", InpRiskPercent);
      return(0.0);
   }

   return(NormLot(lot));
}

double NormLot(double lot)
{
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double lo   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double hi   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0.0)
      return(0.0);

   lot = MathFloor(lot / step) * step;       // round DOWN — never exceed the risk budget
   int digits = (int)MathRound(-MathLog10(step));
   return(NormalizeDouble(MathMax(lo, MathMin(hi, lot)), digits));
}

//+------------------------------------------------------------------+
//| 7. RISK GUARDS                                                   |
//+------------------------------------------------------------------+
void UpdateEquityPeakAndBreaker()
{
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq <= 0.0)
      return;

   if(eq > g_equityPeak)
      g_equityPeak = eq;

   if(g_equityPeak <= 0.0)
      return;

   double ddPct = (g_equityPeak - eq) / g_equityPeak * 100.0;
   if(ddPct >= InpEquityBreakerPct && !g_halt)
   {
      g_halt = true;                          // LATCH — only InpResetBreaker clears it
      PersistState();
      PrintFormat("[BREAKER] latched at %.2f%% drawdown (peak=%.2f equity=%.2f)",
                  ddPct, g_equityPeak, eq);
   }
}

bool PassesDailyLossLimit()
{
   if(InpDailyLossLimitPct <= 0.0 || g_dayStartEquity <= 0.0)
      return(true);

   double eq        = AccountInfoDouble(ACCOUNT_EQUITY);
   double dayPnlPct = (eq - g_dayStartEquity) / g_dayStartEquity * 100.0;

   if(dayPnlPct <= -InpDailyLossLimitPct)
   {
      PrintFormat("[DAILY-LOSS] %.2f%% — no more entries today", dayPnlPct);
      return(false);
   }
   return(true);
}

void RollDailyAnchorIfNeeded()
{
   MqlDateTime t;
   TimeToStruct(TimeCurrent(), t);
   t.hour = 0; t.min = 0; t.sec = 0;
   datetime today = StructToTime(t);

   if(today != g_dayAnchorDate)
   {
      g_dayAnchorDate  = today;
      g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      PersistState();
      PrintFormat("[DAY] anchor rolled — start equity %.2f", g_dayStartEquity);
   }
}

bool PassesMarginPreCheck(const int direction, const double lot, const double price)
{
   //--- an over-max lot is REJECTED by the server, never silently reduced
   if(lot > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX))
   {
      Print("[MARGIN] lot exceeds VOLUME_MAX — blocking entry");
      return(false);
   }

   double margin = 0.0;
   ENUM_ORDER_TYPE type = (direction > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);

   if(!OrderCalcMargin(type, _Symbol, lot, price, margin))
   {
      //--- FAIL-PERMISSIVE: the check itself could not run (e.g. symbol not in
      //--- MarketWatch). Log and allow — the broker still rejects an
      //--- unaffordable fill. Never leave this branch empty.
      PrintFormat("[MARGIN] OrderCalcMargin failed: %d — allowing placement", GetLastError());
      return(true);
   }

   if(margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   {
      //--- the check RAN and said no → block
      PrintFormat("[MARGIN] need %.2f, free %.2f — blocking entry",
                  margin, AccountInfoDouble(ACCOUNT_MARGIN_FREE));
      return(false);
   }

   return(true);
}

//+------------------------------------------------------------------+
//| 8. OPERATIONAL FILTERS                                           |
//+------------------------------------------------------------------+
bool PassesOperationalFilters()
{
   //--- spread ---------------------------------------------------------
   if(InpMaxSpreadPoints > 0)
   {
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread > InpMaxSpreadPoints)
      {
         PrintFormat("[FILTER] spread %d > %d — skipping", (int)spread, InpMaxSpreadPoints);
         return(false);
      }
   }

   //--- open gap -------------------------------------------------------
   if(InpMaxGapPoints > 0)
   {
      double gap = MathAbs(iOpen(_Symbol, _Period, 0) - iClose(_Symbol, _Period, 1)) / _Point;
      if(gap > InpMaxGapPoints)
      {
         PrintFormat("[FILTER] gap %.0f pts > %d — skipping", gap, InpMaxGapPoints);
         return(false);
      }
   }

   //--- session window, in UTC so it is reproducible across brokers ----
   if(InpUseSessionFilter)
   {
      MqlDateTime utc;
      TimeToStruct(TimeGMT(), utc);
      int h = utc.hour;
      bool inWindow;

      if(InpSessionStartHourUtc <= InpSessionEndHourUtc)
         inWindow = (h >= InpSessionStartHourUtc && h < InpSessionEndHourUtc);
      else
         inWindow = (h >= InpSessionStartHourUtc || h < InpSessionEndHourUtc);  // wraps midnight

      if(!inWindow)
         return(false);
   }

   return(true);
}

//+------------------------------------------------------------------+
//| 9. POSITION QUERIES (always filter by symbol AND magic)          |
//+------------------------------------------------------------------+
int CountMyPositions()
{
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)     // downward: closing reindexes
   {
      ulong ticket = PositionGetTicket(i);            // selects as it returns
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      n++;
   }
   return(n);
}

//+------------------------------------------------------------------+
//| 10. INDICATOR READS                                              |
//+------------------------------------------------------------------+
//| bool + out-param, never a bare double: a short read must be       |
//| distinguishable from a legitimate 0.0, or the caller cannot honour |
//| "commit the bar only after every read succeeded".                 |
//+------------------------------------------------------------------+
bool BufferValue(const int handle, const int shift, double &out)
{
   double buf[];
   ArraySetAsSeries(buf, true);              // NOT the default — [0] would be oldest
   if(CopyBuffer(handle, 0, shift, 1, buf) < 1)
      return(false);
   out = buf[0];
   return(true);
}

//+------------------------------------------------------------------+
//| 11. STATE PERSISTENCE & RECOVERY                                 |
//+------------------------------------------------------------------+
//| A recompile, restart or parameter change wipes memory while       |
//| positions stay open. Latches must outlive the process.            |
//+------------------------------------------------------------------+
void PersistState()
{
   GlobalVariableSet(g_gvPrefix + "_peak",  g_equityPeak);
   GlobalVariableSet(g_gvPrefix + "_halt",  (g_halt ? 1.0 : 0.0));
   GlobalVariableSet(g_gvPrefix + "_dayEq", g_dayStartEquity);
   GlobalVariableSet(g_gvPrefix + "_dayAt", (double)g_dayAnchorDate);
}

void RecoverState()
{
   if(GlobalVariableCheck(g_gvPrefix + "_peak"))
      g_equityPeak = GlobalVariableGet(g_gvPrefix + "_peak");
   if(g_equityPeak <= 0.0)
      g_equityPeak = AccountInfoDouble(ACCOUNT_EQUITY);

   if(GlobalVariableCheck(g_gvPrefix + "_halt"))
      g_halt = (GlobalVariableGet(g_gvPrefix + "_halt") > 0.5);

   //--- an explicit manual reset clears the latch, then disarms itself
   if(g_halt && InpResetBreaker)
   {
      g_halt       = false;
      g_equityPeak = AccountInfoDouble(ACCOUNT_EQUITY);
      Print("[BREAKER] manually reset — set InpResetBreaker back to false");
   }

   if(GlobalVariableCheck(g_gvPrefix + "_dayEq"))
      g_dayStartEquity = GlobalVariableGet(g_gvPrefix + "_dayEq");
   if(GlobalVariableCheck(g_gvPrefix + "_dayAt"))
      g_dayAnchorDate = (datetime)GlobalVariableGet(g_gvPrefix + "_dayAt");

   PersistState();
}

//+------------------------------------------------------------------+
//| 12. TRADE EVENTS — cooldown after a stop-out                     |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest    &request,
                        const MqlTradeResult     &result)
{
   if(InpCooldownBars <= 0)
      return;
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;
   if(!HistoryDealSelect(trans.deal))
      return;
   if(HistoryDealGetInteger(trans.deal, DEAL_MAGIC)  != InpMagicNumber)
      return;
   if(HistoryDealGetString (trans.deal, DEAL_SYMBOL) != _Symbol)
      return;
   if(HistoryDealGetInteger(trans.deal, DEAL_ENTRY)  != DEAL_ENTRY_OUT)
      return;
   if(HistoryDealGetInteger(trans.deal, DEAL_REASON) != DEAL_REASON_SL)
      return;

   g_cooldownUntil = TimeCurrent() + (datetime)(InpCooldownBars * PeriodSeconds(_Period));
   PrintFormat("[COOLDOWN] stop-out — no entries until %s", TimeToString(g_cooldownUntil));
}

//+------------------------------------------------------------------+
//| 13. INPUT VALIDATION                                             |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
   if(InpMagicNumber <= 0)
   {
      Print("[INIT] InpMagicNumber must be > 0 and unique per instance");
      return(false);
   }
   if(InpFastPeriod <= 0 || InpSlowPeriod <= 0 || InpFastPeriod >= InpSlowPeriod)
   {
      Print("[INIT] require 0 < InpFastPeriod < InpSlowPeriod");
      return(false);
   }
   if(InpAtrPeriod <= 0)
   {
      Print("[INIT] InpAtrPeriod must be > 0");
      return(false);
   }
   if(InpAtrSLMult <= 0.0 || InpRR <= 0.0)
   {
      Print("[INIT] InpAtrSLMult and InpRR must be > 0");
      return(false);
   }
   if(InpUseRiskPercent && (InpRiskPercent <= 0.0 || InpRiskPercent > 100.0))
   {
      Print("[INIT] InpRiskPercent must be in (0, 100]");
      return(false);
   }
   if(!InpUseRiskPercent && InpFixedLot <= 0.0)
   {
      Print("[INIT] InpFixedLot must be > 0");
      return(false);
   }
   if(InpMaxPositions <= 0)
   {
      Print("[INIT] InpMaxPositions must be >= 1");
      return(false);
   }
   if(InpEquityBreakerPct <= 0.0 || InpEquityBreakerPct > 100.0)
   {
      Print("[INIT] InpEquityBreakerPct must be in (0, 100]");
      return(false);
   }
   if(InpUseSessionFilter &&
      (InpSessionStartHourUtc < 0 || InpSessionStartHourUtc > 23 ||
       InpSessionEndHourUtc   < 0 || InpSessionEndHourUtc   > 23))
   {
      Print("[INIT] session hours must be in [0, 23] UTC");
      return(false);
   }
   return(true);
}
//+------------------------------------------------------------------+
