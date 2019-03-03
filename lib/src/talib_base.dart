library talib;

import 'dart:math' as math;
import 'dart:core';


T exceptionAware<T>(T Function() f) {
   try { 
     return f(); 
   } catch(_) { 
     return null; 
    }
   }

enum MaType {
  SMA,
  EMA,
  WMA,
  DEMA,
  TEMA,
  TRIMA,
  KAMA,
  MAMA,
  T3MA,
}

class moneyFlow {
  double positive;
  double negative;

  moneyFlow({positive, negative}) {
    this.positive = positive;
    this.negative = negative;
  }
}

List BBands(List inReal, int inTimePeriod, double inNbDevUp, double inNbDevDn,
    MaType inMAType) {
  var outRealUpperBand = new List(inReal.length);
  var outRealMiddleBand = Ma(inReal, inTimePeriod, inMAType);
  var outRealLowerBand = new List(inReal.length);
  var tempBuffer2 = StdDev(inReal, inTimePeriod, 1.0);
  if (inNbDevUp == inNbDevDn) {
    if (inNbDevUp == 1.0) {
      for (var i = 0; i < inReal.length; i++) {
        var tempReal = tempBuffer2.elementAt(i);
        var tempReal2 = outRealMiddleBand.elementAt(i);
        outRealUpperBand[i] = tempReal2 + tempReal;
        outRealLowerBand[i] = tempReal2 - tempReal;
      }
    } else {
      for (var i = 0; i < inReal.length; i++) {
        var tempReal = tempBuffer2.elementAt(i) * inNbDevUp;
        var tempReal2 = outRealMiddleBand.elementAt(i);
        outRealUpperBand[i] = tempReal2 + tempReal;
        outRealLowerBand[i] = tempReal2 - tempReal;
      }
    }
  } else if (inNbDevUp == 1.0) {
    for (var i = 0; i < inReal.length; i++) {
      var tempReal = tempBuffer2.elementAt(i);
      var tempReal2 = outRealMiddleBand.elementAt(i);
      outRealUpperBand[i] = tempReal2 + tempReal;
      outRealLowerBand[i] = tempReal2 - (tempReal * inNbDevDn);
    }
  } else if (inNbDevDn == 1.0) {
    for (var i = 0; i < inReal.length; i++) {
      var tempReal = tempBuffer2.elementAt(i);
      var tempReal2 = outRealMiddleBand.elementAt(i);
      outRealLowerBand[i] = tempReal2 - tempReal;
      outRealUpperBand[i] = tempReal2 + (tempReal * inNbDevUp);
    }
  } else {
    for (var i = 0; i < inReal.length; i++) {
      var tempReal = tempBuffer2.elementAt(i);
      var tempReal2 = outRealMiddleBand.elementAt(i);
      outRealUpperBand[i] = tempReal2 + (tempReal * inNbDevUp);
      outRealLowerBand[i] = tempReal2 - (tempReal * inNbDevDn);
    }
  }

  return [outRealUpperBand, outRealMiddleBand, outRealLowerBand];
}

List Dema(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var firstEMA = Ema(inReal, inTimePeriod);
  var secondEMA = Ema(
      firstEMA.sublist(
        inTimePeriod - 1,
      ),
      inTimePeriod);

  for (var outIdx = (inTimePeriod * 2) - 2, secondEMAIdx = inTimePeriod - 1;
      outIdx < inReal.length;
      outIdx = outIdx + 1, secondEMAIdx = secondEMAIdx + 1) {
    outReal[outIdx] =
        (2.0 * firstEMA.elementAt(outIdx)) - secondEMA.elementAt(secondEMAIdx);
  }
  return outReal;
}

List ema(List inReal, int inTimePeriod, double k1) {
  var outReal = new List(inReal.length);
  var lookbackTotal = inTimePeriod - 1;
  var startIdx = lookbackTotal;
  var today = startIdx - lookbackTotal;
  var i = inTimePeriod;
  var tempReal = 0.0;
  for (; i > 0;) {
    tempReal += inReal.elementAt(today);
    today++;
    i--;
  }
  var prevMA = tempReal / inTimePeriod;
  for (; today <= startIdx;) {
    prevMA = ((inReal.elementAt(today) - prevMA) * k1) + prevMA;
    today++;
  }
  outReal[startIdx] = prevMA;
  var outIdx = startIdx + 1;
  for (; today < inReal.length;) {
    prevMA = ((inReal.elementAt(today) - prevMA) * k1) + prevMA;
    outReal[outIdx] = prevMA;
    today++;
    outIdx++;
  }
  return outReal;
}

List Ema(List inReal, int inTimePeriod) {
  var k = 2.0 / inTimePeriod + 1;
  var outReal = ema(inReal, inTimePeriod, k);
  return outReal;
}

