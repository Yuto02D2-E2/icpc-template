#include "testlib.h"
#include "constraints.h"

#include <algorithm>
#include <fstream>
#include <set>
#include <sstream>
#include <vector>

using namespace std;


long long simulate(const vector<int>& order, const vector<long long>& c) {
    int n = order.size();
    long long res = 0;
    for (int i = 0; i + 1 < n; ++i) {
        int l = min(order[i] - 1, order[i + 1] - 1);
        int r = max(order[i] - 1, order[i + 1] - 1);
        for (int j = l; j < r; ++j) {
            res += c[j];
        }
    }
    return res;
}

long long calc_max(const vector<long long>& c) {
    const long long LM = 1LL << 61;
    int n = c.size() + 1;
    vector<vector<vector<long long>>> dp(n - 1, vector<vector<long long>>(3, vector<long long>(n + 1, -LM)));
    dp[0][0][2] = c[0] * 2;
    dp[0][1][1] = c[0];
    for (int i = 1; i < n - 1; ++i) {
        for (int j = 0; j < 3; ++j) {
            for (int k = 1; k < n + 1; ++k) {
                for (int l = -2; l <= 2; l += 2) {
                    if (0 < k + l && k + l < n + 1 && dp[i][j][k] < dp[i - 1][j][k + l] + c[i] * k) {
                        dp[i][j][k] = dp[i - 1][j][k + l] + c[i] * k;
                    }
                }
                if (j) {
                    for (int l = -1; l <= 1; l += 2) {
                        if (0 < k + l && k + l < n + 1 && dp[i][j][k] < dp[i - 1][j - 1][k + l] + c[i] * k) {
                            dp[i][j][k] = dp[i - 1][j - 1][k + l] + c[i] * k;
                        }
                    }
                }
            }
        }
    }
    return max(dp[n - 2][1][1], dp[n - 2][2][2]);
}

int main(int argc, char** argv) {
    registerTestlibCmd(argc, argv);

    for (int casenum = 0; ; ++casenum) {
        int n = inf.readInt();
        if (n == 0) {
            break;
        }
        setTestCase(casenum);
        vector<long long> c = inf.readLongs(n - 1);

        long long s = ouf.readLong();
        vector<int> order = ouf.readInts(n);
        {
            vector<bool> used(n);
            for (int i = 0; i < n; ++i) {
                if (!(1 <= order[i] && order[i] <= n)) {
					quitf(_wa, "Case #%d: Illegal value at position %d: %d", casenum, i, order[i]);
                }
                if (used[order[i] - 1]) {
					quitf(_wa, "Case #%d: Duplicate value %d", casenum, order[i]);
                }
                used[order[i] - 1] = true;
            }
        }
        long long sim_s = simulate(order, c);
        if (s != sim_s) {
            quitf(_wa, "Case #%d: Output is %d, but simulated is %d", casenum, s, sim_s);
        }
        long long ans_s = calc_max(c);
        if (s < ans_s) {
            quitf(_wa, "Case #%d: Output is %d, but expected is %d", casenum, s, ans_s);
        }
        else if (s > ans_s) {
            quitf(_fail, "Case #%d: Output is %d, but expected is %d", casenum, s, ans_s);
        }
        else {
            // ok
        }
    }
    if (!ouf.seekEof()) {
        quitf(_wa, "Participant output contains extra tokens");
    }
    quitf(_ok, "ok");
    return 0;
}
