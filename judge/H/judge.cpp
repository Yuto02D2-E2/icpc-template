#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <cstdarg>
#include <set>
#include <map>
#include <utility>
#include <algorithm>
#include <cassert>
#include <sstream>

#include "testlib.h"

using namespace std;

vector<int> readints(){
	vector<int> v;
	while(!ouf.seekEoln()){
		int x = ouf.readInt();
		v.push_back(x);
	}

	return v;
}

int main(int argc, char **argv){
	// Expected arguments: input output answer(unused)
	registerTestlibCmd(argc, argv);

	using pii = pair<int,int>;

	for(int casenum = 1; ; ++casenum){
		int n = inf.readInt();
		int m = inf.readInt();
		if(n == 0){ break; }
		
		setTestCase(casenum);

		vector<int> deg(n + 1);
		set<pii> edges;
		for(int i = 0; i < m; ++i){
			int a = inf.readInt();
			int b = inf.readInt();
			++deg[a];
			++deg[b];
			edges.insert(minmax(a, b));
		}

		vector<int> v = readints();
		int sz = v.size();

		int numdeg1 = 0;
		for(int i = 1; i <= n; ++i){
			if(deg[i] == 1){
				++numdeg1;
			}
		}
		
		if(numdeg1 >= 3){
			if(sz == 1 && v[0] == -1){
				// ok
			}
			else{
				quitf(_wa, "Unexpected output for an impossible case");
			}
		}
		else{
			if(sz == 1 && v[0] == -1){
				quitf(_wa, "Unexpected \"impossible\" for a possible case");
			}
			
			for(int i = 0; i < sz; ++i){
				int x = v[i];
				if(x < 1 || x > n){
					quitf(_wa, "Illegal value at position %d: %d", i, x);
				}
			}
			
			map<pii,int> movecnt;
			for(int i = 1; i < sz; ++i){
				int a = v[i - 1];
				int b = v[i];
				pii key = minmax(a, b);
				
				if(!edges.count(key)){
					quitf(_wa, "Passed non-existing edge at position %d: %d -> %d", i, a, b);
				}
				++movecnt[key];
				
				if(i >= 2 && v[i - 2] == v[i]){
					quitf(_wa, "Prohibited move at position %d: %d -> %d -> %d", i, v[i - 2], v[i - 1], v[i]);
				}
			}
			
			for(pii key : edges){
				int cnt = movecnt[key];
				if(cnt == 0){
					quitf(_wa, "Edge {%d, %d} was never passed", key.first, key.second);
				}
				if(cnt >= 3){
					quitf(_wa, "Edge {%d, %d} was passed %d times", key.first, key.second, cnt);
				}
			}
		}
	}
	
	ouf.seekEof();
	ouf.readEof();

	quitf(_ok, "Passed");
}