List HtTrendline(List inReal) {
  var outReal = new List(inReal.length);
  var a = 0.0962;
  var b = 0.5769;
  var detrenderOdd = new List(3);
  var detrenderEven = new List(3);
  var q1Odd = new List(3);
  var q1Even = new List(3);
  var jIOdd = new List(3);
  var jIEven = new List(3);
  var jQOdd = new List(3);
  var jQEven = new List(3);
  var smoothPriceIdx = 0;
  var maxIdxSmoothPrice = (50 - 1);
  var smoothPrice = new List(maxIdxSmoothPrice + 1);
  var iTrend1 = 0.0;
  var iTrend2 = 0.0;
  var iTrend3 = 0.0;
  var tempReal = math.atan(1);
  var rad2Deg = 45.0 / tempReal;
  var lookbackTotal = 63;
  var startIdx = lookbackTotal;
  var trailingWMAIdx = startIdx - lookbackTotal;
  var today = trailingWMAIdx;
  tempReal = inReal.elementAt(today);
  today++;
  var periodWMASub = tempReal;
  var periodWMASum = tempReal;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 2.0;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 3.0;
  var trailingWMAValue = 0.0;
  var i = 34;
  for (var ok = true; ok;) {
    tempReal = inReal.elementAt(today);
    today++;
    periodWMASub += tempReal;
    periodWMASub -= trailingWMAValue;
    periodWMASum += tempReal * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    periodWMASum -= periodWMASub;
    i--;
    ok = i != 0;
  }
  var hilbertIdx = 0;
  var detrender = 0.0;
  var prevDetrenderOdd = 0.0;
  var prevDetrenderEven = 0.0;
  var prevDetrenderInputOdd = 0.0;
  var prevDetrenderInputEven = 0.0;
  var q1 = 0.0;
  var prevq1Odd = 0.0;
  var prevq1Even = 0.0;
  var prevq1InputOdd = 0.0;
  var prevq1InputEven = 0.0;
  var jI = 0.0;
  var prevJIOdd = 0.0;
  var prevJIEven = 0.0;
  var prevJIInputOdd = 0.0;
  var prevJIInputEven = 0.0;
  var jQ = 0.0;
  var prevJQOdd = 0.0;
  var prevJQEven = 0.0;
  var prevJQInputOdd = 0.0;
  var prevJQInputEven = 0.0;
  var period = 0.0;
  var outIdx = 63;
  var previ2 = 0.0;
  var prevq2 = 0.0;
  var Re = 0.0;
  var Im = 0.0;
  var i1ForOddPrev3 = 0.0;
  var i1ForEvenPrev3 = 0.0;
  var i1ForOddPrev2 = 0.0;
  var i1ForEvenPrev2 = 0.0;
  var smoothPeriod = 0.0;
  var q2 = 0.0;
  var i2 = 0.0;
  for (; today < inReal.length;) {
    var adjustedPrevPeriod = (0.075 * period) + 0.54;
    var todayValue = inReal.elementAt(today);
    periodWMASub += todayValue;
    periodWMASub -= trailingWMAValue;
    periodWMASum += todayValue * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    var smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    smoothPrice[smoothPriceIdx] = smoothedValue;
    if ((today % 2) == 0) {
      var hilbertTempReal = a * smoothedValue;
      detrender = -detrenderEven.elementAt(hilbertIdx);
      detrenderEven[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderEven;
      prevDetrenderEven = b * prevDetrenderInputEven;
      detrender += prevDetrenderEven;
      prevDetrenderInputEven = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Even.elementAt(hilbertIdx);
      q1Even[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Even;
      prevq1Even = b * prevq1InputEven;
      q1 += prevq1Even;
      prevq1InputEven = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForEvenPrev3;
      jI = -jIEven.elementAt(hilbertIdx);
      jIEven[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIEven;
      prevJIEven = b * prevJIInputEven;
      jI += prevJIEven;
      prevJIInputEven = i1ForEvenPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQEven.elementAt(hilbertIdx);
      jQEven[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQEven;
      prevJQEven = b * prevJQInputEven;
      jQ += prevJQEven;
      prevJQInputEven = q1;
      jQ *= adjustedPrevPeriod;
      hilbertIdx++;
      if (hilbertIdx == 3) {
        hilbertIdx = 0;
      }

      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForEvenPrev3 - jQ)) + (0.8 * previ2);
      i1ForOddPrev3 = i1ForOddPrev2;
      i1ForOddPrev2 = detrender;
    } else {
      var hilbertTempReal = a * smoothedValue;
      detrender = -detrenderOdd.elementAt(hilbertIdx);
      detrenderOdd[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderOdd;
      prevDetrenderOdd = b * prevDetrenderInputOdd;
      detrender += prevDetrenderOdd;
      prevDetrenderInputOdd = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Odd.elementAt(hilbertIdx);
      q1Odd[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Odd;
      prevq1Odd = b * prevq1InputOdd;
      q1 += prevq1Odd;
      prevq1InputOdd = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForOddPrev3;
      jI = -jIOdd.elementAt(hilbertIdx);
      jIOdd[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIOdd;
      prevJIOdd = b * prevJIInputOdd;
      jI += prevJIOdd;
      prevJIInputOdd = i1ForOddPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQOdd.elementAt(hilbertIdx);
      jQOdd[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQOdd;
      prevJQOdd = b * prevJQInputOdd;
      jQ += prevJQOdd;
      prevJQInputOdd = q1;
      jQ *= adjustedPrevPeriod;
      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForOddPrev3 - jQ)) + (0.8 * previ2);
      i1ForEvenPrev3 = i1ForEvenPrev2;
      i1ForEvenPrev2 = detrender;
    }
    Re = (0.2 * ((i2 * previ2) + (q2 * prevq2))) + (0.8 * Re);
    Im = (0.2 * ((i2 * prevq2) - (q2 * previ2))) + (0.8 * Im);
    prevq2 = q2;
    previ2 = i2;
    tempReal = period;
    if ((Im != 0.0) && (Re != 0.0)) {
      period = 360.0 / (math.atan(Im / Re) * rad2Deg);
    }

    var tempReal2 = 1.5 * tempReal;
    if (period > tempReal2) {
      period = tempReal2;
    }

    tempReal2 = 0.67 * tempReal;
    if (period < tempReal2) {
      period = tempReal2;
    }

    if (period < 6) {
      period = 6;
    } else if (period > 50) {
      period = 50;
    }

    period = (0.2 * period) + (0.8 * tempReal);
    smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod);
    var DCPeriod = smoothPeriod + 0.5;
    var DCPeriodInt = DCPeriod.floor();
    var idx = today;
    tempReal = 0.0;
    for (var i = 0; i < DCPeriodInt; i++) {
      tempReal += inReal.elementAt(idx);
      idx--;
    }
    if (DCPeriodInt > 0) {
      tempReal = tempReal / (DCPeriodInt * 1.0);
    }

    tempReal2 =
        (4.0 * tempReal + 3.0 * iTrend1 + 2.0 * iTrend2 + iTrend3) / 10.0;
    iTrend3 = iTrend2;
    iTrend2 = iTrend1;
    iTrend1 = tempReal;
    if (today >= startIdx) {
      outReal[outIdx] = tempReal2;
      outIdx++;
    }

    smoothPriceIdx++;
    if (smoothPriceIdx > maxIdxSmoothPrice) {
      smoothPriceIdx = 0;
    }

    today++;
  }
  return outReal;
}

List Kama(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var constMax = 2.0 / (30.0 + 1.0);
  var constDiff = 2.0 / (2.0 + 1.0) - constMax;
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var sumROC1 = 0.0;
  var today = startIdx - lookbackTotal;
  var trailingIdx = today;
  var i = inTimePeriod;
  for (; i > 0;) {
    var tempReal = inReal.elementAt(today);
    today++;
    tempReal -= inReal.elementAt(today);
    sumROC1 += tempReal.abs();
    i--;
  }
  var prevKAMA = inReal.elementAt(today - 1);
  var tempReal = inReal.elementAt(today);
  var tempReal2 = inReal.elementAt(trailingIdx);
  trailingIdx++;
  var periodROC = tempReal - tempReal2;
  var trailingValue = tempReal2;
  if ((sumROC1 <= periodROC) ||
      (((-(0.00000000000001)) < sumROC1) && (sumROC1 < (0.00000000000001)))) {
    tempReal = 1.0;
  } else {
    tempReal = (periodROC / sumROC1).abs();
  }
  tempReal = (tempReal * constDiff) + constMax;
  tempReal *= tempReal;
  prevKAMA = ((inReal.elementAt(today) - prevKAMA) * tempReal) + prevKAMA;
  today++;
  for (; today <= startIdx;) {
    tempReal = inReal.elementAt(today);
    tempReal2 = inReal.elementAt(trailingIdx);
    trailingIdx++;
    periodROC = tempReal - tempReal2;
    sumROC1 -= (trailingValue - tempReal2).abs();
    sumROC1 += (tempReal - inReal.elementAt(today - 1)).abs();
    trailingValue = tempReal2;
    if ((sumROC1 <= periodROC) ||
        (((-(0.00000000000001)) < sumROC1) && (sumROC1 < (0.00000000000001)))) {
      tempReal = 1.0;
    } else {
      tempReal = (periodROC / sumROC1).abs();
    }
    tempReal = (tempReal * constDiff) + constMax;
    tempReal *= tempReal;
    prevKAMA = ((inReal.elementAt(today) - prevKAMA) * tempReal) + prevKAMA;
    today++;
  }
  outReal[inTimePeriod] = prevKAMA;
  var outIdx = inTimePeriod + 1;
  for (; today < inReal.length;) {
    tempReal = inReal.elementAt(today);
    tempReal2 = inReal.elementAt(trailingIdx);
    trailingIdx++;
    periodROC = tempReal - tempReal2;
    sumROC1 -= (trailingValue - tempReal2).abs();
    sumROC1 += (tempReal - inReal.elementAt(today - 1)).abs();
    trailingValue = tempReal2;
    if ((sumROC1 <= periodROC) ||
        (((-(0.00000000000001)) < sumROC1) && (sumROC1 < (0.00000000000001)))) {
      tempReal = 1.0;
    } else {
      tempReal = (periodROC / sumROC1).abs();
    }
    tempReal = (tempReal * constDiff) + constMax;
    tempReal *= tempReal;
    prevKAMA = ((inReal.elementAt(today) - prevKAMA) * tempReal) + prevKAMA;
    today++;
    outReal[outIdx] = prevKAMA;
    outIdx++;
  }
  return outReal;
}

List Ma(List inReal, int inTimePeriod, MaType inMAType) {
  var outReal = new List(inReal.length);
  if (inTimePeriod == 1) {
    outReal = List.from(inReal);
    return outReal;
  }
  switch (inMAType) {
    case MaType.SMA:
      outReal = Sma(inReal, inTimePeriod);
      break;
    case MaType.EMA:
      outReal = Ema(inReal, inTimePeriod);
      break;
    case MaType.WMA:
      outReal = Wma(inReal, inTimePeriod);
      break;
    case MaType.DEMA:
      outReal = Dema(inReal, inTimePeriod);
      break;
    case MaType.TEMA:
      outReal = Tema(inReal, inTimePeriod);
      break;
    case MaType.TRIMA:
      outReal = Trima(inReal, inTimePeriod);
      break;
    case MaType.KAMA:
      outReal = Kama(inReal, inTimePeriod);
      break;
    case MaType.MAMA:
      var tmpList = Mama(inReal, 0.5, 0.05);
      outReal = tmpList[0];
      ;
      break;
    case MaType.T3MA:
      outReal = T3(inReal, inTimePeriod, 0.7);
      break;
  }
  return outReal;
}

List Mama(List inReal, double inFastLimit, double inSlowLimit) {
  var outMAMA = new List(inReal.length);
  var outFAMA = new List(inReal.length);
  var a = 0.0962;
  var b = 0.5769;
  var detrenderOdd = new List(3);
  var detrenderEven = new List(3);
  var q1Odd = new List(3);
  var q1Even = new List(3);
  var jIOdd = new List(3);
  var jIEven = new List(3);
  var jQOdd = new List(3);
  var jQEven = new List(3);
  var rad2Deg = 180.0 / (4.0 * math.atan(1));
  var lookbackTotal = 32;
  var startIdx = lookbackTotal;
  var trailingWMAIdx = startIdx - lookbackTotal;
  var today = trailingWMAIdx;
  var tempReal = inReal.elementAt(today);
  today++;
  var periodWMASub = tempReal;
  var periodWMASum = tempReal;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 2.0;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 3.0;
  var trailingWMAValue = 0.0;
  var i = 9;
  var smoothedValue = 0.0;
  for (var ok = true; ok;) {
    tempReal = inReal.elementAt(today);
    today++;
    periodWMASub += tempReal;
    periodWMASub -= trailingWMAValue;
    periodWMASum += tempReal * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    i--;
    ok = i != 0;
  }
  var hilbertIdx = 0;
  detrenderOdd[0] = 0.0;
  detrenderOdd[1] = 0.0;
  detrenderOdd[2] = 0.0;
  detrenderEven[0] = 0.0;
  detrenderEven[1] = 0.0;
  detrenderEven[2] = 0.0;
  var detrender = 0.0;
  var prevDetrenderOdd = 0.0;
  var prevDetrenderEven = 0.0;
  var prevDetrenderInputOdd = 0.0;
  var prevDetrenderInputEven = 0.0;
  q1Odd[0] = 0.0;
  q1Odd[1] = 0.0;
  q1Odd[2] = 0.0;
  q1Even[0] = 0.0;
  q1Even[1] = 0.0;
  q1Even[2] = 0.0;
  var q1 = 0.0;
  var prevq1Odd = 0.0;
  var prevq1Even = 0.0;
  var prevq1InputOdd = 0.0;
  var prevq1InputEven = 0.0;
  jIOdd[0] = 0.0;
  jIOdd[1] = 0.0;
  jIOdd[2] = 0.0;
  jIEven[0] = 0.0;
  jIEven[1] = 0.0;
  jIEven[2] = 0.0;
  var jI = 0.0;
  var prevjIOdd = 0.0;
  var prevjIEven = 0.0;
  var prevjIInputOdd = 0.0;
  var prevjIInputEven = 0.0;
  jQOdd[0] = 0.0;
  jQOdd[1] = 0.0;
  jQOdd[2] = 0.0;
  jQEven[0] = 0.0;
  jQEven[1] = 0.0;
  jQEven[2] = 0.0;
  var jQ = 0.0;
  var prevjQOdd = 0.0;
  var prevjQEven = 0.0;
  var prevjQInputOdd = 0.0;
  var prevjQInputEven = 0.0;
  var period = 0.0;
  var outIdx = startIdx;
  var previ2 = 0.0;
  var prevq2 = 0.0;
  var Re = 0.0;
  var Im = 0.0;
  var mama = 0.0;
  var fama = 0.0;
  var i1ForOddPrev3 = 0.0;
  var i1ForEvenPrev3 = 0.0;
  var i1ForOddPrev2 = 0.0;
  var i1ForEvenPrev2 = 0.0;
  var prevPhase = 0.0;
  var adjustedPrevPeriod = 0.0;
  var todayValue = 0.0;
  var hilbertTempReal = 0.0;
  for (; today < inReal.length;) {
    adjustedPrevPeriod = (0.075 * period) + 0.54;
    todayValue = inReal.elementAt(today);
    periodWMASub += todayValue;
    periodWMASub -= trailingWMAValue;
    periodWMASum += todayValue * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    var q2 = 0.0;
    var i2 = 0.0;
    var tempReal2 = 0.0;
    if ((today % 2) == 0) {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderEven.elementAt(hilbertIdx);
      detrenderEven[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderEven;
      prevDetrenderEven = b * prevDetrenderInputEven;
      detrender += prevDetrenderEven;
      prevDetrenderInputEven = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Even.elementAt(hilbertIdx);
      q1Even[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Even;
      prevq1Even = b * prevq1InputEven;
      q1 += prevq1Even;
      prevq1InputEven = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForEvenPrev3;
      jI = -jIEven.elementAt(hilbertIdx);
      jIEven[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevjIEven;
      prevjIEven = b * prevjIInputEven;
      jI += prevjIEven;
      prevjIInputEven = i1ForEvenPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQEven.elementAt(hilbertIdx);
      jQEven[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevjQEven;
      prevjQEven = b * prevjQInputEven;
      jQ += prevjQEven;
      prevjQInputEven = q1;
      jQ *= adjustedPrevPeriod;
      hilbertIdx++;
      if (hilbertIdx == 3) {
        hilbertIdx = 0;
      }

      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForEvenPrev3 - jQ)) + (0.8 * previ2);
      i1ForOddPrev3 = i1ForOddPrev2;
      i1ForOddPrev2 = detrender;
      if (i1ForEvenPrev3 != 0.0) {
        tempReal2 = (math.atan(q1 / i1ForEvenPrev3) * rad2Deg);
      } else {
        tempReal2 = 0.0;
      }
    } else {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderOdd.elementAt(hilbertIdx);
      detrenderOdd[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderOdd;
      prevDetrenderOdd = b * prevDetrenderInputOdd;
      detrender += prevDetrenderOdd;
      prevDetrenderInputOdd = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Odd.elementAt(hilbertIdx);
      q1Odd[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Odd;
      prevq1Odd = b * prevq1InputOdd;
      q1 += prevq1Odd;
      prevq1InputOdd = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForOddPrev3;
      jI = -jIOdd.elementAt(hilbertIdx);
      jIOdd[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevjIOdd;
      prevjIOdd = b * prevjIInputOdd;
      jI += prevjIOdd;
      prevjIInputOdd = i1ForOddPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQOdd.elementAt(hilbertIdx);
      jQOdd[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevjQOdd;
      prevjQOdd = b * prevjQInputOdd;
      jQ += prevjQOdd;
      prevjQInputOdd = q1;
      jQ *= adjustedPrevPeriod;
      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForOddPrev3 - jQ)) + (0.8 * previ2);
      i1ForEvenPrev3 = i1ForEvenPrev2;
      i1ForEvenPrev2 = detrender;
      if (i1ForOddPrev3 != 0.0) {
        tempReal2 = (math.atan(q1 / i1ForOddPrev3) * rad2Deg);
      } else {
        tempReal2 = 0.0;
      }
    }
    tempReal = prevPhase - tempReal2;
    prevPhase = tempReal2;
    if (tempReal < 1.0) {
      tempReal = 1.0;
    }

    if (tempReal > 1.0) {
      tempReal = inFastLimit / tempReal;
      if (tempReal < inSlowLimit) {
        tempReal = inSlowLimit;
      }
    } else {
      tempReal = inFastLimit;
    }
    mama = (tempReal * todayValue) + ((1 - tempReal) * mama);
    tempReal *= 0.5;
    fama = (tempReal * mama) + ((1 - tempReal) * fama);
    if (today >= startIdx) {
      outMAMA[outIdx] = mama;
      outFAMA[outIdx] = fama;
      outIdx++;
    }

    Re = (0.2 * ((i2 * previ2) + (q2 * prevq2))) + (0.8 * Re);
    Im = (0.2 * ((i2 * prevq2) - (q2 * previ2))) + (0.8 * Im);
    prevq2 = q2;
    previ2 = i2;
    tempReal = period;
    if ((Im != 0.0) && (Re != 0.0)) {
      period = 360.0 / (math.atan(Im / Re) * rad2Deg);
    }

    tempReal2 = 1.5 * tempReal;
    if (period > tempReal2) {
      period = tempReal2;
    }

    tempReal2 = 0.67 * tempReal;
    if (period < tempReal2) {
      period = tempReal2;
    }

    if (period < 6) {
      period = 6;
    } else if (period > 50) {
      period = 50;
    }

    period = (0.2 * period) + (0.8 * tempReal);
    today++;
  }
  return [outMAMA, outFAMA];
}

List MaVp(List inReal, List inPeriods, int inMinPeriod, int inMaxPeriod,
    MaType inMAType) {
  var outReal = new List(inReal.length);
  var startIdx = inMaxPeriod - 1;
  var outputSize = inReal.length;
  var localPeriodArray = new List(outputSize);
  for (var i = startIdx; i < outputSize; i++) {
    var tempInt = inPeriods.elementAt(i);
    if (tempInt < inMinPeriod) {
      tempInt = inMinPeriod;
    } else if (tempInt > inMaxPeriod) {
      tempInt = inMaxPeriod;
    }

    localPeriodArray[i] = tempInt;
  }
  for (var i = startIdx; i < outputSize; i++) {
    var curPeriod = localPeriodArray.elementAt(i);
    if (curPeriod != 0) {
      var localOutputArray = Ma(inReal, curPeriod, inMAType);
      outReal[i] = localOutputArray.elementAt(i);
      for (var j = i + 1; j < outputSize; j++) {
        if (localPeriodArray.elementAt(j) == curPeriod) {
          localPeriodArray[j] = 0;
          outReal[j] = localOutputArray.elementAt(j);
        }
      }
    }
  }
  return outReal;
}

List MidPoint(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var nbInitialElementNeeded = inTimePeriod - 1;
  var startIdx = nbInitialElementNeeded;
  var outIdx = inTimePeriod - 1;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  for (; today < inReal.length;) {
    var lowest = inReal.elementAt(trailingIdx);
    trailingIdx++;
    var highest = lowest;
    for (var i = trailingIdx; i <= today; i++) {
      var tmp = inReal.elementAt(i);
      if (tmp < lowest) {
        lowest = tmp;
      } else if (tmp > highest) {
        highest = tmp;
      }
    }
    outReal[outIdx] = (highest + lowest) / 2.0;
    outIdx++;
    today++;
  }
  return outReal;
}

List MidPrice(List inHigh, List inLow, int inTimePeriod) {
  var outReal = new List(inHigh.length);
  var nbInitialElementNeeded = inTimePeriod - 1;
  var startIdx = nbInitialElementNeeded;
  var outIdx = inTimePeriod - 1;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  for (; today < inHigh.length;) {
    var lowest = inLow.elementAt(trailingIdx);
    var highest = inHigh.elementAt(trailingIdx);
    trailingIdx++;
    for (var i = trailingIdx; i <= today; i++) {
      var tmp = inLow.elementAt(i);
      if (tmp < lowest) {
        lowest = tmp;
      }

      tmp = inHigh.elementAt(i);
      if (tmp > highest) {
        highest = tmp;
      }
    }
    outReal[outIdx] = (highest + lowest) / 2.0;
    outIdx++;
    today++;
  }
  return outReal;
}

List Sar(List inHigh, List inLow, double inAcceleration, double inMaximum) {
  var outReal = new List(inHigh.length);
  var af = inAcceleration;
  if (af > inMaximum) {
    af = inMaximum;
    inAcceleration = inMaximum;
  }

  var epTemp = MinusDM(inHigh, inLow, 1);
  var isLong = 1;
  if (epTemp.elementAt(1) > 0) {
    isLong = 0;
  }

  var startIdx = 1;
  var outIdx = startIdx;
  var todayIdx = startIdx;
  var newHigh = inHigh.elementAt(todayIdx - 1);
  var newLow = inLow.elementAt(todayIdx - 1);
  var sar = 0.0;
  var ep = 0.0;
  if (isLong == 1) {
    ep = inHigh.elementAt(todayIdx);
    sar = newLow;
  } else {
    ep = inLow.elementAt(todayIdx);
    sar = newHigh;
  }
  newLow = inLow.elementAt(todayIdx);
  newHigh = inHigh.elementAt(todayIdx);
  var prevLow = 0.0;
  var prevHigh = 0.0;
  for (; todayIdx < inHigh.length;) {
    prevLow = newLow;
    prevHigh = newHigh;
    newLow = inLow.elementAt(todayIdx);
    newHigh = inHigh.elementAt(todayIdx);
    todayIdx++;
    if (isLong == 1) {
      if (newLow <= sar) {
        isLong = 0;
        sar = ep;
        if (sar < prevHigh) {
          sar = prevHigh;
        }

        if (sar < newHigh) {
          sar = newHigh;
        }

        outReal[outIdx] = sar;
        outIdx++;
        af = inAcceleration;
        ep = newLow;
        sar = sar + af * (ep - sar);
        if (sar < prevHigh) {
          sar = prevHigh;
        }

        if (sar < newHigh) {
          sar = newHigh;
        }
      } else {
        outReal[outIdx] = sar;
        outIdx++;
        if (newHigh > ep) {
          ep = newHigh;
          af += inAcceleration;
          if (af > inMaximum) {
            af = inMaximum;
          }
        }

        sar = sar + af * (ep - sar);
        if (sar > prevLow) {
          sar = prevLow;
        }

        if (sar > newLow) {
          sar = newLow;
        }
      }
    } else {
      if (newHigh >= sar) {
        isLong = 1;
        sar = ep;
        if (sar > prevLow) {
          sar = prevLow;
        }

        if (sar > newLow) {
          sar = newLow;
        }

        outReal[outIdx] = sar;
        outIdx++;
        af = inAcceleration;
        ep = newHigh;
        sar = sar + af * (ep - sar);
        if (sar > prevLow) {
          sar = prevLow;
        }

        if (sar > newLow) {
          sar = newLow;
        }
      } else {
        outReal[outIdx] = sar;
        outIdx++;
        if (newLow < ep) {
          ep = newLow;
          af += inAcceleration;
          if (af > inMaximum) {
            af = inMaximum;
          }
        }

        sar = sar + af * (ep - sar);
        if (sar < prevHigh) {
          sar = prevHigh;
        }

        if (sar < newHigh) {
          sar = newHigh;
        }
      }
    }
  }
  return outReal;
}

List SarExt(
    List inHigh,
    List inLow,
    double inStartValue,
    double inOffsetOnReverse,
    double inAccelerationInitLong,
    double inAccelerationLong,
    double inAccelerationMaxLong,
    double inAccelerationInitShort,
    double inAccelerationShort,
    double inAccelerationMaxShort) {
  var outReal = new List(inHigh.length);
  var startIdx = 1;
  var afLong = inAccelerationInitLong;
  var afShort = inAccelerationInitShort;
  if (afLong > inAccelerationMaxLong) {
    afLong = inAccelerationMaxLong;
    inAccelerationInitLong = inAccelerationMaxLong;
  }

  if (inAccelerationLong > inAccelerationMaxLong) {
    inAccelerationLong = inAccelerationMaxLong;
  }

  if (afShort > inAccelerationMaxShort) {
    afShort = inAccelerationMaxShort;
    inAccelerationInitShort = inAccelerationMaxShort;
  }

  if (inAccelerationShort > inAccelerationMaxShort) {
    inAccelerationShort = inAccelerationMaxShort;
  }

  var isLong = 0;
  if (inStartValue == 0) {
    var epTemp = MinusDM(inHigh, inLow, 1);
    if (epTemp.elementAt(1) > 0) {
      isLong = 0;
    } else {
      isLong = 1;
    }
  } else if (inStartValue > 0) {
    isLong = 1;
  }

  var outIdx = startIdx;
  var todayIdx = startIdx;
  var newHigh = inHigh.elementAt(todayIdx - 1);
  var newLow = inLow.elementAt(todayIdx - 1);
  var ep = 0.0;
  var sar = 0.0;
  if (inStartValue == 0) {
    if (isLong == 1) {
      ep = inHigh.elementAt(todayIdx);
      sar = newLow;
    } else {
      ep = inLow.elementAt(todayIdx);
      sar = newHigh;
    }
  } else if (inStartValue > 0) {
    ep = inHigh.elementAt(todayIdx);
    sar = inStartValue;
  } else {
    ep = inLow.elementAt(todayIdx);
    sar = inStartValue.abs();
  }

  newLow = inLow.elementAt(todayIdx);
  newHigh = inHigh.elementAt(todayIdx);
  var prevLow = 0.0;
  var prevHigh = 0.0;
  for (; todayIdx < inHigh.length;) {
    prevLow = newLow;
    prevHigh = newHigh;
    newLow = inLow.elementAt(todayIdx);
    newHigh = inHigh.elementAt(todayIdx);
    todayIdx++;
    if (isLong == 1) {
      if (newLow <= sar) {
        isLong = 0;
        sar = ep;
        if (sar < prevHigh) {
          sar = prevHigh;
        }

        if (sar < newHigh) {
          sar = newHigh;
        }

        if (inOffsetOnReverse != 0.0) {
          sar += sar * inOffsetOnReverse;
        }

        outReal[outIdx] = -sar;
        outIdx++;
        afShort = inAccelerationInitShort;
        ep = newLow;
        sar = sar + afShort * (ep - sar);
        if (sar < prevHigh) {
          sar = prevHigh;
        }

        if (sar < newHigh) {
          sar = newHigh;
        }
      } else {
        outReal[outIdx] = sar;
        outIdx++;
        if (newHigh > ep) {
          ep = newHigh;
          afLong += inAccelerationLong;
          if (afLong > inAccelerationMaxLong) {
            afLong = inAccelerationMaxLong;
          }
        }

        sar = sar + afLong * (ep - sar);
        if (sar > prevLow) {
          sar = prevLow;
        }

        if (sar > newLow) {
          sar = newLow;
        }
      }
    } else {
      if (newHigh >= sar) {
        isLong = 1;
        sar = ep;
        if (sar > prevLow) {
          sar = prevLow;
        }

        if (sar > newLow) {
          sar = newLow;
        }

        if (inOffsetOnReverse != 0.0) {
          sar -= sar * inOffsetOnReverse;
        }

        outReal[outIdx] = sar;
        outIdx++;
        afLong = inAccelerationInitLong;
        ep = newHigh;
        sar = sar + afLong * (ep - sar);
        if (sar > prevLow) {
          sar = prevLow;
        }

        if (sar > newLow) {
          sar = newLow;
        }
      } else {
        outReal[outIdx] = -sar;
        outIdx++;
        if (newLow < ep) {
          ep = newLow;
          afShort += inAccelerationShort;
          if (afShort > inAccelerationMaxShort) {
            afShort = inAccelerationMaxShort;
          }
        }

        sar = sar + afShort * (ep - sar);
        if (sar < prevHigh) {
          sar = prevHigh;
        }

        if (sar < newHigh) {
          sar = newHigh;
        }
      }
    }
  }
  return outReal;
}

List Sma(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var lookbackTotal = inTimePeriod - 1;
  var startIdx = lookbackTotal;
  var periodTotal = 0.0;
  var trailingIdx = startIdx - lookbackTotal;
  var i = trailingIdx;
  if (inTimePeriod > 1) {
    for (; i < startIdx;) {
      periodTotal += inReal.elementAt(i);
      i++;
    }
  }

  var outIdx = startIdx;
  for (var ok = true; ok;) {
    periodTotal += inReal.elementAt(i);
    var tempReal = periodTotal;
    periodTotal -= inReal.elementAt(trailingIdx);
    outReal[outIdx] = tempReal / inTimePeriod;
    trailingIdx++;
    i++;
    outIdx++;
    ok = i < outReal.length;
  }
  return outReal;
}

List T3(List inReal, int inTimePeriod, double inVFactor) {
  var outReal = new List(inReal.length);
  var lookbackTotal = 6 * (inTimePeriod - 1);
  var startIdx = lookbackTotal;
  var today = startIdx - lookbackTotal;
  var k = 2.0 / (inTimePeriod + 1.0);
  var oneMinusK = 1.0 - k;
  var tempReal = inReal.elementAt(today);
  today++;
  for (var i = inTimePeriod - 1; i > 0; i--) {
    tempReal += inReal.elementAt(today);
    today++;
  }
  var e1 = tempReal / inTimePeriod;
  tempReal = e1;
  for (var i = inTimePeriod - 1; i > 0; i--) {
    e1 = (k * inReal.elementAt(today)) + (oneMinusK * e1);
    tempReal += e1;
    today++;
  }
  var e2 = tempReal / inTimePeriod;
  tempReal = e2;
  for (var i = inTimePeriod - 1; i > 0; i--) {
    e1 = (k * inReal.elementAt(today)) + (oneMinusK * e1);
    e2 = (k * e1) + (oneMinusK * e2);
    tempReal += e2;
    today++;
  }
  var e3 = tempReal / inTimePeriod;
  tempReal = e3;
  for (var i = inTimePeriod - 1; i > 0; i--) {
    e1 = (k * inReal.elementAt(today)) + (oneMinusK * e1);
    e2 = (k * e1) + (oneMinusK * e2);
    e3 = (k * e2) + (oneMinusK * e3);
    tempReal += e3;
    today++;
  }
  var e4 = tempReal / inTimePeriod;
  tempReal = e4;
  for (var i = inTimePeriod - 1; i > 0; i--) {
    e1 = (k * inReal.elementAt(today)) + (oneMinusK * e1);
    e2 = (k * e1) + (oneMinusK * e2);
    e3 = (k * e2) + (oneMinusK * e3);
    e4 = (k * e3) + (oneMinusK * e4);
    tempReal += e4;
    today++;
  }
  var e5 = tempReal / inTimePeriod;
  tempReal = e5;
  for (var i = inTimePeriod - 1; i > 0; i--) {
    e1 = (k * inReal.elementAt(today)) + (oneMinusK * e1);
    e2 = (k * e1) + (oneMinusK * e2);
    e3 = (k * e2) + (oneMinusK * e3);
    e4 = (k * e3) + (oneMinusK * e4);
    e5 = (k * e4) + (oneMinusK * e5);
    tempReal += e5;
    today++;
  }
  var e6 = tempReal / inTimePeriod;
  for (; today <= startIdx;) {
    e1 = (k * inReal.elementAt(today)) + (oneMinusK * e1);
    e2 = (k * e1) + (oneMinusK * e2);
    e3 = (k * e2) + (oneMinusK * e3);
    e4 = (k * e3) + (oneMinusK * e4);
    e5 = (k * e4) + (oneMinusK * e5);
    e6 = (k * e5) + (oneMinusK * e6);
    today++;
  }
  tempReal = inVFactor * inVFactor;
  var c1 = -(tempReal * inVFactor);
  var c2 = 3.0 * (tempReal - c1);
  var c3 = -6.0 * tempReal - 3.0 * (inVFactor - c1);
  var c4 = 1.0 + 3.0 * inVFactor - c1 + 3.0 * tempReal;
  var outIdx = lookbackTotal;
  outReal[outIdx] = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
  outIdx++;
  for (; today < inReal.length;) {
    e1 = (k * inReal.elementAt(today)) + (oneMinusK * e1);
    e2 = (k * e1) + (oneMinusK * e2);
    e3 = (k * e2) + (oneMinusK * e3);
    e4 = (k * e3) + (oneMinusK * e4);
    e5 = (k * e4) + (oneMinusK * e5);
    e6 = (k * e5) + (oneMinusK * e6);
    outReal[outIdx] = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
    outIdx++;
    today++;
  }
  return outReal;
}

List Tema(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var firstEMA = Ema(inReal, inTimePeriod);
  var secondEMA = Ema(
      firstEMA.sublist(
        inTimePeriod - 1,
      ),
      inTimePeriod);
  var thirdEMA = Ema(
      secondEMA.sublist(
        inTimePeriod - 1,
      ),
      inTimePeriod);
  var outIdx = (inTimePeriod * 3) - 3;
  var secondEMAIdx = (inTimePeriod * 2) - 2;
  var thirdEMAIdx = inTimePeriod - 1;
  for (; outIdx < inReal.length;) {
    outReal[outIdx] = thirdEMA.elementAt(thirdEMAIdx) +
        ((3.0 * firstEMA.elementAt(outIdx)) -
            (3.0 * secondEMA.elementAt(secondEMAIdx)));
    outIdx++;
    secondEMAIdx++;
    thirdEMAIdx++;
  }
  return outReal;
}

List Trima(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var lookbackTotal = inTimePeriod - 1;
  var startIdx = lookbackTotal;
  var outIdx = inTimePeriod - 1;
  var factor = null;
  if (inTimePeriod % 2 == 1) {
    var i = inTimePeriod >> 1;
    factor = (i + 1.0) * (i + 1.0);
    factor = 1.0 / factor;
    var trailingIdx = startIdx - lookbackTotal;
    var middleIdx = trailingIdx + i;
    var todayIdx = middleIdx + i;
    var numerator = 0.0;
    var numeratorSub = 0.0;
    for (var i = middleIdx; i >= trailingIdx; i--) {
      var tempReal = inReal.elementAt(i);
      numeratorSub += tempReal;
      numerator += numeratorSub;
    }
    var numeratorAdd = 0.0;
    middleIdx++;
    for (var i = middleIdx; i <= todayIdx; i++) {
      var tempReal = inReal.elementAt(i);
      numeratorAdd += tempReal;
      numerator += numeratorAdd;
    }
    outIdx = inTimePeriod - 1;
    var tempReal = inReal.elementAt(trailingIdx);
    trailingIdx++;
    outReal[outIdx] = numerator * factor;
    outIdx++;
    todayIdx++;
    for (; todayIdx < inReal.length;) {
      numerator -= numeratorSub;
      numeratorSub -= tempReal;
      tempReal = inReal.elementAt(middleIdx);
      middleIdx++;
      numeratorSub += tempReal;
      numerator += numeratorAdd;
      numeratorAdd -= tempReal;
      tempReal = inReal.elementAt(todayIdx);
      todayIdx++;
      numeratorAdd += tempReal;
      numerator += tempReal;
      tempReal = inReal.elementAt(trailingIdx);
      trailingIdx++;
      outReal[outIdx] = numerator * factor;
      outIdx++;
    }
  } else {
    var i = (inTimePeriod >> 1);
    factor = i * (i + 1);
    factor = 1.0 / factor;
    var trailingIdx = startIdx - lookbackTotal;
    var middleIdx = trailingIdx + i - 1;
    var todayIdx = middleIdx + i;
    var numerator = 0.0;
    var numeratorSub = 0.0;
    for (var i = middleIdx; i >= trailingIdx; i--) {
      var tempReal = inReal.elementAt(i);
      numeratorSub += tempReal;
      numerator += numeratorSub;
    }
    var numeratorAdd = 0.0;
    middleIdx++;
    for (var i = middleIdx; i <= todayIdx; i++) {
      var tempReal = inReal.elementAt(i);
      numeratorAdd += tempReal;
      numerator += numeratorAdd;
    }
    outIdx = inTimePeriod - 1;
    var tempReal = inReal.elementAt(trailingIdx);
    trailingIdx++;
    outReal[outIdx] = numerator * factor;
    outIdx++;
    todayIdx++;
    for (; todayIdx < inReal.length;) {
      numerator -= numeratorSub;
      numeratorSub -= tempReal;
      tempReal = inReal.elementAt(middleIdx);
      middleIdx++;
      numeratorSub += tempReal;
      numeratorAdd -= tempReal;
      numerator += numeratorAdd;
      tempReal = inReal.elementAt(todayIdx);
      todayIdx++;
      numeratorAdd += tempReal;
      numerator += tempReal;
      tempReal = inReal.elementAt(trailingIdx);
      trailingIdx++;
      outReal[outIdx] = numerator * factor;
      outIdx++;
    }
  }
  return outReal;
}

List Wma(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var lookbackTotal = inTimePeriod - 1;
  var startIdx = lookbackTotal;
  if (inTimePeriod == 1) {
    outReal = List.from(inReal);
    return outReal;
  }

  var divider = (inTimePeriod * (inTimePeriod + 1)) >> 1;
  var outIdx = inTimePeriod - 1;
  var trailingIdx = startIdx - lookbackTotal;
  var periodSum = 0.0;
  var periodSub = 0.0;
  var inIdx = trailingIdx;
  var i = 1;
  for (; inIdx < startIdx;) {
    var tempReal = inReal.elementAt(inIdx);
    periodSub += tempReal;
    periodSum += tempReal * i;
    inIdx++;
    i++;
  }
  var trailingValue = 0.0;
  for (; inIdx < inReal.length;) {
    var tempReal = inReal.elementAt(inIdx);
    periodSub += tempReal;
    periodSub -= trailingValue;
    periodSum += tempReal * inTimePeriod;
    trailingValue = inReal.elementAt(trailingIdx);
    outReal[outIdx] = periodSum / divider;
    periodSum -= periodSub;
    inIdx++;
    trailingIdx++;
    outIdx++;
  }
  return outReal;
}

List Adx(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var inTimePeriodF = inTimePeriod;
  var lookbackTotal = (2 * inTimePeriod) - 1;
  var startIdx = lookbackTotal;
  var outIdx = inTimePeriod;
  var prevMinusDM = 0.0;
  var prevPlusDM = 0.0;
  var prevTR = 0.0;
  var today = startIdx - lookbackTotal;
  var prevHigh = inHigh.elementAt(today);
  var prevLow = inLow.elementAt(today);
  var prevClose = inClose.elementAt(today);
  for (var i = inTimePeriod - 1; i > 0; i--) {
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM += diffM;
    } else if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM += diffP;
    }

    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR += tempReal;
    prevClose = inClose.elementAt(today);
  }
  var sumDX = 0.0;
  for (var i = inTimePeriod; i > 0; i--) {
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    prevMinusDM -= prevMinusDM / inTimePeriodF;
    prevPlusDM -= prevPlusDM / inTimePeriodF;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM += diffM;
    } else if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM += diffP;
    }

    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR = prevTR - (prevTR / inTimePeriodF) + tempReal;
    prevClose = inClose.elementAt(today);
    if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
      var minusDI = (100.0 * (prevMinusDM / prevTR));
      var plusDI = (100.0 * (prevPlusDM / prevTR));
      tempReal = minusDI + plusDI;
      if (!(((-(0.00000000000001)) < tempReal) &&
          (tempReal < (0.00000000000001)))) {
        sumDX += (100.0 * ((minusDI - plusDI).abs() / tempReal));
      }
    }
  }
  var prevADX = (sumDX / inTimePeriodF);
  outReal[startIdx] = prevADX;
  outIdx = startIdx + 1;
  today++;
  for (; today < inClose.length;) {
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    prevMinusDM -= prevMinusDM / inTimePeriodF;
    prevPlusDM -= prevPlusDM / inTimePeriodF;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM += diffM;
    } else if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM += diffP;
    }

    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR = prevTR - (prevTR / inTimePeriodF) + tempReal;
    prevClose = inClose.elementAt(today);
    if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
      var minusDI = (100.0 * (prevMinusDM / prevTR));
      var plusDI = (100.0 * (prevPlusDM / prevTR));
      tempReal = minusDI + plusDI;
      if (!(((-(0.00000000000001)) < tempReal) &&
          (tempReal < (0.00000000000001)))) {
        tempReal = (100.0 * ((minusDI - plusDI).abs() / tempReal));
        prevADX =
            (((prevADX * (inTimePeriodF - 1)) + tempReal) / inTimePeriodF);
      }
    }

    outReal[outIdx] = prevADX;
    outIdx++;
    today++;
  }
  return outReal;
}

