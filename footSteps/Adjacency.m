//
//  Adjacency.m
//  footSteps
//
//  Created by Sumit Chaudhary on 10/05/14.
//  Copyright (c) 2014 dev155. All rights reserved.
//

#import "Adjacency.h"

@implementation Adjacency

//const int INF = 9999;
-(NSArray*)adjacencyMatrix:(NSArray*)points{
  int map[points.count];
  int i=0;
  for (NSNumber* point in points) {
    map[i]=point.intValue;
  }
  // 0 = straight, 1 = right, 2 = left
  int arr[2][points.count+1];
  int dir = 1;
  int size = 0;
  int com[2][4];
  int x = 0;
  int y = 0;
  int half;
  int a, b ;
  arr[0][0] = x;
  arr[1][0] = y;
  for (int i = 0 ; i < 8; i++){
    // north = 1, east = 2, south = 3, west = 4;
    {if (dir == 1 && map[i] == 0)
      dir = 1;
    else if (dir == 1 && map[i] == 1)
      dir = 2;
    else if (dir == 1 && map[i] == 2)
      dir = 4;
    else if (dir == 1 && map[i] == 3)
      dir = 3;
      // north cases ends
      
    else if (dir == 2 && map[i] == 0)
      dir = 2;
    else if (dir == 2 && map[i] == 1)
      dir = 3;
    else if (dir == 2 && map[i] == 2)
      dir = 1;
    else if (dir == 2 && map[i] == 3)
      dir = 4;
      // east cases ends
      
    else if (dir == 3 && map[i] == 0)
      dir = 3;
    else if (dir == 3 && map[i] == 1)
      dir = 4;
    else if (dir == 3 && map[i] == 2)
      dir = 2;
    else if (dir == 3 && map[i] == 3)
      dir = 1;
      // south cases ends
      
    else if (dir == 4 && map[i] == 0)
      dir = 4;
    else if (dir == 4 && map[i] == 1)
      dir = 1;
    else if (dir == 4 && map[i] == 2)
      dir = 3;
    else if (dir == 4 && map[i] == 3)
      dir = 2;
    }
    // west cases ends
    { if ( dir == 1){
      arr[0][i+1] = x;
      arr[1][i+1] = ++y;
    }
    else if ( dir == 2){
      arr[0][i+1] = ++x;
      arr[1][i+1] = y;
    }
    else if ( dir == 4){
      arr[0][i+1] = --x;
      arr[1][i+1] = y;
    }
    else if ( dir == 3){
      arr[0][i+1] = x;
      arr[1][i+1] = --y;
    }
    }
  }
  //printing coordinates
  for (int j = 0 ; j < 9; j++){
//    cout << "x coord : " << arr[0][j] << " " << "y coord :" << arr[1][j] << " " << j <<":"<< "\n";
  }
  //finding number of common coordinates, along with the respective ones.
  int count=0;
  for (int k = 0; k < 9; k++){
    for (int l = 0; l < 9; l++){
      
      if ( arr[0][k] == arr[0][l] && arr[1][k] == arr[1][l] && k !=l){
        ++count;
//        
//        cout << "k: " << k << " " << arr[0][k] << "=" << arr[0][l] << " " << "l: " << l << " " << arr[1][k] << "=" << arr[1][l] << "\n";
        com[0][count-1] = k;
        com[1][count-1] = l;
//        cout << "count:" << count << "\n";
      }
    }
  }
  //number of common coordinates is count/2.
  //adjacency matrix is called adj.
  half = count/2;
  for ( int m = 0; m < half ; m++){
//    cout << com[0][m] << " " << com[1][m] << "\n";
  }
  int adj[7][7];
  for (int i = 0 ; i < 7; i++){
    for (int j = 0; j < 7 ; j++){
      if (j-i==1 || i-j ==1 )
        adj[i][j] = 1;
      else
        adj[i][j]=0;
    }
  }
//  cout << "com: " << com[1][0] << "\n";
  for (int i = 0; i < half ; i++){
    size = half - i;
//    cout << "size:" << size << "\n";
    
    
    a = com[0][i] ;
    b = com[1][i] - size;
    adj[a][b] = 1;
    adj[b][a] = 1;
//    cout << "a: " << a << " " << "b: " << b << "\n";
    if ( a > 0){
      adj[a][b+1] = 1;
      adj[b+1][a] = 1;
      adj[b+1][b] = 0;
      adj[b][b+1] = 0;
//      cout << "b+1: " << adj[b+1][a] << "\n" ;
    }
  }
  for (int i = 0 ; i < 7 ; i++){
    for (int j = 0; j < 7; j++){
//      cout << adj[i][j] << " " ;
    }
//    cout << "i:" << i << "\n";
  }
  
//  NSMutableArray *adjArray = [[NSMutableArray alloc] init];
//  int sizeOfAdj = points.count + 1 - (half);
//  for (int j= 0; j<sizeOfAdj; ++sizeOfAdj) {
//    
//  }
  return nil;
}
@end
