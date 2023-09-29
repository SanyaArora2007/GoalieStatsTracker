//
//  test.swift
//  GoalieStatsTracker
//
//  Created by Sanya Arora on 10/12/23.
//

import SwiftUI

struct test: View {
    
    @State var points: [CGPoint] = []
    
    var drawCircle: some Gesture {
        SpatialTapGesture()
            .onEnded() { event in
                points.append(event.location)
            }
    }
    
    var body: some View {
        ZStack {
            Text("HEre")
            
            ForEach(points, id: \.x) { point in
                CreateCircle(location: point)
            }
        }
        .contentShape(Rectangle())
        .gesture(drawCircle)
        
    }
}



struct CreateCircle: View {
    

    @State var currentLocation: CGPoint = CGPoint.zero
    
    init(location: CGPoint) {
        currentLocation = location
        print(location)
        print(currentLocation)
    }
    
    var body: some View {

        return Circle().fill(Color.red)
            .frame(width: 20, height: 20)
            .position(currentLocation)
    }
}




struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