List AdxR(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var startIdx = (2 * inTimePeriod) - 1;
  var tmpadx = Adx(inHigh, inLow, inClose, inTimePeriod);
  var i = startIdx;
  var j = startIdx + inTimePeriod - 1;
  for (var outIdx = startIdx + inTimePeriod - 1;
      outIdx < inClose.length;
      outIdx = outIdx + 1, i = i + 1, j = j + 1) {
    outReal[outIdx] = ((tmpadx.elementAt(i) + tmpadx.elementAt(j)) / 2.0);
  }
  return outReal;
}

List Apo(List inReal, int inFastPeriod, int inSlowPeriod, MaType inMAType) {
  if (inSlowPeriod < inFastPeriod) {
    inSlowPeriod = inFastPeriod;
    inFastPeriod = inSlowPeriod;
  }

  var tempBuffer = Ma(inReal, inFastPeriod, inMAType);
  var outReal = Ma(inReal, inSlowPeriod, inMAType);
  for (var i = inSlowPeriod - 1; i < inReal.length; i++) {
    outReal[i] = tempBuffer.elementAt(i) - outReal.elementAt(i);
  }
  return outReal;
}

List Aroon(List inHigh, List inLow, int inTimePeriod) {
  var outAroonUp = new List(inHigh.length);
  var outAroonDown = new List(inHigh.length);
  var startIdx = inTimePeriod;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - inTimePeriod;
  var lowestIdx = -1;
  var highestIdx = -1;
  var lowest = 0.0;
  var highest = 0.0;
  var factor = 100.0 / inTimePeriod;
  for (; today < inHigh.length;) {
    var tmp = inLow.elementAt(today);
    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inLow.elementAt(lowestIdx);
      var i = lowestIdx;
      i++;
      for (; i <= today;) {
        tmp = inLow.elementAt(i);
        if (tmp <= lowest) {
          lowestIdx = i;
          lowest = tmp;
        }

        i++;
      }
    } else if (tmp <= lowest) {
      lowestIdx = today;
      lowest = tmp;
    }

    tmp = inHigh.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inHigh.elementAt(highestIdx);
      var i = highestIdx;
      i++;
      for (; i <= today;) {
        tmp = inHigh.elementAt(i);
        if (tmp >= highest) {
          highestIdx = i;
          highest = tmp;
        }

        i++;
      }
    } else if (tmp >= highest) {
      highestIdx = today;
      highest = tmp;
    }

    outAroonUp[outIdx] = factor * inTimePeriod - (today - highestIdx);
    outAroonDown[outIdx] = factor * inTimePeriod - (today - lowestIdx);
    outIdx++;
    trailingIdx++;
    today++;
  }
  return [outAroonDown, outAroonUp];
}

List AroonOsc(List inHigh, List inLow, int inTimePeriod) {
  var outReal = new List(inHigh.length);
  var startIdx = inTimePeriod;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - inTimePeriod;
  var lowestIdx = -1;
  var highestIdx = -1;
  var lowest = 0.0;
  var highest = 0.0;
  var factor = 100.0 / inTimePeriod;
  for (; today < inHigh.length;) {
    var tmp = inLow.elementAt(today);
    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inLow.elementAt(lowestIdx);
      var i = lowestIdx;
      i++;
      for (; i <= today;) {
        tmp = inLow.elementAt(i);
        if (tmp <= lowest) {
          lowestIdx = i;
          lowest = tmp;
        }

        i++;
      }
    } else if (tmp <= lowest) {
      lowestIdx = today;
      lowest = tmp;
    }

    tmp = inHigh.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inHigh.elementAt(highestIdx);
      var i = highestIdx;
      i++;
      for (; i <= today;) {
        tmp = inHigh.elementAt(i);
        if (tmp >= highest) {
          highestIdx = i;
          highest = tmp;
        }

        i++;
      }
    } else if (tmp >= highest) {
      highestIdx = today;
      highest = tmp;
    }

    var aroon = factor * highestIdx - lowestIdx;
    outReal[outIdx] = aroon;
    outIdx++;
    trailingIdx++;
    today++;
  }
  return outReal;
}

List Bop(List inOpen, List inHigh, List inLow, List inClose) {
  var outReal = new List(inClose.length);
  for (var i = 0; i < inClose.length; i++) {
    var tempReal = inHigh.elementAt(i) - inLow.elementAt(i);
    if (tempReal < (0.00000000000001)) {
      outReal[i] = 0.0;
    } else {
      outReal[i] = (inClose.elementAt(i) - inOpen.elementAt(i)) / tempReal;
    }
  }
  return outReal;
}

List Cmo(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var outIdx = startIdx;
  if (inTimePeriod == 1) {
    outReal = List.from(inReal);
    return outReal;
  }

  var today = startIdx - lookbackTotal;
  var prevValue = inReal.elementAt(today);
  var prevGain = 0.0;
  var prevLoss = 0.0;
  today++;
  for (var i = inTimePeriod; i > 0; i--) {
    var tempValue1 = inReal.elementAt(today);
    var tempValue2 = tempValue1 - prevValue;
    prevValue = tempValue1;
    if (tempValue2 < 0) {
      prevLoss -= tempValue2;
    } else {
      prevGain += tempValue2;
    }
    today++;
  }
  prevLoss /= inTimePeriod;
  prevGain /= inTimePeriod;
  if (today > startIdx) {
    var tempValue1 = prevGain + prevLoss;
    if (!(((-(0.00000000000001)) < tempValue1) &&
        (tempValue1 < (0.00000000000001)))) {
      outReal[outIdx] = 100.0 * ((prevGain - prevLoss) / tempValue1);
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
  } else {
    for (; today < startIdx;) {
      var tempValue1 = inReal.elementAt(today);
      var tempValue2 = tempValue1 - prevValue;
      prevValue = tempValue1;
      prevLoss *= inTimePeriod - 1;
      prevGain *= inTimePeriod - 1;
      if (tempValue2 < 0) {
        prevLoss -= tempValue2;
      } else {
        prevGain += tempValue2;
      }
      prevLoss /= inTimePeriod;
      prevGain /= inTimePeriod;
      today++;
    }
  }
  for (; today < inReal.length;) {
    var tempValue1 = inReal.elementAt(today);
    today++;
    var tempValue2 = tempValue1 - prevValue;
    prevValue = tempValue1;
    prevLoss *= inTimePeriod - 1;
    prevGain *= inTimePeriod - 1;
    if (tempValue2 < 0) {
      prevLoss -= tempValue2;
    } else {
      prevGain += tempValue2;
    }
    prevLoss /= inTimePeriod;
    prevGain /= inTimePeriod;
    tempValue1 = prevGain + prevLoss;
    if (!(((-(0.00000000000001)) < tempValue1) &&
        (tempValue1 < (0.00000000000001)))) {
      outReal[outIdx] = 100.0 * ((prevGain - prevLoss) / tempValue1);
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
  }
  return outReal;
}

List Cci(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var circBufferIdx = 0;
  var lookbackTotal = inTimePeriod - 1;
  var startIdx = lookbackTotal;
  var circBuffer = new List(inTimePeriod);
  var maxIdxCircBuffer = (inTimePeriod - 1);
  var i = startIdx - lookbackTotal;
  if (inTimePeriod > 1) {
    for (; i < startIdx;) {
      circBuffer[circBufferIdx] =
          (inHigh.elementAt(i) + inLow.elementAt(i) + inClose.elementAt(i)) / 3;
      i++;
      circBufferIdx++;
      if (circBufferIdx > maxIdxCircBuffer) {
        circBufferIdx = 0;
      }
    }
  }

  var outIdx = inTimePeriod - 1;
  for (; i < inClose.length;) {
    var lastValue =
        (inHigh.elementAt(i) + inLow.elementAt(i) + inClose.elementAt(i)) / 3;
    circBuffer[circBufferIdx] = lastValue;
    var theAverage = 0.0;
    for (var j = 0; j < inTimePeriod; j++) {
      theAverage += circBuffer.elementAt(j);
    }
    theAverage /= inTimePeriod;
    var tempReal2 = 0.0;
    for (var j = 0; j < inTimePeriod; j++) {
      tempReal2 += (circBuffer.elementAt(j) - theAverage).abs();
    }
    var tempReal = lastValue - theAverage;
    if ((tempReal != 0.0) && (tempReal2 != 0.0)) {
      outReal[outIdx] = tempReal / (0.015 * (tempReal2 / inTimePeriod));
    } else {
      outReal[outIdx] = 0.0;
    }
    circBufferIdx++;
    if (circBufferIdx > maxIdxCircBuffer) {
      circBufferIdx = 0;
    }

    outIdx++;
    i++;
  }
  return outReal;
}

List Dx(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var lookbackTotal = 2;
  if (inTimePeriod > 1) {
    lookbackTotal = inTimePeriod;
  }

  var startIdx = lookbackTotal;
  var outIdx = startIdx;
  var prevMinusDM = 0.0;
  var prevPlusDM = 0.0;
  var prevTR = 0.0;
  var today = startIdx - lookbackTotal;
  var prevHigh = inHigh.elementAt(today);
  var prevLow = inLow.elementAt(today);
  var prevClose = inClose.elementAt(today);
  var i = inTimePeriod - 1;
  for (; i > 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM += diffM;
    } else if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM += diffP;
    }

    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR += tempReal;
    prevClose = inClose.elementAt(today);
  }
  if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
    var minusDI = (100.0 * (prevMinusDM / prevTR));
    var plusDI = (100.0 * (prevPlusDM / prevTR));
    var tempReal = minusDI + plusDI;
    if (!(((-(0.00000000000001)) < tempReal) &&
        (tempReal < (0.00000000000001)))) {
      outReal[outIdx] = (100.0 * ((minusDI - plusDI).abs() / tempReal));
    } else {
      outReal[outIdx] = 0.0;
    }
  } else {
    outReal[outIdx] = 0.0;
  }
  outIdx = startIdx;
  for (; today < inClose.length - 1;) {
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    prevMinusDM -= prevMinusDM / inTimePeriod;
    prevPlusDM -= prevPlusDM / inTimePeriod;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM += diffM;
    } else if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM += diffP;
    }

    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR = prevTR - (prevTR / inTimePeriod) + tempReal;
    prevClose = inClose.elementAt(today);
    if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
      var minusDI = (100.0 * (prevMinusDM / prevTR));
      var plusDI = (100.0 * (prevPlusDM / prevTR));
      tempReal = minusDI + plusDI;
      if (!(((-(0.00000000000001)) < tempReal) &&
          (tempReal < (0.00000000000001)))) {
        outReal[outIdx] = (100.0 * ((minusDI - plusDI).abs() / tempReal));
      } else {
        outReal[outIdx] = outReal.elementAt(outIdx - 1);
      }
    } else {
      outReal[outIdx] = outReal.elementAt(outIdx - 1);
    }
    outIdx++;
  }
  return outReal;
}

List Macd(List inReal, int inFastPeriod, int inSlowPeriod, int inSignalPeriod) {
  if (inSlowPeriod < inFastPeriod) {
    inSlowPeriod = inFastPeriod;
    inFastPeriod = inSlowPeriod;
  }

  var k1 = 0.0;
  var k2 = 0.0;
  if (inSlowPeriod != 0) {
    k1 = 2.0 / inSlowPeriod + 1;
  } else {
    inSlowPeriod = 26;
    k1 = 0.075;
  }
  if (inFastPeriod != 0) {
    k2 = 2.0 / inFastPeriod + 1;
  } else {
    inFastPeriod = 12;
    k2 = 0.15;
  }
  var lookbackSignal = inSignalPeriod - 1;
  var lookbackTotal = lookbackSignal;
  lookbackTotal += (inSlowPeriod - 1);
  var fastEMABuffer = ema(inReal, inFastPeriod, k2);
  var slowEMABuffer = ema(inReal, inSlowPeriod, k1);
  for (var i = 0; i < fastEMABuffer.length; i++) { 
    fastEMABuffer[i] = exceptionAware<dynamic>(() => fastEMABuffer.elementAt(i) - slowEMABuffer.elementAt(i));
  }
  var outMACD = new List(inReal.length);
  for (var i = lookbackTotal - 1; i < fastEMABuffer.length; i++) {
    outMACD[i] = fastEMABuffer.elementAt(i);
  }
  var outMACDSignal = ema(outMACD, inSignalPeriod, (2.0 / inSignalPeriod + 1));
  var outMACDHist = new List(inReal.length);
  for (var i = lookbackTotal; i < outMACDHist.length; i++) {
    outMACDHist[i] = outMACD.elementAt(i) - outMACDSignal.elementAt(i);
  }
  return [outMACD, outMACDSignal, outMACDHist];
}

List MacdExt(
    List inReal,
    int inFastPeriod,
    MaType inFastMAType,
    int inSlowPeriod,
    MaType inSlowMAType,
    int inSignalPeriod,
    MaType inSignalMAType) {
  var lookbackLargest = 0;
  if (inFastPeriod < inSlowPeriod) {
    lookbackLargest = inSlowPeriod;
  } else {
    lookbackLargest = inFastPeriod;
  }
  var lookbackTotal = (inSignalPeriod - 1) + (lookbackLargest - 1);
  var outMACD = new List(inReal.length);
  var outMACDSignal = new List(inReal.length);
  var outMACDHist = new List(inReal.length);
  var slowMABuffer = Ma(inReal, inSlowPeriod, inSlowMAType);
  var fastMABuffer = Ma(inReal, inFastPeriod, inFastMAType);
  var tempBuffer1 = new List(inReal.length);
  for (var i = 0; i < slowMABuffer.length; i++) {
    tempBuffer1[i] = fastMABuffer.elementAt(i) - slowMABuffer.elementAt(i);
  }
  var tempBuffer2 = Ma(tempBuffer1, inSignalPeriod, inSignalMAType);
  for (var i = lookbackTotal; i < outMACDHist.length; i++) {
    outMACD[i] = tempBuffer1.elementAt(i);
    outMACDSignal[i] = tempBuffer2.elementAt(i);
    outMACDHist[i] = outMACD.elementAt(i) - outMACDSignal.elementAt(i);
  }
  return [outMACD, outMACDSignal, outMACDHist];
}

List MacdFix(List inReal, int inSignalPeriod) {
  return Macd(inReal, 0, 0, inSignalPeriod);
}

List MinusDI(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var lookbackTotal = 1;
  if (inTimePeriod > 1) {
    lookbackTotal = inTimePeriod;
  }

  var startIdx = lookbackTotal;
  var outIdx = startIdx;
  var prevHigh = 0.0;
  var prevLow = 0.0;
  var prevClose = 0.0;
  if (inTimePeriod <= 1) {
    var today = startIdx - 1;
    prevHigh = inHigh.elementAt(today);
    prevLow = inLow.elementAt(today);
    prevClose = inClose.elementAt(today);
    for (; today < inClose.length - 1;) {
      today++;
      var tempReal = inHigh.elementAt(today);
      var diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow.elementAt(today);
      var diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffM > 0) && (diffP < diffM)) {
        tempReal = prevHigh - prevLow;
        var tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) {
          tempReal = tempReal2;
        }

        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) {
          tempReal = tempReal2;
        }

        if (((-(0.00000000000001)) < tempReal) &&
            (tempReal < (0.00000000000001))) {
          outReal[outIdx] = 0.0;
        } else {
          outReal[outIdx] = diffM / tempReal;
        }
        outIdx++;
      } else {
        outReal[outIdx] = 0.0;
        outIdx++;
      }
      prevClose = inClose.elementAt(today);
    }
    return outReal;
  }

  var prevMinusDM = 0.0;
  var prevTR = 0.0;
  var today = startIdx - lookbackTotal;
  prevHigh = inHigh.elementAt(today);
  prevLow = inLow.elementAt(today);
  prevClose = inClose.elementAt(today);
  var i = inTimePeriod - 1;
  for (; i > 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM += diffM;
    }

    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR += tempReal;
    prevClose = inClose.elementAt(today);
  }
  i = 1;
  for (; i != 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod) + diffM;
    } else {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod);
    }
    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR = prevTR - (prevTR / inTimePeriod) + tempReal;
    prevClose = inClose.elementAt(today);
  }
  if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
    outReal[startIdx] = (100.0 * (prevMinusDM / prevTR));
  } else {
    outReal[startIdx] = 0.0;
  }
  outIdx = startIdx + 1;
  for (; today < inClose.length - 1;) {
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod) + diffM;
    } else {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod);
    }
    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR = prevTR - (prevTR / inTimePeriod) + tempReal;
    prevClose = inClose.elementAt(today);
    if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
      outReal[outIdx] = (100.0 * (prevMinusDM / prevTR));
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
  }
  return outReal;
}

