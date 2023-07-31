//+------------------------------------------------------------------+
//|                                            AR_Super_Fractal.mq5  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property version   "1.01"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
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

// -- indicator inputs
input int inp_fractalShoulder = 2; // Fractal Shoulder (candles on each side)
input int ExtArrowShift = 10; // Fractal Offset (empty space)

//---- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- arrow shifts when drawing

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-1*ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,ExtArrowShift);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initialization done
  }

//+------------------------------------------------------------------+
//|  Accelerator/Decelerator Oscillator                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i,limit;
   int fractalShoulder = inp_fractalShoulder;
//---
   if(rates_total<fractalShoulder * 2 + 1)
      return(0);
//---
   if(prev_calculated<fractalShoulder * 2 + 3)
     {
      limit=fractalShoulder;
      //--- clean up arrays
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
     }
   else
      limit=rates_total-(fractalShoulder * 2 + 1);

   for(i=limit; i<rates_total-(fractalShoulder+1) && !IsStopped(); i++)
     {
      //---- Upper Fractal

      double highs[];
      double lows[];

      bool upperFractal = false;

      for(int j = 1; j<=fractalShoulder; j++)
        {
         highs.Push(High[i+j]);
         highs.Push(High[i-j]);
         lows.Push(Low[i+j]);
         lows.Push(Low[i-j]);
        }

      double max_high = highs[ArrayMaximum(highs)];
      double min_low = lows[ArrayMinimum(lows)];

      if(High[i] > max_high)
        {
         ExtUpperBuffer[i]=High[i];
        }
      else
         ExtUpperBuffer[i]=EMPTY_VALUE;


      if(Low[i] < min_low)
        {
         ExtLowerBuffer[i]=Low[i];
        }
      else
         ExtLowerBuffer[i]=EMPTY_VALUE;

     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
