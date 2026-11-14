package com.example;

import java.util.Arrays;

public final class OrderStatsImpl extends OrderStats {

    public OrderStatsImpl() {
        super();
    }

    @Override
    public Integer medianOfMedians(int[] xs) {
        if (xs == null || xs.length == 0) {
            return null;
        }
        int groupCount = (xs.length + 4) / 5;
        int[] medians = new int[groupCount];
        int idx = 0;
        for (int start = 0; start < xs.length; start += 5) {
            int end = Math.min(start + 5, xs.length);
            int[] group = Arrays.copyOfRange(xs, start, end);
            Arrays.sort(group);
            medians[idx++] = group[(group.length - 1) / 2];
        }
        Arrays.sort(medians);
        return medians[(medians.length - 1) / 2];
    }

    @Override
    public SelectResult selectKth(int[] xs, int k) {
        if (xs == null || k < 0 || k >= xs.length) {
            return null;
        }
        int[] cur = xs.clone();
        int[] pivotBuffer = new int[64];
        int pivotCount = 0;

        while (true) {
            if (cur.length <= 5) {
                int[] sorted = cur.clone();
                Arrays.sort(sorted);
                return new SelectResult(sorted[k], Arrays.copyOf(pivotBuffer, pivotCount));
            }

            int p = medianOfMedians(cur);
            if (pivotCount == pivotBuffer.length) {
                pivotBuffer = Arrays.copyOf(pivotBuffer, pivotCount * 2);
            }
            pivotBuffer[pivotCount++] = p;

            int lessCount = 0;
            int equalCount = 0;
            for (int v : cur) {
                if (v < p) {
                    lessCount++;
                } else if (v == p) {
                    equalCount++;
                }
            }
            int greaterCount = cur.length - lessCount - equalCount;

            int[] less = new int[lessCount];
            int[] greater = new int[greaterCount];
            int li = 0;
            int gi = 0;
            for (int v : cur) {
                if (v < p) {
                    less[li++] = v;
                } else if (v > p) {
                    greater[gi++] = v;
                }
            }

            if (k < lessCount) {
                cur = less;
            } else if (k < lessCount + equalCount) {
                return new SelectResult(p, Arrays.copyOf(pivotBuffer, pivotCount));
            } else {
                k = k - lessCount - equalCount;
                cur = greater;
            }
        }
    }

    @Override
    public Double medianTwoSorted(SortedSource a, SortedSource b) {
        long lenA = a.length();
        long lenB = b.length();
        long total = lenA + lenB;
        if (total == 0) {
            return null;
        }

        SortedSource src1 = a;
        SortedSource src2 = b;
        long m = lenA;
        long n = lenB;
        if (m > n) {
            src1 = b;
            src2 = a;
            m = lenB;
            n = lenA;
        }

        long half = (total + 1) / 2;
        long lo = Math.max(0L, half - n);
        long hi = Math.min(m, half);

        // Find smallest i in [lo, hi] such that src1[i] >= src2[j-1] where j = half - i.
        while (lo < hi) {
            long mid = (lo + hi) >>> 1;
            long j = half - mid;
            boolean ok;
            if (mid >= m) {
                ok = true;
            } else if (j <= 0) {
                ok = true;
            } else {
                int aRight = src1.get((int) mid);
                int bLeft = src2.get((int) (j - 1));
                ok = aRight >= bLeft;
            }
            if (ok) {
                hi = mid;
            } else {
                lo = mid + 1;
            }
        }

        long i = lo;
        long j = half - i;

        boolean hasALeft = i > 0;
        boolean hasARight = i < m;
        boolean hasBLeft = j > 0;
        boolean hasBRight = j < n;

        long leftMax = Long.MIN_VALUE;
        if (hasALeft) {
            leftMax = Math.max(leftMax, src1.get((int) (i - 1)));
        }
        if (hasBLeft) {
            leftMax = Math.max(leftMax, src2.get((int) (j - 1)));
        }

        if (total % 2 == 1) {
            return (double) leftMax;
        }

        long rightMin = Long.MAX_VALUE;
        if (hasARight) {
            rightMin = Math.min(rightMin, src1.get((int) i));
        }
        if (hasBRight) {
            rightMin = Math.min(rightMin, src2.get((int) j));
        }

        return ((double) leftMax + (double) rightMin) / 2.0;
    }
}