List MinusDM(List inHigh, List inLow, int inTimePeriod) {
  var outReal = new List(inHigh.length);
  var lookbackTotal = 1;
  if (inTimePeriod > 1) {
    lookbackTotal = inTimePeriod - 1;
  }

  var startIdx = lookbackTotal;
  var outIdx = startIdx;
  var today = startIdx;
  var prevHigh = 0.0;
  var prevLow = 0.0;
  if (inTimePeriod <= 1) {
    today = startIdx - 1;
    prevHigh = inHigh.elementAt(today);
    prevLow = inLow.elementAt(today);
    for (; today < inHigh.length - 1;) {
      today++;
      var tempReal = inHigh.elementAt(today);
      var diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow.elementAt(today);
      var diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffM > 0) && (diffP < diffM)) {
        outReal[outIdx] = diffM;
      } else {
        outReal[outIdx] = 0;
      }
      outIdx++;
    }
    return outReal;
  }

  var prevMinusDM = 0.0;
  today = startIdx - lookbackTotal;
  prevHigh = inHigh.elementAt(today);
  prevLow = inLow.elementAt(today);
  var i = inTimePeriod - 1;
  for (; i > 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM += diffM;
    }
  }
  i = 0;
  for (; i != 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod) + diffM;
    } else {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod);
    }
  }
  outReal[startIdx] = prevMinusDM;
  outIdx = startIdx + 1;
  for (; today < inHigh.length - 1;) {
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffM > 0) && (diffP < diffM)) {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod) + diffM;
    } else {
      prevMinusDM = prevMinusDM - (prevMinusDM / inTimePeriod);
    }
    outReal[outIdx] = prevMinusDM;
    outIdx++;
  }
  return outReal;
}

List Mfi(
    List inHigh, List inLow, List inClose, List inVolume, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var mflowIdx = 0;
  var maxIdxMflow = (50 - 1);
  var mflow = new List(inTimePeriod);
  maxIdxMflow = inTimePeriod - 1;
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var outIdx = startIdx;
  var today = startIdx - lookbackTotal;
  var prevValue = (inHigh.elementAt(today) +
          inLow.elementAt(today) +
          inClose.elementAt(today)) /
      3.0;
  var posSumMF = 0.0;
  var negSumMF = 0.0;
  today++;
  for (var i = inTimePeriod; i > 0; i--) {
    var tempValue1 = (inHigh.elementAt(today) +
            inLow.elementAt(today) +
            inClose.elementAt(today)) /
        3.0;
    var tempValue2 = tempValue1 - prevValue;
    prevValue = tempValue1;
    tempValue1 *= inVolume.elementAt(today);
    today++;
    if (tempValue2 < 0) {
      (mflow.elementAt(mflowIdx)).negative = tempValue1;
      negSumMF += tempValue1;
      (mflow.elementAt(mflowIdx)).positive = 0.0;
    } else if (tempValue2 > 0) {
      (mflow.elementAt(mflowIdx)).positive = tempValue1;
      posSumMF += tempValue1;
      (mflow.elementAt(mflowIdx)).negative = 0.0;
    } else {
      (mflow.elementAt(mflowIdx)).positive = 0.0;
      (mflow.elementAt(mflowIdx)).negative = 0.0;
    }

    mflowIdx++;
    if (mflowIdx > maxIdxMflow) {
      mflowIdx = 0;
    }
  }
  if (today > startIdx) {
    var tempValue1 = posSumMF + negSumMF;
    if (tempValue1 < 1.0) {
    } else {
      outReal[outIdx] = 100.0 * (posSumMF / tempValue1);
      outIdx++;
    }
  } else {
    for (; today < startIdx;) {
      posSumMF -= mflow.elementAt(mflowIdx).positive;
      negSumMF -= mflow.elementAt(mflowIdx).negative;
      var tempValue1 = (inHigh.elementAt(today) +
              inLow.elementAt(today) +
              inClose.elementAt(today)) /
          3.0;
      var tempValue2 = tempValue1 - prevValue;
      prevValue = tempValue1;
      tempValue1 *= inVolume.elementAt(today);
      today++;
      if (tempValue2 < 0) {
        (mflow.elementAt(mflowIdx)).negative = tempValue1;
        negSumMF += tempValue1;
        (mflow.elementAt(mflowIdx)).positive = 0.0;
      } else if (tempValue2 > 0) {
        (mflow.elementAt(mflowIdx)).positive = tempValue1;
        posSumMF += tempValue1;
        (mflow.elementAt(mflowIdx)).negative = 0.0;
      } else {
        (mflow.elementAt(mflowIdx)).positive = 0.0;
        (mflow.elementAt(mflowIdx)).negative = 0.0;
      }

      mflowIdx++;
      if (mflowIdx > maxIdxMflow) {
        mflowIdx = 0;
      }
    }
  }
  for (; today < inClose.length;) {
    posSumMF -= (mflow.elementAt(mflowIdx)).positive;
    negSumMF -= (mflow.elementAt(mflowIdx)).negative;
    var tempValue1 = (inHigh.elementAt(today) +
            inLow.elementAt(today) +
            inClose.elementAt(today)) /
        3.0;
    var tempValue2 = tempValue1 - prevValue;
    prevValue = tempValue1;
    tempValue1 *= inVolume.elementAt(today);
    today++;
    if (tempValue2 < 0) {
      (mflow.elementAt(mflowIdx)).negative = tempValue1;
      negSumMF += tempValue1;
      (mflow.elementAt(mflowIdx)).positive = 0.0;
    } else if (tempValue2 > 0) {
      (mflow.elementAt(mflowIdx)).positive = tempValue1;
      posSumMF += tempValue1;
      (mflow.elementAt(mflowIdx)).negative = 0.0;
    } else {
      (mflow.elementAt(mflowIdx)).positive = 0.0;
      (mflow.elementAt(mflowIdx)).negative = 0.0;
    }

    tempValue1 = posSumMF + negSumMF;
    if (tempValue1 < 1.0) {
      outReal[outIdx] = 0.0;
    } else {
      outReal[outIdx] = 100.0 * (posSumMF / tempValue1);
    }
    outIdx++;
    mflowIdx++;
    if (mflowIdx > maxIdxMflow) {
      mflowIdx = 0;
    }
  }
  return outReal;
}

List Mom(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var inIdx = inTimePeriod;
  var outIdx = inTimePeriod;
  var trailingIdx = 0;
  for (; inIdx < inReal.length;) {
    outReal[outIdx] = inReal.elementAt(inIdx) - inReal.elementAt(trailingIdx);
    inIdx = inIdx + 1;
    outIdx = outIdx + 1;
    trailingIdx = trailingIdx + 1;
  }
  return outReal;
}

List PlusDI(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var lookbackTotal = 1;
  if (inTimePeriod > 1) {
    lookbackTotal = inTimePeriod;
  }

  var startIdx = lookbackTotal;
  var outIdx = startIdx;
  var prevHigh = 0.0;
  var prevLow = 0.0;
  var prevClose = 0.0;
  if (inTimePeriod <= 1) {
    var today = startIdx - 1;
    prevHigh = inHigh.elementAt(today);
    prevLow = inLow.elementAt(today);
    prevClose = inClose.elementAt(today);
    for (; today < inClose.length - 1;) {
      today++;
      var tempReal = inHigh.elementAt(today);
      var diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow.elementAt(today);
      var diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffP > 0) && (diffP > diffM)) {
        tempReal = prevHigh - prevLow;
        var tempReal2 = (prevHigh - prevClose).abs();
        if (tempReal2 > tempReal) {
          tempReal = tempReal2;
        }

        tempReal2 = (prevLow - prevClose).abs();
        if (tempReal2 > tempReal) {
          tempReal = tempReal2;
        }

        if (((-(0.00000000000001)) < tempReal) &&
            (tempReal < (0.00000000000001))) {
          outReal[outIdx] = 0.0;
        } else {
          outReal[outIdx] = diffP / tempReal;
        }
        outIdx++;
      } else {
        outReal[outIdx] = 0.0;
        outIdx++;
      }
      prevClose = inClose.elementAt(today);
    }
    return outReal;
  }

  var prevPlusDM = 0.0;
  var prevTR = 0.0;
  var today = startIdx - lookbackTotal;
  prevHigh = inHigh.elementAt(today);
  prevLow = inLow.elementAt(today);
  prevClose = inClose.elementAt(today);
  var i = inTimePeriod - 1;
  for (; i > 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM += diffP;
    }

    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR += tempReal;
    prevClose = inClose.elementAt(today);
  }
  i = 1;
  for (; i != 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod) + diffP;
    } else {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod);
    }
    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR = prevTR - (prevTR / inTimePeriod) + tempReal;
    prevClose = inClose.elementAt(today);
  }
  if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
    outReal[startIdx] = (100.0 * (prevPlusDM / prevTR));
  } else {
    outReal[startIdx] = 0.0;
  }
  outIdx = startIdx + 1;
  for (; today < inClose.length - 1;) {
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod) + diffP;
    } else {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod);
    }
    tempReal = prevHigh - prevLow;
    var tempReal2 = (prevHigh - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    tempReal2 = (prevLow - prevClose).abs();
    if (tempReal2 > tempReal) {
      tempReal = tempReal2;
    }

    prevTR = prevTR - (prevTR / inTimePeriod) + tempReal;
    prevClose = inClose.elementAt(today);
    if (!(((-(0.00000000000001)) < prevTR) && (prevTR < (0.00000000000001)))) {
      outReal[outIdx] = (100.0 * (prevPlusDM / prevTR));
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
  }
  return outReal;
}

List PlusDM(List inHigh, List inLow, int inTimePeriod) {
  var outReal = new List(inHigh.length);
  var lookbackTotal = 1;
  if (inTimePeriod > 1) {
    lookbackTotal = inTimePeriod - 1;
  }

  var startIdx = lookbackTotal;
  var outIdx = startIdx;
  var today = startIdx;
  var prevHigh = 0.0;
  var prevLow = 0.0;
  if (inTimePeriod <= 1) {
    today = startIdx - 1;
    prevHigh = inHigh.elementAt(today);
    prevLow = inLow.elementAt(today);
    for (; today < inHigh.length - 1;) {
      today++;
      var tempReal = inHigh.elementAt(today);
      var diffP = tempReal - prevHigh;
      prevHigh = tempReal;
      tempReal = inLow.elementAt(today);
      var diffM = prevLow - tempReal;
      prevLow = tempReal;
      if ((diffP > 0) && (diffP > diffM)) {
        outReal[outIdx] = diffP;
      } else {
        outReal[outIdx] = 0;
      }
      outIdx++;
    }
    return outReal;
  }

  var prevPlusDM = 0.0;
  today = startIdx - lookbackTotal;
  prevHigh = inHigh.elementAt(today);
  prevLow = inLow.elementAt(today);
  var i = inTimePeriod - 1;
  for (; i > 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM += diffP;
    }
  }
  i = 0;
  for (; i != 0;) {
    i--;
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod) + diffP;
    } else {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod);
    }
  }
  outReal[startIdx] = prevPlusDM;
  outIdx = startIdx + 1;
  for (; today < inHigh.length - 1;) {
    today++;
    var tempReal = inHigh.elementAt(today);
    var diffP = tempReal - prevHigh;
    prevHigh = tempReal;
    tempReal = inLow.elementAt(today);
    var diffM = prevLow - tempReal;
    prevLow = tempReal;
    if ((diffP > 0) && (diffP > diffM)) {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod) + diffP;
    } else {
      prevPlusDM = prevPlusDM - (prevPlusDM / inTimePeriod);
    }
    outReal[outIdx] = prevPlusDM;
    outIdx++;
  }
  return outReal;
}

List Ppo(List inReal, int inFastPeriod, int inSlowPeriod, MaType inMAType) {
  if (inSlowPeriod < inFastPeriod) {
    inSlowPeriod = inFastPeriod;
    inFastPeriod = inSlowPeriod;
  }

  var tempBuffer = Ma(inReal, inFastPeriod, inMAType);
  var outReal = Ma(inReal, inSlowPeriod, inMAType);
  for (var i = inSlowPeriod - 1; i < inReal.length; i++) {
    var tempReal = outReal.elementAt(i);
    if (!(((-(0.00000000000001)) < tempReal) &&
        (tempReal < (0.00000000000001)))) {
      outReal[i] = ((tempBuffer.elementAt(i) - tempReal) / tempReal) * 100.0;
    } else {
      outReal[i] = 0.0;
    }
  }
  return outReal;
}

List Rocp(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  if (inTimePeriod < 1) {
    return outReal;
  }

  var startIdx = inTimePeriod;
  var outIdx = startIdx;
  var inIdx = startIdx;
  var trailingIdx = startIdx - inTimePeriod;
  for (; inIdx < outReal.length;) {
    var tempReal = inReal.elementAt(trailingIdx);
    if (tempReal != 0.0) {
      outReal[outIdx] = (inReal.elementAt(inIdx) - tempReal) / tempReal;
    } else {
      outReal[outIdx] = 0.0;
    }
    trailingIdx++;
    outIdx++;
    inIdx++;
  }
  return outReal;
}

List Roc(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var startIdx = inTimePeriod;
  var outIdx = inTimePeriod;
  var inIdx = startIdx;
  var trailingIdx = startIdx - inTimePeriod;
  for (; inIdx < inReal.length;) {
    var tempReal = inReal.elementAt(trailingIdx);
    if (tempReal != 0.0) {
      outReal[outIdx] = ((inReal.elementAt(inIdx) / tempReal) - 1.0) * 100.0;
    } else {
      outReal[outIdx] = 0.0;
    }
    trailingIdx++;
    outIdx++;
    inIdx++;
  }
  return outReal;
}

List Rocr(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var startIdx = inTimePeriod;
  var outIdx = inTimePeriod;
  var inIdx = startIdx;
  var trailingIdx = startIdx - inTimePeriod;
  for (; inIdx < inReal.length;) {
    var tempReal = inReal.elementAt(trailingIdx);
    if (tempReal != 0.0) {
      outReal[outIdx] = (inReal.elementAt(inIdx) / tempReal);
    } else {
      outReal[outIdx] = 0.0;
    }
    trailingIdx++;
    outIdx++;
    inIdx++;
  }
  return outReal;
}

List Rocr100(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var startIdx = inTimePeriod;
  var outIdx = inTimePeriod;
  var inIdx = startIdx;
  var trailingIdx = startIdx - inTimePeriod;
  for (; inIdx < inReal.length;) {
    var tempReal = inReal.elementAt(trailingIdx);
    if (tempReal != 0.0) {
      outReal[outIdx] = (inReal.elementAt(inIdx) / tempReal) * 100.0;
    } else {
      outReal[outIdx] = 0.0;
    }
    trailingIdx++;
    outIdx++;
    inIdx++;
  }
  return outReal;
}

List Rsi(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  if (inTimePeriod < 2) {
    return outReal;
  }

  var tempValue1 = 0.0;
  var tempValue2 = 0.0;
  var outIdx = inTimePeriod;
  var today = 0;
  var prevValue = inReal.elementAt(today);
  var prevGain = 0.0;
  var prevLoss = 0.0;
  today++;
  for (var i = inTimePeriod; i > 0; i--) {
    tempValue1 = inReal.elementAt(today);
    today++;
    tempValue2 = tempValue1 - prevValue;
    prevValue = tempValue1;
    if (tempValue2 < 0) {
      prevLoss -= tempValue2;
    } else {
      prevGain += tempValue2;
    }
  }
  prevLoss /= inTimePeriod;
  prevGain /= inTimePeriod;
  if (today > 0) {
    tempValue1 = prevGain + prevLoss;
    if (!((-0.00000000000001 < tempValue1) &&
        (tempValue1 < 0.00000000000001))) {
      outReal[outIdx] = 100.0 * (prevGain / tempValue1);
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
  } else {
    for (; today < 0;) {
      tempValue1 = inReal.elementAt(today);
      tempValue2 = tempValue1 - prevValue;
      prevValue = tempValue1;
      prevLoss *= inTimePeriod - 1;
      prevGain *= inTimePeriod - 1;
      if (tempValue2 < 0) {
        prevLoss -= tempValue2;
      } else {
        prevGain += tempValue2;
      }
      prevLoss /= inTimePeriod;
      prevGain /= inTimePeriod;
      today++;
    }
  }
  for (; today < inReal.length;) {
    tempValue1 = inReal.elementAt(today);
    today++;
    tempValue2 = tempValue1 - prevValue;
    prevValue = tempValue1;
    prevLoss *= inTimePeriod - 1;
    prevGain *= inTimePeriod - 1;
    if (tempValue2 < 0) {
      prevLoss -= tempValue2;
    } else {
      prevGain += tempValue2;
    }
    prevLoss /= inTimePeriod;
    prevGain /= inTimePeriod;
    tempValue1 = prevGain + prevLoss;
    if (!((-0.00000000000001 < tempValue1) &&
        (tempValue1 < 0.00000000000001))) {
      outReal[outIdx] = 100.0 * (prevGain / tempValue1);
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
  }
  return outReal;
}

List Stoch(
    List inHigh,
    List inLow,
    List inClose,
    int inFastKPeriod,
    int inSlowKPeriod,
    MaType inSlowKMAType,
    int inSlowDPeriod,
    MaType inSlowDMAType) {
  var outSlowK = new List(inClose.length);
  var outSlowD = new List(inClose.length);
  var lookbackK = inFastKPeriod - 1;
  var lookbackKSlow = inSlowKPeriod - 1;
  var lookbackDSlow = inSlowDPeriod - 1;
  var lookbackTotal = lookbackK + lookbackDSlow + lookbackKSlow;
  var startIdx = lookbackTotal;
  var outIdx = 0;
  var trailingIdx = startIdx - lookbackTotal;
  var today = trailingIdx + lookbackK;
  var lowestIdx = -1;
  var highestIdx = -1;
  var diff = 0.0;
  var highest = 0.0;
  var lowest = 0.0;
  var tempBuffer = new List(inClose.length - today + 1);
  for (; today < inClose.length;) {
    var tmp = inLow.elementAt(today);
    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inLow.elementAt(lowestIdx);
      var i = lowestIdx + 1;
      for (; i <= today;) {
        var tmp = inLow.elementAt(i);
        if (tmp < lowest) {
          lowestIdx = i;
          lowest = tmp;
        }

        i++;
      }
      diff = (highest - lowest) / 100.0;
    } else if (tmp <= lowest) {
      lowestIdx = today;
      lowest = tmp;
      diff = (highest - lowest) / 100.0;
    }

    tmp = inHigh.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inHigh.elementAt(highestIdx);
      var i = highestIdx + 1;
      for (; i <= today;) {
        var tmp = inHigh.elementAt(i);
        if (tmp > highest) {
          highestIdx = i;
          highest = tmp;
        }

        i++;
      }
      diff = (highest - lowest) / 100.0;
    } else if (tmp >= highest) {
      highestIdx = today;
      highest = tmp;
      diff = (highest - lowest) / 100.0;
    }

    if (diff != 0.0) {
      tempBuffer[outIdx] = (inClose.elementAt(today) - lowest) / diff;
    } else {
      tempBuffer[outIdx] = 0.0;
    }
    outIdx++;
    trailingIdx++;
    today++;
  }
  var tempBuffer1 = Ma(tempBuffer, inSlowKPeriod, inSlowKMAType);
  var tempBuffer2 = Ma(tempBuffer1, inSlowDPeriod, inSlowDMAType);

  for (var i = lookbackDSlow + lookbackKSlow, j = lookbackTotal;
      j < inClose.length;
      i = i + 1, j = j + 1) {
    outSlowK[j] = tempBuffer1.elementAt(i);
    outSlowD[j] = tempBuffer2.elementAt(i);
  }

  return [outSlowK, outSlowD];
}

List StochF(List inHigh, List inLow, List inClose, int inFastKPeriod,
    int inFastDPeriod, MaType inFastDMAType) {
  var outFastK = new List(inClose.length);
  var outFastD = new List(inClose.length);
  var lookbackK = inFastKPeriod - 1;
  var lookbackFastD = inFastDPeriod - 1;
  var lookbackTotal = lookbackK + lookbackFastD;
  var startIdx = lookbackTotal;
  var outIdx = 0;
  var trailingIdx = startIdx - lookbackTotal;
  var today = trailingIdx + lookbackK;
  var lowestIdx = -1;
  var highestIdx = -1;
  var diff = 0.0;
  var highest = 0.0;
  var lowest = 0.0;
  var tempBuffer = new List((inClose.length - today + 1));
  for (; today < inClose.length;) {
    var tmp = inLow.elementAt(today);
    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inLow.elementAt(lowestIdx);
      var i = lowestIdx;
      i++;
      for (; i <= today;) {
        tmp = inLow.elementAt(i);
        if (tmp < lowest) {
          lowestIdx = i;
          lowest = tmp;
        }

        i++;
      }
      diff = (highest - lowest) / 100.0;
    } else if (tmp <= lowest) {
      lowestIdx = today;
      lowest = tmp;
      diff = (highest - lowest) / 100.0;
    }

    tmp = inHigh.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inHigh.elementAt(highestIdx);
      var i = highestIdx;
      i++;
      for (; i <= today;) {
        tmp = inHigh.elementAt(i);
        if (tmp > highest) {
          highestIdx = i;
          highest = tmp;
        }

        i++;
      }
      diff = (highest - lowest) / 100.0;
    } else if (tmp >= highest) {
      highestIdx = today;
      highest = tmp;
      diff = (highest - lowest) / 100.0;
    }

    if (diff != 0.0) {
      tempBuffer[outIdx] = (inClose.elementAt(today) - lowest) / diff;
    } else {
      tempBuffer[outIdx] = 0.0;
    }
    outIdx++;
    trailingIdx++;
    today++;
  }
  var tempBuffer1 = Ma(tempBuffer, inFastDPeriod, inFastDMAType);
  for (var i = lookbackFastD, j = lookbackTotal;
      j < inClose.length;
      i = i + 1, j = j + 1) {
    outFastK[j] = tempBuffer.elementAt(i);
    outFastD[j] = tempBuffer1.elementAt(i);
  }
  return [outFastK, outFastD];
}

