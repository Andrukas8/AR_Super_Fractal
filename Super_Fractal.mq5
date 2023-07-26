//+------------------------------------------------------------------+
//|                                            AR_Super_Fractal.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Andrukas8"
#property link      "https://github.com/Andrukas8/AR_Super_Fractal"
#property version   "1.01"
#property indicator_chart_window

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

// -- indicator inputs
input int inp_fractalShoulder = 2; // Fractal Shoulder (candles on each side)
input int fractal_offset = 10; // Fractal Offset (empty space)

//--- Bearish Fractal
#property indicator_label1  "Bearish Fractal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Bullish Fractal
#property indicator_label2  "Bullish Fractal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- indicator buffers
double BufferUP[];
double BufferDN[];
int fractalShoulder;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,217); // Arrow up
   PlotIndexSetInteger(1,PLOT_ARROW,218); // Arrow Down
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-1*fractal_offset);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,fractal_offset);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SuperFractal");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {


// --- Checking if Fractal Shoulder integer is valid
   if(inp_fractalShoulder <= 0)
     {
      fractalShoulder = 1;
     }
   else
     {
      fractalShoulder = inp_fractalShoulder;
     }


//--- Checking the minimum number of bars for calculation

   if(rates_total<fractalShoulder)
      return 0;

//--- Checking and calculating the number of bars
   int limit=rates_total-prev_calculated;

   if(limit>1)
     {
      limit=rates_total - fractalShoulder - 1;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
     }
//--- Indexing arrays as timeseries
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- Calculating the indicator

   for(int i=limit; i>=fractalShoulder && !IsStopped(); i--)
     {
      bool frac_bull=false;
      bool frac_bear=false;

      double highs[];
      double lows[];

      double max_high;
      double min_low;

      for(int j=1; j<=fractalShoulder; j++)
        {
         highs.Push(high[i+j]);
         highs.Push(high[i-j]);
         lows.Push(low[i+j]);
         lows.Push(low[i-j]);
        }

      max_high = highs[ArrayMaximum(highs)];
      min_low = lows[ArrayMinimum(lows)];

      if(high[i] > max_high)
        {
         frac_bull = true;
        }

      if(low[i] < min_low)
        {
         frac_bear = true;
        }

      //--- Fractals

      if(frac_bull)
        {
         BufferUP[i]=high[i];
        }

      else
         BufferUP[i]=EMPTY_VALUE;

      if(frac_bear)
        {
         BufferDN[i]=low[i];
        }

      else
         BufferDN[i]=EMPTY_VALUE;
     }

//--- return value of prev_calculated for next call
   return(rates_total);

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