List StochRsi(List inReal, int inTimePeriod, int inFastKPeriod,
    int inFastDPeriod, MaType inFastDMAType) {
  var outFastK = new List(inReal.length);
  var outFastD = new List(inReal.length);
  var lookbackSTOCHF = (inFastKPeriod - 1) + (inFastDPeriod - 1);
  var lookbackTotal = inTimePeriod + lookbackSTOCHF;
  var startIdx = lookbackTotal;
  var tempRSIBuffer = Rsi(inReal, inTimePeriod);
  var tmpList = StochF(tempRSIBuffer, tempRSIBuffer, tempRSIBuffer,
      inFastKPeriod, inFastDPeriod, inFastDMAType);
  var tempk = tmpList[0];
  var tempd = tmpList[1];
  ;
  for (var i = startIdx; i < inReal.length; i++) {
    outFastK[i] = tempk.elementAt(i);
    outFastD[i] = tempd.elementAt(i);
  }
  return [outFastK, outFastD];
}

List Trix(List inReal, int inTimePeriod) {
  var tmpReal = Ema(inReal, inTimePeriod);
  tmpReal = Ema(
      tmpReal.sublist(
        inTimePeriod - 1,
      ),
      inTimePeriod);
  tmpReal = Ema(
      tmpReal.sublist(
        inTimePeriod - 1,
      ),
      inTimePeriod);
  tmpReal = Roc(tmpReal, 1);
  var outReal = new List(inReal.length);

  for (var i = inTimePeriod, j = ((inTimePeriod - 1) * 3) + 1;
      j < outReal.length;
      i = i + 1, j = j + 1) {
    outReal[j] = tmpReal.elementAt(i);
  }
  return outReal;
}

List UltOsc(List inHigh, List inLow, List inClose, int inTimePeriod1,
    int inTimePeriod2, int inTimePeriod3) {
  var outReal = new List(inClose.length);
  var usedFlag = new List(3);
  var periods = new List(3);
  var sortedPeriods = new List(3);
  periods[0] = inTimePeriod1;
  periods[1] = inTimePeriod2;
  periods[2] = inTimePeriod3;
  for (var i = 0; i < 3; i++) {
    var longestPeriod = 0;
    var longestIndex = 0;
    for (var j = 0; j < 3; j++) {
      if ((usedFlag.elementAt(j) == 0) &&
          (periods.elementAt(j) > longestPeriod)) {
        longestPeriod = periods.elementAt(j);
        longestIndex = j;
      }
    }
    usedFlag[longestIndex] = 1;
    sortedPeriods[i] = longestPeriod;
  }
  inTimePeriod1 = sortedPeriods.elementAt(2);
  inTimePeriod2 = sortedPeriods.elementAt(1);
  inTimePeriod3 = sortedPeriods.elementAt(0);
  var lookbackTotal = 0;
  if (inTimePeriod1 > inTimePeriod2) {
    lookbackTotal = inTimePeriod1;
  }

  if (inTimePeriod3 > lookbackTotal) {
    lookbackTotal = inTimePeriod3;
  }

  lookbackTotal++;
  var startIdx = lookbackTotal - 1;
  var a1Total = 0.0;
  var b1Total = 0.0;
  for (var i = startIdx - inTimePeriod1 + 1; i < startIdx; i++) {
    var tempLT = inLow.elementAt(i);
    var tempHT = inHigh.elementAt(i);
    var tempCY = inClose.elementAt(i - 1);
    var trueLow = 0.0;
    if (tempLT < tempCY) {
      trueLow = tempLT;
    } else {
      trueLow = tempCY;
    }
    var closeMinusTrueLow = inClose.elementAt(i) - trueLow;
    var trueRange = tempHT - tempLT;
    var tempDouble = (tempCY - tempHT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    tempDouble = (tempCY - tempLT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    a1Total += closeMinusTrueLow;
    b1Total += trueRange;
  }
  var a2Total = 0.0;
  var b2Total = 0.0;
  for (var i = startIdx - inTimePeriod2 + 1; i < startIdx; i++) {
    var tempLT = inLow.elementAt(i);
    var tempHT = inHigh.elementAt(i);
    var tempCY = inClose.elementAt(i - 1);
    var trueLow = 0.0;
    if (tempLT < tempCY) {
      trueLow = tempLT;
    } else {
      trueLow = tempCY;
    }
    var closeMinusTrueLow = inClose.elementAt(i) - trueLow;
    var trueRange = tempHT - tempLT;
    var tempDouble = (tempCY - tempHT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    tempDouble = (tempCY - tempLT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    a2Total += closeMinusTrueLow;
    b2Total += trueRange;
  }
  var a3Total = 0.0;
  var b3Total = 0.0;
  for (var i = startIdx - inTimePeriod3 + 1; i < startIdx; i++) {
    var tempLT = inLow.elementAt(i);
    var tempHT = inHigh.elementAt(i);
    var tempCY = inClose.elementAt(i - 1);
    var trueLow = 0.0;
    if (tempLT < tempCY) {
      trueLow = tempLT;
    } else {
      trueLow = tempCY;
    }
    var closeMinusTrueLow = inClose.elementAt(i) - trueLow;
    var trueRange = tempHT - tempLT;
    var tempDouble = (tempCY - tempHT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    tempDouble = (tempCY - tempLT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    a3Total += closeMinusTrueLow;
    b3Total += trueRange;
  }
  var today = startIdx;
  var outIdx = startIdx;
  var trailingIdx1 = today - inTimePeriod1 + 1;
  var trailingIdx2 = today - inTimePeriod2 + 1;
  var trailingIdx3 = today - inTimePeriod3 + 1;
  for (; today < inClose.length;) {
    var tempLT = inLow.elementAt(today);
    var tempHT = inHigh.elementAt(today);
    var tempCY = inClose.elementAt(today - 1);
    var trueLow = 0.0;
    if (tempLT < tempCY) {
      trueLow = tempLT;
    } else {
      trueLow = tempCY;
    }
    var closeMinusTrueLow = inClose.elementAt(today) - trueLow;
    var trueRange = tempHT - tempLT;
    var tempDouble = (tempCY - tempHT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    tempDouble = (tempCY - tempLT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    a1Total += closeMinusTrueLow;
    a2Total += closeMinusTrueLow;
    a3Total += closeMinusTrueLow;
    b1Total += trueRange;
    b2Total += trueRange;
    b3Total += trueRange;
    var output = 0.0;
    if (!(((-(0.00000000000001)) < b1Total) &&
        (b1Total < (0.00000000000001)))) {
      output += 4.0 * (a1Total / b1Total);
    }

    if (!(((-(0.00000000000001)) < b2Total) &&
        (b2Total < (0.00000000000001)))) {
      output += 2.0 * (a2Total / b2Total);
    }

    if (!(((-(0.00000000000001)) < b3Total) &&
        (b3Total < (0.00000000000001)))) {
      output += a3Total / b3Total;
    }

    tempLT = inLow.elementAt(trailingIdx1);
    tempHT = inHigh.elementAt(trailingIdx1);
    tempCY = inClose.elementAt(trailingIdx1 - 1);
    trueLow = 0.0;
    if (tempLT < tempCY) {
      trueLow = tempLT;
    } else {
      trueLow = tempCY;
    }
    closeMinusTrueLow = inClose.elementAt(trailingIdx1) - trueLow;
    trueRange = tempHT - tempLT;
    tempDouble = (tempCY - tempHT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    tempDouble = (tempCY - tempLT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    a1Total -= closeMinusTrueLow;
    b1Total -= trueRange;
    tempLT = inLow.elementAt(trailingIdx2);
    tempHT = inHigh.elementAt(trailingIdx2);
    tempCY = inClose.elementAt(trailingIdx2 - 1);
    trueLow = 0.0;
    if (tempLT < tempCY) {
      trueLow = tempLT;
    } else {
      trueLow = tempCY;
    }
    closeMinusTrueLow = inClose.elementAt(trailingIdx2) - trueLow;
    trueRange = tempHT - tempLT;
    tempDouble = (tempCY - tempHT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    tempDouble = (tempCY - tempLT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    a2Total -= closeMinusTrueLow;
    b2Total -= trueRange;
    tempLT = inLow.elementAt(trailingIdx3);
    tempHT = inHigh.elementAt(trailingIdx3);
    tempCY = inClose.elementAt(trailingIdx3 - 1);
    trueLow = 0.0;
    if (tempLT < tempCY) {
      trueLow = tempLT;
    } else {
      trueLow = tempCY;
    }
    closeMinusTrueLow = inClose.elementAt(trailingIdx3) - trueLow;
    trueRange = tempHT - tempLT;
    tempDouble = (tempCY - tempHT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    tempDouble = (tempCY - tempLT).abs();
    if (tempDouble > trueRange) {
      trueRange = tempDouble;
    }

    a3Total -= closeMinusTrueLow;
    b3Total -= trueRange;
    outReal[outIdx] = 100.0 * (output / 7.0);
    outIdx++;
    today++;
    trailingIdx1++;
    trailingIdx2++;
    trailingIdx3++;
  }
  return outReal;
}

List WillR(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var nbInitialElementNeeded = (inTimePeriod - 1);
  var diff = 0.0;
  var outIdx = inTimePeriod - 1;
  var startIdx = inTimePeriod - 1;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var highestIdx = -1;
  var lowestIdx = -1;
  var highest = 0.0;
  var lowest = 0.0;
  var i = 0;
  for (; today < inClose.length;) {
    var tmp = inLow.elementAt(today);
    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inLow.elementAt(lowestIdx);
      i = lowestIdx;
      i++;
      for (; i <= today;) {
        tmp = inLow.elementAt(i);
        if (tmp < lowest) {
          lowestIdx = i;
          lowest = tmp;
        }

        i++;
      }
      diff = (highest - lowest) / (-100.0);
    } else if (tmp <= lowest) {
      lowestIdx = today;
      lowest = tmp;
      diff = (highest - lowest) / (-100.0);
    }

    tmp = inHigh.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inHigh.elementAt(highestIdx);
      i = highestIdx;
      i++;
      for (; i <= today;) {
        tmp = inHigh.elementAt(i);
        if (tmp > highest) {
          highestIdx = i;
          highest = tmp;
        }

        i++;
      }
      diff = (highest - lowest) / (-100.0);
    } else if (tmp >= highest) {
      highestIdx = today;
      highest = tmp;
      diff = (highest - lowest) / (-100.0);
    }

    if (diff != 0.0) {
      outReal[outIdx] = (highest - inClose.elementAt(today)) / diff;
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
    trailingIdx++;
    today++;
  }
  return outReal;
}

List Ad(List inHigh, List inLow, List inClose, List inVolume) {
  var outReal = new List(inClose.length);
  var startIdx = 0;
  var nbBar = inClose.length - startIdx;
  var currentBar = startIdx;
  var outIdx = 0;
  var ad = 0.0;
  for (; nbBar != 0;) {
    var high = inHigh.elementAt(currentBar);
    var low = inLow.elementAt(currentBar);
    var tmp = high - low;
    var close = inClose.elementAt(currentBar);
    if (tmp > 0.0) {
      ad += (((close - low) - (high - close)) / tmp) *
          (inVolume.elementAt(currentBar));
    }

    outReal[outIdx] = ad;
    outIdx++;
    currentBar++;
    nbBar--;
  }
  return outReal;
}

List AdOsc(List inHigh, List inLow, List inClose, List inVolume,
    int inFastPeriod, int inSlowPeriod) {
  var outReal = new List(inClose.length);
  if ((inFastPeriod < 2) || (inSlowPeriod < 2)) {
    return outReal;
  }

  var slowestPeriod = 0;
  if (inFastPeriod < inSlowPeriod) {
    slowestPeriod = inSlowPeriod;
  } else {
    slowestPeriod = inFastPeriod;
  }
  var lookbackTotal = slowestPeriod - 1;
  var startIdx = lookbackTotal;
  var today = startIdx - lookbackTotal;
  var ad = 0.0;
  var fastk = (2.0 / (inFastPeriod + 1.0));
  var oneMinusfastk = 1.0 - fastk;
  var slowk = (2.0 / (inSlowPeriod + 1.0));
  var oneMinusslowk = 1.0 - slowk;
  var high = inHigh.elementAt(today);
  var low = inLow.elementAt(today);
  var tmp = high - low;
  var close = inClose.elementAt(today);
  if (tmp > 0.0) {
    ad +=
        (((close - low) - (high - close)) / tmp) * (inVolume.elementAt(today));
  }

  today++;
  var fastEMA = ad;
  var slowEMA = ad;
  for (; today < startIdx;) {
    high = inHigh.elementAt(today);
    low = inLow.elementAt(today);
    tmp = high - low;
    close = inClose.elementAt(today);
    if (tmp > 0.0) {
      ad += (((close - low) - (high - close)) / tmp) *
          (inVolume.elementAt(today));
    }

    today++;
    fastEMA = (fastk * ad) + (oneMinusfastk * fastEMA);
    slowEMA = (slowk * ad) + (oneMinusslowk * slowEMA);
  }
  var outIdx = lookbackTotal;
  for (; today < inClose.length;) {
    high = inHigh.elementAt(today);
    low = inLow.elementAt(today);
    tmp = high - low;
    close = inClose.elementAt(today);
    if (tmp > 0.0) {
      ad += (((close - low) - (high - close)) / tmp) *
          (inVolume.elementAt(today));
    }

    today++;
    fastEMA = (fastk * ad) + (oneMinusfastk * fastEMA);
    slowEMA = (slowk * ad) + (oneMinusslowk * slowEMA);
    outReal[outIdx] = fastEMA - slowEMA;
    outIdx++;
  }
  return outReal;
}

List Obv(List inReal, List inVolume) {
  var outReal = new List(inReal.length);
  var startIdx = 0;
  var prevOBV = inVolume.elementAt(startIdx);
  var prevReal = inReal.elementAt(startIdx);
  var outIdx = 0;
  for (var i = startIdx; i < inReal.length; i++) {
    var tempReal = inReal.elementAt(i);
    if (tempReal > prevReal) {
      prevOBV += inVolume.elementAt(i);
    } else if (tempReal < prevReal) {
      prevOBV -= inVolume.elementAt(i);
    }

    outReal[outIdx] = prevOBV;
    prevReal = tempReal;
    outIdx++;
  }
  return outReal;
}

List Atr(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  var inTimePeriodF = inTimePeriod;
  if (inTimePeriod < 1) {
    return outReal;
  }

  if (inTimePeriod <= 1) {
    return TRange(inHigh, inLow, inClose);
  }

  var outIdx = inTimePeriod;
  var today = inTimePeriod + 1;
  var tr = TRange(inHigh, inLow, inClose);
  var prevATRTemp = Sma(tr, inTimePeriod);
  var prevATR = prevATRTemp.elementAt(inTimePeriod);
  outReal[inTimePeriod] = prevATR;
  for (outIdx = inTimePeriod + 1; outIdx < inClose.length; outIdx++) {
    prevATR *= inTimePeriodF - 1.0;
    prevATR += tr.elementAt(today);
    prevATR /= inTimePeriodF;
    outReal[outIdx] = prevATR;
    today++;
  }
  return outReal;
}

List Natr(List inHigh, List inLow, List inClose, int inTimePeriod) {
  var outReal = new List(inClose.length);
  if (inTimePeriod < 1) {
    return outReal;
  }

  if (inTimePeriod <= 1) {
    return TRange(inHigh, inLow, inClose);
  }

  var inTimePeriodF = inTimePeriod;
  var outIdx = inTimePeriod;
  var today = inTimePeriod;
  var tr = TRange(inHigh, inLow, inClose);
  var prevATRTemp = Sma(tr, inTimePeriod);
  var prevATR = prevATRTemp.elementAt(inTimePeriod);
  var tempValue = inClose.elementAt(today);
  if (tempValue != 0.0) {
    outReal[outIdx] = (prevATR / tempValue) * 100.0;
  } else {
    outReal[outIdx] = 0.0;
  }
  for (outIdx = inTimePeriod + 1; outIdx < inClose.length; outIdx++) {
    today++;
    prevATR *= inTimePeriodF - 1.0;
    prevATR += tr.elementAt(today);
    prevATR /= inTimePeriodF;
    tempValue = inClose.elementAt(today);
    if (tempValue != 0.0) {
      outReal[outIdx] = (prevATR / tempValue) * 100.0;
    } else {
      outReal[0] = 0.0;
    }
  }
  return outReal;
}

List TRange(List inHigh, List inLow, List inClose) {
  var outReal = new List(inClose.length);
  var startIdx = 1;
  var outIdx = startIdx;
  var today = startIdx;
  for (; today < inClose.length;) {
    var tempLT = inLow.elementAt(today);
    var tempHT = inHigh.elementAt(today);
    var tempCY = inClose.elementAt(today - 1);
    var greatest = tempHT - tempLT;
    var val2 = (tempCY - tempHT).abs();
    if (val2 > greatest) {
      greatest = val2;
    }

    var val3 = (tempCY - tempLT).abs();
    if (val3 > greatest) {
      greatest = val3;
    }

    outReal[outIdx] = greatest;
    outIdx++;
    today++;
  }
  return outReal;
}

List AvgPrice(List inOpen, List inHigh, List inLow, List inClose) {
  var outReal = new List(inClose.length);
  var outIdx = 0;
  var startIdx = 0;
  for (var i = startIdx; i < inClose.length; i++) {
    outReal[outIdx] = (inHigh.elementAt(i) +
            inLow.elementAt(i) +
            inClose.elementAt(i) +
            inOpen.elementAt(i)) /
        4;
    outIdx++;
  }
  return outReal;
}

List MedPrice(List inHigh, List inLow) {
  var outReal = new List(inHigh.length);
  var outIdx = 0;
  var startIdx = 0;
  for (var i = startIdx; i < inHigh.length; i++) {
    outReal[outIdx] = (inHigh.elementAt(i) + inLow.elementAt(i)) / 2.0;
    outIdx++;
  }
  return outReal;
}

List TypPrice(List inHigh, List inLow, List inClose) {
  var outReal = new List(inClose.length);
  var outIdx = 0;
  var startIdx = 0;
  for (var i = startIdx; i < inClose.length; i++) {
    outReal[outIdx] =
        (inHigh.elementAt(i) + inLow.elementAt(i) + inClose.elementAt(i)) / 3.0;
    outIdx++;
  }
  return outReal;
}

List WclPrice(List inHigh, List inLow, List inClose) {
  var outReal = new List(inClose.length);
  var outIdx = 0;
  var startIdx = 0;
  for (var i = startIdx; i < inClose.length; i++) {
    outReal[outIdx] = (inHigh.elementAt(i) +
            inLow.elementAt(i) +
            (inClose.elementAt(i) * 2.0)) /
        4.0;
    outIdx++;
  }
  return outReal;
}

List HtDcPeriod(List inReal) {
  var outReal = new List(inReal.length);
  var a = 0.0962;
  var b = 0.5769;
  var detrenderOdd = new List(3);
  var detrenderEven = new List(3);
  var q1Odd = new List(3);
  var q1Even = new List(3);
  var jIOdd = new List(3);
  var jIEven = new List(3);
  var jQOdd = new List(3);
  var jQEven = new List(3);
  var rad2Deg = 180.0 / (4.0 * math.atan(1));
  var lookbackTotal = 32;
  var startIdx = lookbackTotal;
  var trailingWMAIdx = startIdx - lookbackTotal;
  var today = trailingWMAIdx;
  var tempReal = inReal.elementAt(today);
  today++;
  var periodWMASub = tempReal;
  var periodWMASum = tempReal;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 2.0;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 3.0;
  var trailingWMAValue = 0.0;
  var i = 9;
  var smoothedValue = 0.0;
  for (var ok = true; ok;) {
    tempReal = inReal.elementAt(today);
    today++;
    periodWMASub += tempReal;
    periodWMASub -= trailingWMAValue;
    periodWMASum += tempReal * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    i--;
    ok = i != 0;
  }
  var hilbertIdx = 0;
  var detrender = 0.0;
  var prevDetrenderOdd = 0.0;
  var prevDetrenderEven = 0.0;
  var prevDetrenderInputOdd = 0.0;
  var prevDetrenderInputEven = 0.0;
  var q1 = 0.0;
  var prevq1Odd = 0.0;
  var prevq1Even = 0.0;
  var prevq1InputOdd = 0.0;
  var prevq1InputEven = 0.0;
  var jI = 0.0;
  var prevJIOdd = 0.0;
  var prevJIEven = 0.0;
  var prevJIInputOdd = 0.0;
  var prevJIInputEven = 0.0;
  var jQ = 0.0;
  var prevJQOdd = 0.0;
  var prevJQEven = 0.0;
  var prevJQInputOdd = 0.0;
  var prevJQInputEven = 0.0;
  var period = 0.0;
  var outIdx = 32;
  var previ2 = 0.0;
  var prevq2 = 0.0;
  var Re = 0.0;
  var Im = 0.0;
  var i2 = 0.0;
  var q2 = 0.0;
  var i1ForOddPrev3 = 0.0;
  var i1ForEvenPrev3 = 0.0;
  var i1ForOddPrev2 = 0.0;
  var i1ForEvenPrev2 = 0.0;
  var smoothPeriod = 0.0;
  for (; today < inReal.length;) {
    var adjustedPrevPeriod = (0.075 * period) + 0.54;
    var todayValue = inReal.elementAt(today);
    periodWMASub += todayValue;
    periodWMASub -= trailingWMAValue;
    periodWMASum += todayValue * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    var hilbertTempReal = 0.0;
    if ((today % 2) == 0) {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderEven.elementAt(hilbertIdx);
      detrenderEven[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderEven;
      prevDetrenderEven = b * prevDetrenderInputEven;
      detrender += prevDetrenderEven;
      prevDetrenderInputEven = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Even.elementAt(hilbertIdx);
      q1Even[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Even;
      prevq1Even = b * prevq1InputEven;
      q1 += prevq1Even;
      prevq1InputEven = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForEvenPrev3;
      jI = -jIEven.elementAt(hilbertIdx);
      jIEven[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIEven;
      prevJIEven = b * prevJIInputEven;
      jI += prevJIEven;
      prevJIInputEven = i1ForEvenPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQEven.elementAt(hilbertIdx);
      jQEven[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQEven;
      prevJQEven = b * prevJQInputEven;
      jQ += prevJQEven;
      prevJQInputEven = q1;
      jQ *= adjustedPrevPeriod;
      hilbertIdx++;
      if (hilbertIdx == 3) {
        hilbertIdx = 0;
      }

      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForEvenPrev3 - jQ)) + (0.8 * previ2);
      i1ForOddPrev3 = i1ForOddPrev2;
      i1ForOddPrev2 = detrender;
    } else {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderOdd.elementAt(hilbertIdx);
      detrenderOdd[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderOdd;
      prevDetrenderOdd = b * prevDetrenderInputOdd;
      detrender += prevDetrenderOdd;
      prevDetrenderInputOdd = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Odd.elementAt(hilbertIdx);
      q1Odd[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Odd;
      prevq1Odd = b * prevq1InputOdd;
      q1 += prevq1Odd;
      prevq1InputOdd = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForOddPrev3;
      jI = -jIOdd.elementAt(hilbertIdx);
      jIOdd[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIOdd;
      prevJIOdd = b * prevJIInputOdd;
      jI += prevJIOdd;
      prevJIInputOdd = i1ForOddPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQOdd.elementAt(hilbertIdx);
      jQOdd[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQOdd;
      prevJQOdd = b * prevJQInputOdd;
      jQ += prevJQOdd;
      prevJQInputOdd = q1;
      jQ *= adjustedPrevPeriod;
      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForOddPrev3 - jQ)) + (0.8 * previ2);
      i1ForEvenPrev3 = i1ForEvenPrev2;
      i1ForEvenPrev2 = detrender;
    }
    Re = (0.2 * ((i2 * previ2) + (q2 * prevq2))) + (0.8 * Re);
    Im = (0.2 * ((i2 * prevq2) - (q2 * previ2))) + (0.8 * Im);
    prevq2 = q2;
    previ2 = i2;
    tempReal = period;
    if ((Im != 0.0) && (Re != 0.0)) {
      period = 360.0 / (math.atan(Im / Re) * rad2Deg);
    }

    var tempReal2 = 1.5 * tempReal;
    if (period > tempReal2) {
      period = tempReal2;
    }

    tempReal2 = 0.67 * tempReal;
    if (period < tempReal2) {
      period = tempReal2;
    }

    if (period < 6) {
      period = 6;
    } else if (period > 50) {
      period = 50;
    }

    period = (0.2 * period) + (0.8 * tempReal);
    smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod);
    if (today >= startIdx) {
      outReal[outIdx] = smoothPeriod;
      outIdx++;
    }

    today++;
  }
  return outReal;
}

List HtDcPhase(List inReal) {
  var outReal = new List(inReal.length);
  var a = 0.0962;
  var b = 0.5769;
  var detrenderOdd = new List(3);
  var detrenderEven = new List(3);
  var q1Odd = new List(3);
  var q1Even = new List(3);
  var jIOdd = new List(3);
  var jIEven = new List(3);
  var jQOdd = new List(3);
  var jQEven = new List(3);
  var smoothPriceIdx = 0;
  var maxIdxSmoothPrice = (50 - 1);
  var smoothPrice = new List(maxIdxSmoothPrice + 1);
  var tempReal = math.atan(1);
  var rad2Deg = 45.0 / tempReal;
  var constDeg2RadBy360 = tempReal * 8.0;
  var lookbackTotal = 63;
  var startIdx = lookbackTotal;
  var trailingWMAIdx = startIdx - lookbackTotal;
  var today = trailingWMAIdx;
  tempReal = inReal.elementAt(today);
  today++;
  var periodWMASub = tempReal;
  var periodWMASum = tempReal;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 2.0;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 3.0;
  var trailingWMAValue = 0.0;
  var i = 34;
  var smoothedValue = 0.0;
  for (var ok = true; ok;) {
    tempReal = inReal.elementAt(today);
    today++;
    periodWMASub += tempReal;
    periodWMASub -= trailingWMAValue;
    periodWMASum += tempReal * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    i--;
    ok = i != 0;
  }
  var hilbertIdx = 0;
  var detrender = 0.0;
  var prevDetrenderOdd = 0.0;
  var prevDetrenderEven = 0.0;
  var prevDetrenderInputOdd = 0.0;
  var prevDetrenderInputEven = 0.0;
  var q1 = 0.0;
  var prevq1Odd = 0.0;
  var prevq1Even = 0.0;
  var prevq1InputOdd = 0.0;
  var prevq1InputEven = 0.0;
  var jI = 0.0;
  var prevJIOdd = 0.0;
  var prevJIEven = 0.0;
  var prevJIInputOdd = 0.0;
  var prevJIInputEven = 0.0;
  var jQ = 0.0;
  var prevJQOdd = 0.0;
  var prevJQEven = 0.0;
  var prevJQInputOdd = 0.0;
  var prevJQInputEven = 0.0;
  var period = 0.0;
  var outIdx = 0;
  var previ2 = 0.0;
  var prevq2 = 0.0;
  var Re = 0.0;
  var Im = 0.0;
  var i1ForOddPrev3 = 0.0;
  var i1ForEvenPrev3 = 0.0;
  var i1ForOddPrev2 = 0.0;
  var i1ForEvenPrev2 = 0.0;
  var smoothPeriod = 0.0;
  var dcPhase = 0.0;
  var q2 = 0.0;
  var i2 = 0.0;
  for (; today < inReal.length;) {
    var adjustedPrevPeriod = (0.075 * period) + 0.54;
    var todayValue = inReal.elementAt(today);
    periodWMASub += todayValue;
    periodWMASub -= trailingWMAValue;
    periodWMASum += todayValue * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    var hilbertTempReal = 0.0;
    smoothPrice[smoothPriceIdx] = smoothedValue;
    if ((today % 2) == 0) {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderEven.elementAt(hilbertIdx);
      detrenderEven[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderEven;
      prevDetrenderEven = b * prevDetrenderInputEven;
      detrender += prevDetrenderEven;
      prevDetrenderInputEven = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Even.elementAt(hilbertIdx);
      q1Even[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Even;
      prevq1Even = b * prevq1InputEven;
      q1 += prevq1Even;
      prevq1InputEven = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForEvenPrev3;
      jI = -jIEven.elementAt(hilbertIdx);
      jIEven[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIEven;
      prevJIEven = b * prevJIInputEven;
      jI += prevJIEven;
      prevJIInputEven = i1ForEvenPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQEven.elementAt(hilbertIdx);
      jQEven[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQEven;
      prevJQEven = b * prevJQInputEven;
      jQ += prevJQEven;
      prevJQInputEven = q1;
      jQ *= adjustedPrevPeriod;
      hilbertIdx++;
      if (hilbertIdx == 3) {
        hilbertIdx = 0;
      }

      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForEvenPrev3 - jQ)) + (0.8 * previ2);
      i1ForOddPrev3 = i1ForOddPrev2;
      i1ForOddPrev2 = detrender;
    } else {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderOdd.elementAt(hilbertIdx);
      detrenderOdd[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderOdd;
      prevDetrenderOdd = b * prevDetrenderInputOdd;
      detrender += prevDetrenderOdd;
      prevDetrenderInputOdd = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Odd.elementAt(hilbertIdx);
      q1Odd[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Odd;
      prevq1Odd = b * prevq1InputOdd;
      q1 += prevq1Odd;
      prevq1InputOdd = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForOddPrev3;
      jI = -jIOdd.elementAt(hilbertIdx);
      jIOdd[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIOdd;
      prevJIOdd = b * prevJIInputOdd;
      jI += prevJIOdd;
      prevJIInputOdd = i1ForOddPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQOdd.elementAt(hilbertIdx);
      jQOdd[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQOdd;
      prevJQOdd = b * prevJQInputOdd;
      jQ += prevJQOdd;
      prevJQInputOdd = q1;
      jQ *= adjustedPrevPeriod;
      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForOddPrev3 - jQ)) + (0.8 * previ2);
      i1ForEvenPrev3 = i1ForEvenPrev2;
      i1ForEvenPrev2 = detrender;
    }
    Re = (0.2 * ((i2 * previ2) + (q2 * prevq2))) + (0.8 * Re);
    Im = (0.2 * ((i2 * prevq2) - (q2 * previ2))) + (0.8 * Im);
    prevq2 = q2;
    previ2 = i2;
    tempReal = period;
    if ((Im != 0.0) && (Re != 0.0)) {
      period = 360.0 / (math.atan(Im / Re) * rad2Deg);
    }

    var tempReal2 = 1.5 * tempReal;
    if (period > tempReal2) {
      period = tempReal2;
    }

    tempReal2 = 0.67 * tempReal;
    if (period < tempReal2) {
      period = tempReal2;
    }

    if (period < 6) {
      period = 6;
    } else if (period > 50) {
      period = 50;
    }

    period = (0.2 * period) + (0.8 * tempReal);
    smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod);
    var DCPeriod = smoothPeriod + 0.5;
    var DCPeriodInt = DCPeriod.floor();
    var realPart = 0.0;
    var imagPart = 0.0;
    var idx = smoothPriceIdx;
    for (var i = 0; i < DCPeriodInt; i++) {
      tempReal = (i * constDeg2RadBy360) / (DCPeriodInt * 1.0);
      tempReal2 = smoothPrice.elementAt(idx);
      realPart += math.sin(tempReal) * tempReal2;
      imagPart += math.cos(tempReal) * tempReal2;
      if (idx == 0) {
        idx = 50 - 1;
      } else {
        idx--;
      }
    }
    tempReal = imagPart.abs();
    if (tempReal > 0.0) {
      dcPhase = math.atan(realPart / imagPart) * rad2Deg;
    } else if (tempReal <= 0.01) {
      if (realPart < 0.0) {
        dcPhase -= 90.0;
      } else if (realPart > 0.0) {
        dcPhase += 90.0;
      }
    }

    dcPhase += 90.0;
    dcPhase += 360.0 / smoothPeriod;
    if (imagPart < 0.0) {
      dcPhase += 180.0;
    }

    if (dcPhase > 315.0) {
      dcPhase -= 360.0;
    }

    if (today >= startIdx) {
      outReal[outIdx] = dcPhase;
      outIdx++;
    }

    smoothPriceIdx++;
    if (smoothPriceIdx > maxIdxSmoothPrice) {
      smoothPriceIdx = 0;
    }

    today++;
  }
  return outReal;
}

List HtPhasor(List inReal) {
  var outInPhase = new List(inReal.length);
  var outQuadrature = new List(inReal.length);
  var a = 0.0962;
  var b = 0.5769;
  var detrenderOdd = new List(3);
  var detrenderEven = new List(3);
  var q1Odd = new List(3);
  var q1Even = new List(3);
  var jIOdd = new List(3);
  var jIEven = new List(3);
  var jQOdd = new List(3);
  var jQEven = new List(3);
  var rad2Deg = 180.0 / (4.0 * math.atan(1));
  var lookbackTotal = 32;
  var startIdx = lookbackTotal;
  var trailingWMAIdx = startIdx - lookbackTotal;
  var today = trailingWMAIdx;
  var tempReal = inReal.elementAt(today);
  today++;
  var periodWMASub = tempReal;
  var periodWMASum = tempReal;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 2.0;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 3.0;
  var trailingWMAValue = 0.0;
  var i = 9;
  var smoothedValue = 0.0;
  for (var ok = true; ok;) {
    tempReal = inReal.elementAt(today);
    today++;
    periodWMASub += tempReal;
    periodWMASub -= trailingWMAValue;
    periodWMASum += tempReal * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    i--;
    ok = i != 0;
  }
  var hilbertIdx = 0;
  var detrender = 0.0;
  var prevDetrenderOdd = 0.0;
  var prevDetrenderEven = 0.0;
  var prevDetrenderInputOdd = 0.0;
  var prevDetrenderInputEven = 0.0;
  var q1 = 0.0;
  var prevq1Odd = 0.0;
  var prevq1Even = 0.0;
  var prevq1InputOdd = 0.0;
  var prevq1InputEven = 0.0;
  var jI = 0.0;
  var prevJIOdd = 0.0;
  var prevJIEven = 0.0;
  var prevJIInputOdd = 0.0;
  var prevJIInputEven = 0.0;
  var jQ = 0.0;
  var prevJQOdd = 0.0;
  var prevJQEven = 0.0;
  var prevJQInputOdd = 0.0;
  var prevJQInputEven = 0.0;
  var period = 0.0;
  var outIdx = 32;
  var previ2 = 0.0;
  var prevq2 = 0.0;
  var Re = 0.0;
  var Im = 0.0;
  var i1ForOddPrev3 = 0.0;
  var i1ForEvenPrev3 = 0.0;
  var i1ForOddPrev2 = 0.0;
  var i1ForEvenPrev2 = 0.0;
  var i2 = 0.0;
  var q2 = 0.0;
  for (; today < inReal.length;) {
    var adjustedPrevPeriod = (0.075 * period) + 0.54;
    var todayValue = inReal.elementAt(today);
    periodWMASub += todayValue;
    periodWMASub -= trailingWMAValue;
    periodWMASum += todayValue * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    var hilbertTempReal = 0.0;
    if ((today % 2) == 0) {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderEven.elementAt(hilbertIdx);
      detrenderEven[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderEven;
      prevDetrenderEven = b * prevDetrenderInputEven;
      detrender += prevDetrenderEven;
      prevDetrenderInputEven = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Even.elementAt(hilbertIdx);
      q1Even[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Even;
      prevq1Even = b * prevq1InputEven;
      q1 += prevq1Even;
      prevq1InputEven = detrender;
      q1 *= adjustedPrevPeriod;
      if (today >= startIdx) {
        outQuadrature[outIdx] = q1;
        outInPhase[outIdx] = i1ForEvenPrev3;
        outIdx++;
      }

      hilbertTempReal = a * i1ForEvenPrev3;
      jI = -jIEven.elementAt(hilbertIdx);
      jIEven[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIEven;
      prevJIEven = b * prevJIInputEven;
      jI += prevJIEven;
      prevJIInputEven = i1ForEvenPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQEven.elementAt(hilbertIdx);
      jQEven[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQEven;
      prevJQEven = b * prevJQInputEven;
      jQ += prevJQEven;
      prevJQInputEven = q1;
      jQ *= adjustedPrevPeriod;
      hilbertIdx++;
      if (hilbertIdx == 3) {
        hilbertIdx = 0;
      }

      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForEvenPrev3 - jQ)) + (0.8 * previ2);
      i1ForOddPrev3 = i1ForOddPrev2;
      i1ForOddPrev2 = detrender;
    } else {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderOdd.elementAt(hilbertIdx);
      detrenderOdd[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderOdd;
      prevDetrenderOdd = b * prevDetrenderInputOdd;
      detrender += prevDetrenderOdd;
      prevDetrenderInputOdd = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Odd.elementAt(hilbertIdx);
      q1Odd[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Odd;
      prevq1Odd = b * prevq1InputOdd;
      q1 += prevq1Odd;
      prevq1InputOdd = detrender;
      q1 *= adjustedPrevPeriod;
      if (today >= startIdx) {
        outQuadrature[outIdx] = q1;
        outInPhase[outIdx] = i1ForOddPrev3;
        outIdx++;
      }

      hilbertTempReal = a * i1ForOddPrev3;
      jI = -jIOdd.elementAt(hilbertIdx);
      jIOdd[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIOdd;
      prevJIOdd = b * prevJIInputOdd;
      jI += prevJIOdd;
      prevJIInputOdd = i1ForOddPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQOdd.elementAt(hilbertIdx);
      jQOdd[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQOdd;
      prevJQOdd = b * prevJQInputOdd;
      jQ += prevJQOdd;
      prevJQInputOdd = q1;
      jQ *= adjustedPrevPeriod;
      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForOddPrev3 - jQ)) + (0.8 * previ2);
      i1ForEvenPrev3 = i1ForEvenPrev2;
      i1ForEvenPrev2 = detrender;
    }
    Re = (0.2 * ((i2 * previ2) + (q2 * prevq2))) + (0.8 * Re);
    Im = (0.2 * ((i2 * prevq2) - (q2 * previ2))) + (0.8 * Im);
    prevq2 = q2;
    previ2 = i2;
    tempReal = period;
    if ((Im != 0.0) && (Re != 0.0)) {
      period = 360.0 / (math.atan(Im / Re) * rad2Deg);
    }

    var tempReal2 = 1.5 * tempReal;
    if (period > tempReal2) {
      period = tempReal2;
    }

    tempReal2 = 0.67 * tempReal;
    if (period < tempReal2) {
      period = tempReal2;
    }

    if (period < 6) {
      period = 6;
    } else if (period > 50) {
      period = 50;
    }

    period = (0.2 * period) + (0.8 * tempReal);
    today++;
  }
  return [outInPhase, outQuadrature];
}

List HtSine(List inReal) {
  var outSine = new List(inReal.length);
  var outLeadSine = new List(inReal.length);
  var a = 0.0962;
  var b = 0.5769;
  var detrenderOdd = new List(3);
  var detrenderEven = new List(3);
  var q1Odd = new List(3);
  var q1Even = new List(3);
  var jIOdd = new List(3);
  var jIEven = new List(3);
  var jQOdd = new List(3);
  var jQEven = new List(3);
  var smoothPriceIdx = 0;
  var maxIdxSmoothPrice = (50 - 1);
  var smoothPrice = new List(maxIdxSmoothPrice + 1);
  var tempReal = math.atan(1);
  var rad2Deg = 45.0 / tempReal;
  var deg2Rad = 1.0 / rad2Deg;
  var constDeg2RadBy360 = tempReal * 8.0;
  var lookbackTotal = 63;
  var startIdx = lookbackTotal;
  var trailingWMAIdx = startIdx - lookbackTotal;
  var today = trailingWMAIdx;
  tempReal = inReal.elementAt(today);
  today++;
  var periodWMASub = tempReal;
  var periodWMASum = tempReal;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 2.0;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 3.0;
  var trailingWMAValue = 0.0;
  var i = 34;
  var smoothedValue = 0.0;
  for (var ok = true; ok;) {
    tempReal = inReal.elementAt(today);
    today++;
    periodWMASub += tempReal;
    periodWMASub -= trailingWMAValue;
    periodWMASum += tempReal * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    i--;
    ok = i != 0;
  }
  var hilbertIdx = 0;
  var detrender = 0.0;
  var prevDetrenderOdd = 0.0;
  var prevDetrenderEven = 0.0;
  var prevDetrenderInputOdd = 0.0;
  var prevDetrenderInputEven = 0.0;
  var q1 = 0.0;
  var prevq1Odd = 0.0;
  var prevq1Even = 0.0;
  var prevq1InputOdd = 0.0;
  var prevq1InputEven = 0.0;
  var jI = 0.0;
  var prevJIOdd = 0.0;
  var prevJIEven = 0.0;
  var prevJIInputOdd = 0.0;
  var prevJIInputEven = 0.0;
  var jQ = 0.0;
  var prevJQOdd = 0.0;
  var prevJQEven = 0.0;
  var prevJQInputOdd = 0.0;
  var prevJQInputEven = 0.0;
  var period = 0.0;
  var outIdx = 63;
  var previ2 = 0.0;
  var prevq2 = 0.0;
  var Re = 0.0;
  var Im = 0.0;
  var i1ForOddPrev3 = 0.0;
  var i1ForEvenPrev3 = 0.0;
  var i1ForOddPrev2 = 0.0;
  var i1ForEvenPrev2 = 0.0;
  var smoothPeriod = 0.0;
  var dcPhase = 0.0;
  var hilbertTempReal = 0.0;
  var q2 = 0.0;
  var i2 = 0.0;
  for (; today < inReal.length;) {
    var adjustedPrevPeriod = (0.075 * period) + 0.54;
    var todayValue = inReal.elementAt(today);
    periodWMASub += todayValue;
    periodWMASub -= trailingWMAValue;
    periodWMASum += todayValue * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    smoothPrice[smoothPriceIdx] = smoothedValue;
    if ((today % 2) == 0) {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderEven.elementAt(hilbertIdx);
      detrenderEven[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderEven;
      prevDetrenderEven = b * prevDetrenderInputEven;
      detrender += prevDetrenderEven;
      prevDetrenderInputEven = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Even.elementAt(hilbertIdx);
      q1Even[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Even;
      prevq1Even = b * prevq1InputEven;
      q1 += prevq1Even;
      prevq1InputEven = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForEvenPrev3;
      jI = -jIEven.elementAt(hilbertIdx);
      jIEven[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIEven;
      prevJIEven = b * prevJIInputEven;
      jI += prevJIEven;
      prevJIInputEven = i1ForEvenPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQEven.elementAt(hilbertIdx);
      jQEven[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQEven;
      prevJQEven = b * prevJQInputEven;
      jQ += prevJQEven;
      prevJQInputEven = q1;
      jQ *= adjustedPrevPeriod;
      hilbertIdx++;
      if (hilbertIdx == 3) {
        hilbertIdx = 0;
      }

      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForEvenPrev3 - jQ)) + (0.8 * previ2);
      i1ForOddPrev3 = i1ForOddPrev2;
      i1ForOddPrev2 = detrender;
    } else {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderOdd.elementAt(hilbertIdx);
      detrenderOdd[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderOdd;
      prevDetrenderOdd = b * prevDetrenderInputOdd;
      detrender += prevDetrenderOdd;
      prevDetrenderInputOdd = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Odd.elementAt(hilbertIdx);
      q1Odd[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Odd;
      prevq1Odd = b * prevq1InputOdd;
      q1 += prevq1Odd;
      prevq1InputOdd = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForOddPrev3;
      jI = -jIOdd.elementAt(hilbertIdx);
      jIOdd[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIOdd;
      prevJIOdd = b * prevJIInputOdd;
      jI += prevJIOdd;
      prevJIInputOdd = i1ForOddPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQOdd.elementAt(hilbertIdx);
      jQOdd[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQOdd;
      prevJQOdd = b * prevJQInputOdd;
      jQ += prevJQOdd;
      prevJQInputOdd = q1;
      jQ *= adjustedPrevPeriod;
      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForOddPrev3 - jQ)) + (0.8 * previ2);
      i1ForEvenPrev3 = i1ForEvenPrev2;
      i1ForEvenPrev2 = detrender;
    }
    Re = (0.2 * ((i2 * previ2) + (q2 * prevq2))) + (0.8 * Re);
    Im = (0.2 * ((i2 * prevq2) - (q2 * previ2))) + (0.8 * Im);
    prevq2 = q2;
    previ2 = i2;
    tempReal = period;
    if ((Im != 0.0) && (Re != 0.0)) {
      period = 360.0 / (math.atan(Im / Re) * rad2Deg);
    }

    var tempReal2 = 1.5 * tempReal;
    if (period > tempReal2) {
      period = tempReal2;
    }

    tempReal2 = 0.67 * tempReal;
    if (period < tempReal2) {
      period = tempReal2;
    }

    if (period < 6) {
      period = 6;
    } else if (period > 50) {
      period = 50;
    }

    period = (0.2 * period) + (0.8 * tempReal);
    smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod);
    var DCPeriod = smoothPeriod + 0.5;
    var DCPeriodInt = DCPeriod.floor();
    var realPart = 0.0;
    var imagPart = 0.0;
    var idx = smoothPriceIdx;
    for (var i = 0; i < DCPeriodInt; i++) {
      tempReal = (i * constDeg2RadBy360) / (DCPeriodInt * 1.0);
      tempReal2 = smoothPrice.elementAt(idx);
      realPart += math.sin(tempReal) * tempReal2;
      imagPart += math.cos(tempReal) * tempReal2;
      if (idx == 0) {
        idx = 50 - 1;
      } else {
        idx--;
      }
    }
    tempReal = imagPart.abs();
    if (tempReal > 0.0) {
      dcPhase = math.atan(realPart / imagPart) * rad2Deg;
    } else if (tempReal <= 0.01) {
      if (realPart < 0.0) {
        dcPhase -= 90.0;
      } else if (realPart > 0.0) {
        dcPhase += 90.0;
      }
    }

    dcPhase += 90.0;
    dcPhase += 360.0 / smoothPeriod;
    if (imagPart < 0.0) {
      dcPhase += 180.0;
    }

    if (dcPhase > 315.0) {
      dcPhase -= 360.0;
    }

    if (today >= startIdx) {
      outSine[outIdx] = math.sin(dcPhase * deg2Rad);
      outLeadSine[outIdx] = math.sin((dcPhase + 45) * deg2Rad);
      outIdx++;
    }

    smoothPriceIdx++;
    if (smoothPriceIdx > maxIdxSmoothPrice) {
      smoothPriceIdx = 0;
    }

    today++;
  }
  return [outSine, outLeadSine];
}

List HtTrendMode(List inReal) {
  var outReal = new List(inReal.length);
  var a = 0.0962;
  var b = 0.5769;
  var detrenderOdd = new List(3);
  var detrenderEven = new List(3);
  var q1Odd = new List(3);
  var q1Even = new List(3);
  var jIOdd = new List(3);
  var jIEven = new List(3);
  var jQOdd = new List(3);
  var jQEven = new List(3);
  var smoothPriceIdx = 0;
  var maxIdxSmoothPrice = (50 - 1);
  var smoothPrice = new List(maxIdxSmoothPrice + 1);
  var iTrend1 = 0.0;
  var iTrend2 = 0.0;
  var iTrend3 = 0.0;
  var daysInTrend = 0;
  var prevdcPhase = 0.0;
  var dcPhase = 0.0;
  var prevSine = 0.0;
  var sine = 0.0;
  var prevLeadSine = 0.0;
  var leadSine = 0.0;
  var tempReal = math.atan(1);
  var rad2Deg = 45.0 / tempReal;
  var deg2Rad = 1.0 / rad2Deg;
  var constDeg2RadBy360 = tempReal * 8.0;
  var lookbackTotal = 63;
  var startIdx = lookbackTotal;
  var trailingWMAIdx = startIdx - lookbackTotal;
  var today = trailingWMAIdx;
  tempReal = inReal.elementAt(today);
  today++;
  var periodWMASub = tempReal;
  var periodWMASum = tempReal;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 2.0;
  tempReal = inReal.elementAt(today);
  today++;
  periodWMASub += tempReal;
  periodWMASum += tempReal * 3.0;
  var trailingWMAValue = 0.0;
  var i = 34;
  for (var ok = true; ok;) {
    tempReal = inReal.elementAt(today);
    today++;
    periodWMASub += tempReal;
    periodWMASub -= trailingWMAValue;
    periodWMASum += tempReal * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    periodWMASum -= periodWMASub;
    i--;
    ok = i != 0;
  }
  var hilbertIdx = 0;
  var detrender = 0.0;
  var prevDetrenderOdd = 0.0;
  var prevDetrenderEven = 0.0;
  var prevDetrenderInputOdd = 0.0;
  var prevDetrenderInputEven = 0.0;
  var q1 = 0.0;
  var prevq1Odd = 0.0;
  var prevq1Even = 0.0;
  var prevq1InputOdd = 0.0;
  var prevq1InputEven = 0.0;
  var jI = 0.0;
  var prevJIOdd = 0.0;
  var prevJIEven = 0.0;
  var prevJIInputOdd = 0.0;
  var prevJIInputEven = 0.0;
  var jQ = 0.0;
  var prevJQOdd = 0.0;
  var prevJQEven = 0.0;
  var prevJQInputOdd = 0.0;
  var prevJQInputEven = 0.0;
  var period = 0.0;
  var outIdx = 63;
  var previ2 = 0.0;
  var prevq2 = 0.0;
  var Re = 0.0;
  var Im = 0.0;
  var i1ForOddPrev3 = 0.0;
  var i1ForEvenPrev3 = 0.0;
  var i1ForOddPrev2 = 0.0;
  var i1ForEvenPrev2 = 0.0;
  var smoothPeriod = 0.0;
  dcPhase = 0.0;
  var smoothedValue = 0.0;
  var hilbertTempReal = 0.0;
  var q2 = 0.0;
  var i2 = 0.0;
  for (; today < inReal.length;) {
    var adjustedPrevPeriod = (0.075 * period) + 0.54;
    var todayValue = inReal.elementAt(today);
    periodWMASub += todayValue;
    periodWMASub -= trailingWMAValue;
    periodWMASum += todayValue * 4.0;
    trailingWMAValue = inReal.elementAt(trailingWMAIdx);
    trailingWMAIdx++;
    smoothedValue = periodWMASum * 0.1;
    periodWMASum -= periodWMASub;
    smoothPrice[smoothPriceIdx] = smoothedValue;
    if ((today % 2) == 0) {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderEven.elementAt(hilbertIdx);
      detrenderEven[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderEven;
      prevDetrenderEven = b * prevDetrenderInputEven;
      detrender += prevDetrenderEven;
      prevDetrenderInputEven = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Even.elementAt(hilbertIdx);
      q1Even[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Even;
      prevq1Even = b * prevq1InputEven;
      q1 += prevq1Even;
      prevq1InputEven = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForEvenPrev3;
      jI = -jIEven.elementAt(hilbertIdx);
      jIEven[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIEven;
      prevJIEven = b * prevJIInputEven;
      jI += prevJIEven;
      prevJIInputEven = i1ForEvenPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQEven.elementAt(hilbertIdx);
      jQEven[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQEven;
      prevJQEven = b * prevJQInputEven;
      jQ += prevJQEven;
      prevJQInputEven = q1;
      jQ *= adjustedPrevPeriod;
      hilbertIdx++;
      if (hilbertIdx == 3) {
        hilbertIdx = 0;
      }

      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForEvenPrev3 - jQ)) + (0.8 * previ2);
      i1ForOddPrev3 = i1ForOddPrev2;
      i1ForOddPrev2 = detrender;
    } else {
      hilbertTempReal = a * smoothedValue;
      detrender = -detrenderOdd.elementAt(hilbertIdx);
      detrenderOdd[hilbertIdx] = hilbertTempReal;
      detrender += hilbertTempReal;
      detrender -= prevDetrenderOdd;
      prevDetrenderOdd = b * prevDetrenderInputOdd;
      detrender += prevDetrenderOdd;
      prevDetrenderInputOdd = smoothedValue;
      detrender *= adjustedPrevPeriod;
      hilbertTempReal = a * detrender;
      q1 = -q1Odd.elementAt(hilbertIdx);
      q1Odd[hilbertIdx] = hilbertTempReal;
      q1 += hilbertTempReal;
      q1 -= prevq1Odd;
      prevq1Odd = b * prevq1InputOdd;
      q1 += prevq1Odd;
      prevq1InputOdd = detrender;
      q1 *= adjustedPrevPeriod;
      hilbertTempReal = a * i1ForOddPrev3;
      jI = -jIOdd.elementAt(hilbertIdx);
      jIOdd[hilbertIdx] = hilbertTempReal;
      jI += hilbertTempReal;
      jI -= prevJIOdd;
      prevJIOdd = b * prevJIInputOdd;
      jI += prevJIOdd;
      prevJIInputOdd = i1ForOddPrev3;
      jI *= adjustedPrevPeriod;
      hilbertTempReal = a * q1;
      jQ = -jQOdd.elementAt(hilbertIdx);
      jQOdd[hilbertIdx] = hilbertTempReal;
      jQ += hilbertTempReal;
      jQ -= prevJQOdd;
      prevJQOdd = b * prevJQInputOdd;
      jQ += prevJQOdd;
      prevJQInputOdd = q1;
      jQ *= adjustedPrevPeriod;
      q2 = (0.2 * (q1 + jI)) + (0.8 * prevq2);
      i2 = (0.2 * (i1ForOddPrev3 - jQ)) + (0.8 * previ2);
      i1ForEvenPrev3 = i1ForEvenPrev2;
      i1ForEvenPrev2 = detrender;
    }
    Re = (0.2 * ((i2 * previ2) + (q2 * prevq2))) + (0.8 * Re);
    Im = (0.2 * ((i2 * prevq2) - (q2 * previ2))) + (0.8 * Im);
    prevq2 = q2;
    previ2 = i2;
    tempReal = period;
    if ((Im != 0.0) && (Re != 0.0)) {
      period = 360.0 / (math.atan(Im / Re) * rad2Deg);
    }

    var tempReal2 = 1.5 * tempReal;
    if (period > tempReal2) {
      period = tempReal2;
    }

    tempReal2 = 0.67 * tempReal;
    if (period < tempReal2) {
      period = tempReal2;
    }

    if (period < 6) {
      period = 6;
    } else if (period > 50) {
      period = 50;
    }

    period = (0.2 * period) + (0.8 * tempReal);
    smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod);
    prevdcPhase = dcPhase;
    var DCPeriod = smoothPeriod + 0.5;
    var DCPeriodInt = DCPeriod.floor();
    var realPart = 0.0;
    var imagPart = 0.0;
    var idx = smoothPriceIdx;
    for (var i = 0; i < DCPeriodInt; i++) {
      tempReal = (i * constDeg2RadBy360) / (DCPeriodInt * 1.0);
      tempReal2 = smoothPrice.elementAt(idx);
      realPart += math.sin(tempReal) * tempReal2;
      imagPart += math.cos(tempReal) * tempReal2;
      if (idx == 0) {
        idx = 50 - 1;
      } else {
        idx--;
      }
    }
    tempReal = imagPart.abs();
    if (tempReal > 0.0) {
      dcPhase = math.atan(realPart / imagPart) * rad2Deg;
    } else if (tempReal <= 0.01) {
      if (realPart < 0.0) {
        dcPhase -= 90.0;
      } else if (realPart > 0.0) {
        dcPhase += 90.0;
      }
    }

    dcPhase += 90.0;
    dcPhase += 360.0 / smoothPeriod;
    if (imagPart < 0.0) {
      dcPhase += 180.0;
    }

    if (dcPhase > 315.0) {
      dcPhase -= 360.0;
    }

    prevSine = sine;
    prevLeadSine = leadSine;
    sine = math.sin(dcPhase * deg2Rad);
    leadSine = math.sin((dcPhase + 45) * deg2Rad);
    DCPeriod = smoothPeriod + 0.5;
    DCPeriodInt = DCPeriod.floor();
    idx = today;
    tempReal = 0.0;
    for (var i = 0; i < DCPeriodInt; i++) {
      tempReal += inReal.elementAt(idx);
      idx--;
    }
    if (DCPeriodInt > 0) {
      tempReal = tempReal / (DCPeriodInt * 1.0);
    }

    var trendline =
        (4.0 * tempReal + 3.0 * iTrend1 + 2.0 * iTrend2 + iTrend3) / 10.0;
    iTrend3 = iTrend2;
    iTrend2 = iTrend1;
    iTrend1 = tempReal;
    var trend = 1;
    if (((sine > leadSine) && (prevSine <= prevLeadSine)) ||
        ((sine < leadSine) && (prevSine >= prevLeadSine))) {
      daysInTrend = 0;
      trend = 0;
    }

    daysInTrend++;
    if (daysInTrend < (0.5 * smoothPeriod)) {
      trend = 0;
    }

    tempReal = dcPhase - prevdcPhase;
    if ((smoothPeriod != 0.0) &&
        ((tempReal > (0.67 * 360.0 / smoothPeriod)) &&
            (tempReal < (1.5 * 360.0 / smoothPeriod)))) {
      trend = 0;
    }

    tempReal = smoothPrice.elementAt(smoothPriceIdx);
    if ((trendline != 0.0) &&
        (((tempReal - trendline) / trendline).abs() >= 0.015)) {
      trend = 1;
    }

    if (today >= startIdx) {
      outReal[outIdx] = trend;
      outIdx++;
    }

    smoothPriceIdx++;
    if (smoothPriceIdx > maxIdxSmoothPrice) {
      smoothPriceIdx = 0;
    }

    today++;
  }
  return outReal;
}

List Beta(List inReal0, List inReal1, int inTimePeriod) {
  var outReal = new List(inReal0.length);
  var x = 0.0;
  var y = 0.0;
  var sSS = 0.0;
  var sXY = 0.0;
  var sX = 0.0;
  var sY = 0.0;
  var tmpReal = 0.0;
  var n = 0.0;
  var nbInitialElementNeeded = inTimePeriod;
  var startIdx = nbInitialElementNeeded;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var trailingLastPriceX = inReal0.elementAt(trailingIdx);
  var lastPriceX = trailingLastPriceX;
  var trailingLastPriceY = inReal1.elementAt(trailingIdx);
  var lastPriceY = trailingLastPriceY;
  trailingIdx++;
  var i = trailingIdx;
  for (; i < startIdx;) {
    var tmpReal = inReal0.elementAt(i);
    var x = 0.0;
    if (!((-0.00000000000001 < lastPriceX) &&
        (lastPriceX < 0.00000000000001))) {
      x = (tmpReal - lastPriceX) / lastPriceX;
    }

    lastPriceX = tmpReal;
    tmpReal = inReal1.elementAt(i);
    i++;
    var y = 0.0;
    if (!((-0.00000000000001 < lastPriceY) &&
        (lastPriceY < 0.00000000000001))) {
      y = (tmpReal - lastPriceY) / lastPriceY;
    }

    lastPriceY = tmpReal;
    sSS += x * x;
    sXY += x * y;
    sX += x;
    sY += y;
  }
  var outIdx = inTimePeriod;
  n = inTimePeriod.toDouble();
  for (var ok = true; ok;) {
    tmpReal = inReal0.elementAt(i);
    if (!((-0.00000000000001 < lastPriceX) &&
        (lastPriceX < 0.00000000000001))) {
      x = (tmpReal - lastPriceX) / lastPriceX;
    } else {
      x = 0.0;
    }
    lastPriceX = tmpReal;
    tmpReal = inReal1.elementAt(i);
    i++;
    if (!((-0.00000000000001 < lastPriceY) &&
        (lastPriceY < 0.00000000000001))) {
      y = (tmpReal - lastPriceY) / lastPriceY;
    } else {
      y = 0.0;
    }
    lastPriceY = tmpReal;
    sSS += x * x;
    sXY += x * y;
    sX += x;
    sY += y;
    tmpReal = inReal0.elementAt(trailingIdx);
    if (!(((-(0.00000000000001)) < trailingLastPriceX) &&
        (trailingLastPriceX < (0.00000000000001)))) {
      x = (tmpReal - trailingLastPriceX) / trailingLastPriceX;
    } else {
      x = 0.0;
    }
    trailingLastPriceX = tmpReal;
    tmpReal = inReal1.elementAt(trailingIdx);
    trailingIdx++;
    if (!(((-(0.00000000000001)) < trailingLastPriceY) &&
        (trailingLastPriceY < (0.00000000000001)))) {
      y = (tmpReal - trailingLastPriceY) / trailingLastPriceY;
    } else {
      y = 0.0;
    }
    trailingLastPriceY = tmpReal;
    tmpReal = (n * sSS) - (sX * sX);
    if (!(((-(0.00000000000001)) < tmpReal) &&
        (tmpReal < (0.00000000000001)))) {
      outReal[outIdx] = ((n * sXY) - (sX * sY)) / tmpReal;
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
    sSS -= x * x;
    sXY -= x * y;
    sX -= x;
    sY -= y;
    ok = i < inReal0.length;
  }
  return outReal;
}

List Correl(List inReal0, List inReal1, int inTimePeriod) {
  var outReal = new List(inReal0.length);
  var inTimePeriodF = inTimePeriod;
  var lookbackTotal = inTimePeriod - 1;
  var startIdx = lookbackTotal;
  var trailingIdx = startIdx - lookbackTotal;
  var sumXY = 0.0;
  var sumX = 0.0;
  var sumY = 0.0;
  var sumX2 = 0.0;
  var sumY2 = 0.0;
  var today = trailingIdx;
  for (today = trailingIdx; today <= startIdx; today++) {
    var x = inReal0.elementAt(today);
    sumX += x;
    sumX2 += x * x;
    var y = inReal1.elementAt(today);
    sumXY += x * y;
    sumY += y;
    sumY2 += y * y;
  }
  var trailingX = inReal0.elementAt(trailingIdx);
  var trailingY = inReal1.elementAt(trailingIdx);
  trailingIdx++;
  var tempReal = (sumX2 - ((sumX * sumX) / inTimePeriodF)) *
      (sumY2 - ((sumY * sumY) / inTimePeriodF));
  if (!(tempReal < 0.00000000000001)) {
    outReal[inTimePeriod - 1] =
        (sumXY - ((sumX * sumY) / inTimePeriodF)) / math.sqrt(tempReal);
  } else {
    outReal[inTimePeriod - 1] = 0.0;
  }
  var outIdx = inTimePeriod;
  for (; today < inReal0.length;) {
    sumX -= trailingX;
    sumX2 -= trailingX * trailingX;
    sumXY -= trailingX * trailingY;
    sumY -= trailingY;
    sumY2 -= trailingY * trailingY;
    var x = inReal0.elementAt(today);
    sumX += x;
    sumX2 += x * x;
    var y = inReal1.elementAt(today);
    today++;
    sumXY += x * y;
    sumY += y;
    sumY2 += y * y;
    trailingX = inReal0.elementAt(trailingIdx);
    trailingY = inReal1.elementAt(trailingIdx);
    trailingIdx++;
    tempReal = (sumX2 - ((sumX * sumX) / inTimePeriodF)) *
        (sumY2 - ((sumY * sumY) / inTimePeriodF));
    if (!(tempReal < (0.00000000000001))) {
      outReal[outIdx] =
          (sumXY - ((sumX * sumY) / inTimePeriodF)) / math.sqrt(tempReal);
    } else {
      outReal[outIdx] = 0.0;
    }
    outIdx++;
  }
  return outReal;
}

List LinearReg(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var inTimePeriodF = inTimePeriod;
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var outIdx = startIdx - 1;
  var today = startIdx - 1;
  var sumX = inTimePeriodF * (inTimePeriodF - 1) * 0.5;
  var sumXSqr =
      inTimePeriodF * (inTimePeriodF - 1) * (2 * inTimePeriodF - 1) / 6;
  var divisor = sumX * sumX - inTimePeriodF * sumXSqr;
  var sumXY = 0.0;
  var sumY = 0.0;
  var i = inTimePeriod;
  for (; i != 0;) {
    i--;
    var tempValue1 = inReal.elementAt(today - i);
    sumY += tempValue1;
    sumXY += i * tempValue1;
  }
  for (; today < inReal.length;) {
    if (today > startIdx - 1) {
      var tempValue2 = inReal.elementAt(today - inTimePeriod);
      sumXY += sumY - inTimePeriodF * tempValue2;
      sumY += inReal.elementAt(today) - tempValue2;
    }

    var m = (inTimePeriodF * sumXY - sumX * sumY) / divisor;
    var b = (sumY - m * sumX) / inTimePeriodF;
    outReal[outIdx] = b + m * (inTimePeriodF - 1);
    outIdx++;
    today++;
  }
  return outReal;
}

List LinearRegAngle(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var inTimePeriodF = inTimePeriod;
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var outIdx = startIdx - 1;
  var today = startIdx - 1;
  var sumX = inTimePeriodF * (inTimePeriodF - 1) * 0.5;
  var sumXSqr =
      inTimePeriodF * (inTimePeriodF - 1) * (2 * inTimePeriodF - 1) / 6;
  var divisor = sumX * sumX - inTimePeriodF * sumXSqr;
  var sumXY = 0.0;
  var sumY = 0.0;
  var i = inTimePeriod;
  for (; i != 0;) {
    i--;
    var tempValue1 = inReal.elementAt(today - i);
    sumY += tempValue1;
    sumXY += i * tempValue1;
  }
  for (; today < inReal.length;) {
    if (today > startIdx - 1) {
      var tempValue2 = inReal.elementAt(today - inTimePeriod);
      sumXY += sumY - inTimePeriodF * tempValue2;
      sumY += inReal.elementAt(today) - tempValue2;
    }

    var m = (inTimePeriodF * sumXY - sumX * sumY) / divisor;
    outReal[outIdx] = math.atan(m) * (180.0 / math.pi);
    outIdx++;
    today++;
  }
  return outReal;
}

List LinearRegIntercept(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var inTimePeriodF = inTimePeriod;
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var outIdx = startIdx - 1;
  var today = startIdx - 1;
  var sumX = inTimePeriodF * (inTimePeriodF - 1) * 0.5;
  var sumXSqr =
      inTimePeriodF * (inTimePeriodF - 1) * (2 * inTimePeriodF - 1) / 6;
  var divisor = sumX * sumX - inTimePeriodF * sumXSqr;
  var sumXY = 0.0;
  var sumY = 0.0;
  var i = inTimePeriod;
  for (; i != 0;) {
    i--;
    var tempValue1 = inReal.elementAt(today - i);
    sumY += tempValue1;
    sumXY += i * tempValue1;
  }
  for (; today < inReal.length;) {
    if (today > startIdx - 1) {
      var tempValue2 = inReal.elementAt(today - inTimePeriod);
      sumXY += sumY - inTimePeriodF * tempValue2;
      sumY += inReal.elementAt(today) - tempValue2;
    }

    var m = (inTimePeriodF * sumXY - sumX * sumY) / divisor;
    outReal[outIdx] = (sumY - m * sumX) / inTimePeriodF;
    outIdx++;
    today++;
  }
  return outReal;
}

List LinearRegSlope(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var inTimePeriodF = inTimePeriod;
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var outIdx = startIdx - 1;
  var today = startIdx - 1;
  var sumX = inTimePeriodF * (inTimePeriodF - 1) * 0.5;
  var sumXSqr =
      inTimePeriodF * (inTimePeriodF - 1) * (2 * inTimePeriodF - 1) / 6;
  var divisor = sumX * sumX - inTimePeriodF * sumXSqr;
  var sumXY = 0.0;
  var sumY = 0.0;
  var i = inTimePeriod;
  for (; i != 0;) {
    i--;
    var tempValue1 = inReal.elementAt(today - i);
    sumY += tempValue1;
    sumXY += i * tempValue1;
  }
  for (; today < inReal.length;) {
    if (today > startIdx - 1) {
      var tempValue2 = inReal.elementAt(today - inTimePeriod);
      sumXY += sumY - inTimePeriodF * tempValue2;
      sumY += inReal.elementAt(today) - tempValue2;
    }

    outReal[outIdx] = (inTimePeriodF * sumXY - sumX * sumY) / divisor;
    outIdx++;
    today++;
  }
  return outReal;
}

List StdDev(List inReal, int inTimePeriod, double inNbDev) {
  var outReal = Var(inReal, inTimePeriod);
  if (inNbDev != 1.0) {
    for (var i = 0; i < inReal.length; i++) {
      var tempReal = outReal.elementAt(i);
      if (!(tempReal < 0.00000000000001)) {
        outReal[i] = math.sqrt(tempReal) * inNbDev;
      } else {
        outReal[i] = 0.0;
      }
    }
  } else {
    for (var i = 0; i < inReal.length; i++) {
      var tempReal = outReal.elementAt(i);
      if (!(tempReal < 0.00000000000001)) {
        outReal[i] = math.sqrt(tempReal);
      } else {
        outReal[i] = 0.0;
      }
    }
  }
  return outReal;
}

List Tsf(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var inTimePeriodF = inTimePeriod;
  var lookbackTotal = inTimePeriod;
  var startIdx = lookbackTotal;
  var outIdx = startIdx - 1;
  var today = startIdx - 1;
  var sumX = inTimePeriodF * (inTimePeriodF - 1.0) * 0.5;
  var sumXSqr =
      inTimePeriodF * (inTimePeriodF - 1) * (2 * inTimePeriodF - 1) / 6;
  var divisor = sumX * sumX - inTimePeriodF * sumXSqr;
  var sumXY = 0.0;
  var sumY = 0.0;
  var i = inTimePeriod;
  for (; i != 0;) {
    i--;
    var tempValue1 = inReal.elementAt(today - i);
    sumY += tempValue1;
    sumXY += i * tempValue1;
  }
  for (; today < inReal.length;) {
    if (today > startIdx - 1) {
      var tempValue2 = inReal.elementAt(today - inTimePeriod);
      sumXY += sumY - inTimePeriodF * tempValue2;
      sumY += inReal.elementAt(today) - tempValue2;
    }

    var m = (inTimePeriodF * sumXY - sumX * sumY) / divisor;
    var b = (sumY - m * sumX) / inTimePeriodF;
    outReal[outIdx] = b + m * inTimePeriodF;
    today++;
    outIdx++;
  }
  return outReal;
}

List Var(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var nbInitialElementNeeded = inTimePeriod - 1;
  var startIdx = nbInitialElementNeeded;
  var periodTotal1 = 0.0;
  var periodTotal2 = 0.0;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var i = trailingIdx;
  if (inTimePeriod > 1) {
    for (; i < startIdx;) {
      var tempReal = inReal.elementAt(i);
      periodTotal1 += tempReal;
      tempReal *= tempReal;
      periodTotal2 += tempReal;
      i++;
    }
  }

  var outIdx = startIdx;
  for (var ok = true; ok;) {
    var tempReal = inReal.elementAt(i);
    periodTotal1 += tempReal;
    tempReal *= tempReal;
    periodTotal2 += tempReal;
    var meanValue1 = periodTotal1 / inTimePeriod;
    var meanValue2 = periodTotal2 / inTimePeriod;
    tempReal = inReal.elementAt(trailingIdx);
    periodTotal1 -= tempReal;
    tempReal *= tempReal;
    periodTotal2 -= tempReal;
    outReal[outIdx] = meanValue2 - meanValue1 * meanValue1;
    i++;
    trailingIdx++;
    outIdx++;
    ok = i < inReal.length;
  }
  return outReal;
}

List Acos(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.acos(inReal.elementAt(i));
  }
  return outReal;
}

List Asin(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.asin(inReal.elementAt(i));
  }
  return outReal;
}

List Atan(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.atan(inReal.elementAt(i));
  }
  return outReal;
}

List Ceil(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = inReal.elementAt(i).ceil();
  }
  return outReal;
}

List Cos(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.cos(inReal.elementAt(i));
  }
  return outReal;
}

// List Cosh(List inReal) {
//   var outReal = new List(inReal.length);
//   for (var i = 0; i < inReal.length; i++) {
//     outReal[i] = math.Cosh(inReal.elementAt(i));
//   }
//   return outReal;
// }

List Exp(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.exp(inReal.elementAt(i));
  }
  return outReal;
}

List Floor(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = inReal.elementAt(i).floor();
  }
  return outReal;
}

List Ln(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.log(inReal.elementAt(i));
  }
  return outReal;
}

List Log10(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.log(inReal.elementAt(i));
  }
  return outReal;
}

List Sin(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.sin(inReal.elementAt(i));
  }
  return outReal;
}

// List Sinh(List inReal) {
//   var outReal = new List(inReal.length);
//   for (var i = 0; i < inReal.length; i++) {
//     outReal[i] = math.sinh(inReal.elementAt(i));
//   }
//   return outReal;
// }

List Sqrt(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.sqrt(inReal.elementAt(i));
  }
  return outReal;
}

List Tan(List inReal) {
  var outReal = new List(inReal.length);
  for (var i = 0; i < inReal.length; i++) {
    outReal[i] = math.tan(inReal.elementAt(i));
  }
  return outReal;
}

// List Tanh(List inReal) {
//   var outReal = new List(inReal.length);
//   for (var i = 0; i < inReal.length; i++) {
//     outReal[i] = math.Tanh(inReal.elementAt(i));
//   }
//   return outReal;
// }

List Add(List inReal0, List inReal1) {
  var outReal = new List(inReal0.length);
  for (var i = 0; i < inReal0.length; i++) {
    outReal[i] = inReal0.elementAt(i) + inReal1.elementAt(i);
  }
  return outReal;
}

List Div(List inReal0, List inReal1) {
  var outReal = new List(inReal0.length);
  for (var i = 0; i < inReal0.length; i++) {
    outReal[i] = inReal0.elementAt(i) / inReal1.elementAt(i);
  }
  return outReal;
}

List Max(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  if (inTimePeriod < 2) {
    return outReal;
  }

  var nbInitialElementNeeded = inTimePeriod - 1;
  var startIdx = nbInitialElementNeeded;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var highestIdx = -1;
  var highest = 0.0;
  for (; today < outReal.length;) {
    var tmp = inReal.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inReal.elementAt(highestIdx);
      var i = highestIdx + 1;
      for (; i <= today;) {
        tmp = inReal.elementAt(i);
        if (tmp > highest) {
          highestIdx = i;
          highest = tmp;
        }

        i++;
      }
    } else if (tmp >= highest) {
      highestIdx = today;
      highest = tmp;
    }

    outReal[outIdx] = highest;
    outIdx++;
    trailingIdx++;
    today++;
  }
  return outReal;
}

List MaxIndex(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  if (inTimePeriod < 2) {
    return outReal;
  }

  var nbInitialElementNeeded = inTimePeriod - 1;
  var startIdx = nbInitialElementNeeded;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var highestIdx = -1;
  var highest = 0.0;
  for (; today < inReal.length;) {
    var tmp = inReal.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inReal.elementAt(highestIdx);
      var i = highestIdx + 1;
      for (; i <= today;) {
        var tmp = inReal.elementAt(i);
        if (tmp > highest) {
          highestIdx = i;
          highest = tmp;
        }

        i++;
      }
    } else if (tmp >= highest) {
      highestIdx = today;
      highest = tmp;
    }

    outReal[outIdx] = highestIdx;
    outIdx++;
    trailingIdx++;
    today++;
  }
  return outReal;
}

List Min(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  if (inTimePeriod < 2) {
    return outReal;
  }

  var nbInitialElementNeeded = inTimePeriod - 1;
  var startIdx = nbInitialElementNeeded;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var lowestIdx = -1;
  var lowest = 0.0;
  for (; today < outReal.length;) {
    var tmp = inReal.elementAt(today);
    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inReal.elementAt(lowestIdx);
      var i = lowestIdx + 1;
      for (; i <= today;) {
        tmp = inReal.elementAt(i);
        if (tmp < lowest) {
          lowestIdx = i;
          lowest = tmp;
        }

        i++;
      }
    } else if (tmp <= lowest) {
      lowestIdx = today;
      lowest = tmp;
    }

    outReal[outIdx] = lowest;
    outIdx++;
    trailingIdx++;
    today++;
  }
  return outReal;
}

List MinIndex(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  if (inTimePeriod < 2) {
    return outReal;
  }

  var nbInitialElementNeeded = inTimePeriod - 1;
  var startIdx = nbInitialElementNeeded;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var lowestIdx = -1;
  var lowest = 0.0;
  for (; today < inReal.length;) {
    var tmp = inReal.elementAt(today);
    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inReal.elementAt(lowestIdx);
      var i = lowestIdx + 1;
      for (; i <= today;) {
        tmp = inReal.elementAt(i);
        if (tmp < lowest) {
          lowestIdx = i;
          lowest = tmp;
        }

        i++;
      }
    } else if (tmp <= lowest) {
      lowestIdx = today;
      lowest = tmp;
    }

    outReal[outIdx] = lowestIdx;
    outIdx++;
    trailingIdx++;
    today++;
  }
  return outReal;
}

List MinMax(List inReal, int inTimePeriod) {
  var outMin = new List(inReal.length);
  var outMax = new List(inReal.length);
  var nbInitialElementNeeded = (inTimePeriod - 1);
  var startIdx = nbInitialElementNeeded;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var highestIdx = -1;
  var highest = 0.0;
  var lowestIdx = -1;
  var lowest = 0.0;
  for (; today < inReal.length;) {
    var tmpLow = inReal.elementAt(today);
    var tmpHigh = inReal.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inReal.elementAt(highestIdx);
      var i = highestIdx;
      i++;
      for (; i <= today;) {
        tmpHigh = inReal.elementAt(i);
        if (tmpHigh > highest) {
          highestIdx = i;
          highest = tmpHigh;
        }

        i++;
      }
    } else if (tmpHigh >= highest) {
      highestIdx = today;
      highest = tmpHigh;
    }

    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inReal.elementAt(lowestIdx);
      var i = lowestIdx;
      i++;
      for (; i <= today;) {
        tmpLow = inReal.elementAt(i);
        if (tmpLow < lowest) {
          lowestIdx = i;
          lowest = tmpLow;
        }

        i++;
      }
    } else if (tmpLow <= lowest) {
      lowestIdx = today;
      lowest = tmpLow;
    }

    outMax[outIdx] = highest;
    outMin[outIdx] = lowest;
    outIdx++;
    trailingIdx++;
    today++;
  }
  return [outMin, outMax];
}

List MinMaxIndex(List inReal, int inTimePeriod) {
  var outMinIdx = new List(inReal.length);
  var outMaxIdx = new List(inReal.length);
  var nbInitialElementNeeded = (inTimePeriod - 1);
  var startIdx = nbInitialElementNeeded;
  var outIdx = startIdx;
  var today = startIdx;
  var trailingIdx = startIdx - nbInitialElementNeeded;
  var highestIdx = -1;
  var highest = 0.0;
  var lowestIdx = -1;
  var lowest = 0.0;
  for (; today < inReal.length;) {
    var tmpLow = inReal.elementAt(today);
    var tmpHigh = inReal.elementAt(today);
    if (highestIdx < trailingIdx) {
      highestIdx = trailingIdx;
      highest = inReal.elementAt(highestIdx);
      var i = highestIdx;
      i++;
      for (; i <= today;) {
        tmpHigh = inReal.elementAt(i);
        if (tmpHigh > highest) {
          highestIdx = i;
          highest = tmpHigh;
        }

        i++;
      }
    } else if (tmpHigh >= highest) {
      highestIdx = today;
      highest = tmpHigh;
    }

    if (lowestIdx < trailingIdx) {
      lowestIdx = trailingIdx;
      lowest = inReal.elementAt(lowestIdx);
      var i = lowestIdx;
      i++;
      for (; i <= today;) {
        tmpLow = inReal.elementAt(i);
        if (tmpLow < lowest) {
          lowestIdx = i;
          lowest = tmpLow;
        }

        i++;
      }
    } else if (tmpLow <= lowest) {
      lowestIdx = today;
      lowest = tmpLow;
    }

    outMaxIdx[outIdx] = highestIdx;
    outMinIdx[outIdx] = lowestIdx;
    outIdx++;
    trailingIdx++;
    today++;
  }
  return [outMinIdx, outMaxIdx];
}

List Mult(List inReal0, List inReal1) {
  var outReal = new List(inReal0.length);
  for (var i = 0; i < inReal0.length; i++) {
    outReal[i] = inReal0.elementAt(i) * inReal1.elementAt(i);
  }
  return outReal;
}

List Sub(List inReal0, List inReal1) {
  var outReal = new List(inReal0.length);
  for (var i = 0; i < inReal0.length; i++) {
    outReal[i] = inReal0.elementAt(i) - inReal1.elementAt(i);
  }
  return outReal;
}

List Sum(List inReal, int inTimePeriod) {
  var outReal = new List(inReal.length);
  var lookbackTotal = inTimePeriod - 1;
  var startIdx = lookbackTotal;
  var periodTotal = 0.0;
  var trailingIdx = startIdx - lookbackTotal;
  var i = trailingIdx;
  if (inTimePeriod > 1) {
    for (; i < startIdx;) {
      periodTotal += inReal.elementAt(i);
      i++;
    }
  }

  var outIdx = startIdx;
  for (; i < inReal.length;) {
    periodTotal += inReal.elementAt(i);
    var tempReal = periodTotal;
    periodTotal -= inReal.elementAt(trailingIdx);
    outReal[outIdx] = tempReal;
    i++;
    trailingIdx++;
    outIdx++;
  }
  return outReal;
}

List HeikinashiCandles(List<double> highs, List<double> opens,
    List<double> closes, List<double> lows) {
  var N = highs.length;
  var heikinHighs = new List(N);
  var heikinOpens = new List(N);
  var heikinCloses = new List(N);
  var heikinLows = new List(N);
  for (var currentCandle = 1; currentCandle < N; currentCandle++) {
    var previousCandle = currentCandle - 1;
    heikinHighs[currentCandle] = math.max(
        highs.elementAt(currentCandle),
        math.max(
            opens.elementAt(currentCandle), closes.elementAt(currentCandle)));
    heikinOpens[currentCandle] =
        (opens.elementAt(previousCandle) + closes.elementAt(previousCandle)) /
            2;
    heikinCloses[currentCandle] = (highs.elementAt(currentCandle) +
            opens.elementAt(currentCandle) +
            closes.elementAt(currentCandle) +
            lows.elementAt(currentCandle)) /
        4;
    heikinLows[currentCandle] = math.min(
        highs.elementAt(currentCandle),
        math.min(
            opens.elementAt(currentCandle), closes.elementAt(currentCandle)));
  }
  return [heikinHighs, heikinOpens, heikinCloses, heikinLows];
}

List Hlc3(List highs, List lows, List closes) {
  var N = highs.length;
  var result = new List(N);

  for (var i in result) {
    result[i] =
        (highs.elementAt(i) + lows.elementAt(i) + closes.elementAt(i)) / 3;
  }
  return result;
}

bool Crossover(List series1, List series2) {
  if (series1.length < 3 || series2.length < 3) {
    return false;
  }

  var N = series1.length;
  return series1.elementAt(N - 2) <= series2.elementAt(N - 2) &&
      series1.elementAt(N - 1) > series2.elementAt(N - 1);
}

bool Crossunder(List series1, List series2) {
  if (series1.length < 3 || series2.length < 3) {
    return false;
  }

  var N = series1.length;
  return series1.elementAt(N - 1) <= series2.elementAt(N - 1) &&
      series1.elementAt(N - 2) > series2.elementAt(N - 2);
}

List GroupCandles(
    List highs, List opens, List closes, List lows, int groupingFactor) {
  var N = highs.length;
  if (groupingFactor == 0) {
    return [null, null, null, null, null];
  } else if (groupingFactor == 1) {
    return [highs, opens, closes, lows, null];
  }

  if (N % groupingFactor > 0) {
    return [null, null, null, null, null];
  }

  var groupedN = N / groupingFactor;
  var groupedHighs = new List(groupedN.round());
  var groupedOpens = new List(groupedN.round());
  var groupedCloses = new List(groupedN.round());
  var groupedLows = new List(groupedN.round());
  var lastOfCurrentGroup = groupingFactor - 1;
  var k = 0;
  for (var i = 0; i < N; i += groupingFactor) {
    groupedOpens[k] = opens.elementAt(i);
    groupedCloses[k] = closes.elementAt(i + lastOfCurrentGroup);
    groupedHighs[k] = highs.elementAt(i);
    groupedLows[k] = lows.elementAt(i);
    var endOfCurrentGroup = i + lastOfCurrentGroup;
    for (var j = i + 1; j <= endOfCurrentGroup; j++) {
      if (lows.elementAt(j) < groupedLows.elementAt(k)) {
        groupedLows[k] = lows.elementAt(j);
      }

      if (highs.elementAt(j) > groupedHighs.elementAt(k)) {
        groupedHighs[k] = highs.elementAt(j);
      }
    }
    k++;
  }
  return [groupedHighs, groupedOpens, groupedCloses, groupedLows, null];
}
