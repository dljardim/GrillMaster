//
//  ContentView.swift
//  GrillMaster
//
//  Created by Damian Jardim on 4/15/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}


struct DragToyView: View {
    var body: some View {
        Text("🧸 Teddy Bear")
            .padding()
            .background(Color.pink)
            .cornerRadius(10)
            .onDrag {
                return NSItemProvider(object: "Teddy Bear" as NSString)
            }
    }
}


struct DragAndDropTest: View {
    @State private var droppedText: String = "Drop here"
    
    var body: some View {
        HStack {
            Text("🍎 Apple")
                .padding()
                .background(Color.red.opacity(0.7))
                .cornerRadius(8)
                .onDrag {
                    NSItemProvider(object: "Apple" as NSString)
                }
            
            Text(droppedText)
                .padding()
                .frame(width: 120, height: 100)
                .background(Color.green.opacity(0.5))
                .cornerRadius(8)
                .onDrop(of: [.text], isTargeted: nil) { providers in
                    providers.first?.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
                        if let data = item as? Data,
                           let string = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                droppedText = "Dropped: \(string)"
                            }
                        }
                    }
                    return true
                }
        }
    }
}

struct TapGesturesViews: View {
    var body: some View {
        Text("X")
            .padding()
            .frame(width: 120, height: 100)
            .background(Color.green.opacity(0.5))
            .cornerRadius(8)
            .onTapGesture {
                print("tap")
            }
            .onTapGesture(count: 2){
                print("double tapped!")
            }
 
    }
}

struct DragCircleView: View {
    
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            
            VStack{
                Circle()
                    .fill(Color.red)
                    .frame(width: 64, height:64)
                    .scaleEffect(isDragging ? 1.5 : 1)
                    .offset(offset)
//                    .gesture(combined)
            }
        }
        
    }
}

class XUser: ObservableObject {
    var username:String = "Ted"
}

struct XView: View {
    @StateObject var xUser = XUser()
    var body: some View {
        Text("username: \(xUser.username)")
    }
}

//
//@ObservableObject class MessageQueue: ObservableObject {
//    @Published var messages:[String] = []
//    
//}
//
//struct MySimpleView: View {
//    @StateObject var myMessageQueue:MessageQueue
//    
//    var body: some View {
//        Text("MySimpleView")
//    }
//}



/*
 
 observable object
 - an object that can be watched for updates
 - @published - will tell swift to broadcast that the @published variable value has changed
 
 @stateobject - *** OWNED BY THE VIEW Structure *** is a instance of an observable object, which swiftui will retain during updates / renders
 @observedobject - View / structure does not own the observed object.  it should be initialized and passed into the view.
 
 
 whats wrong?
 @ObservedObject property wrapper should not be used when creating an instance of the observable object in our view.  the @ObservedObject should be created outside and passed into the view.
 
 @StateObject should be used when creatinga an instance of an observableObject which should be owned by the view
 
 help -
 i dont see any difference in the output when using @StateObject instead of @ObservedObject.  Both variations show the same output when i click 'get points'.
 
 
 */


class GameStats: ObservableObject {
    @Published var score = 0
    @Published var lives = 3
}

struct GameScreen: View {
    
    @StateObject var stats = GameStats()
    
    var body: some View {
        VStack {
            Text("Score: \(stats.score)")
            Text("Lives: \(stats.lives)")
            Button("Get Points") {
                stats.score += 10
            }
        }
    }
}



/*

The contents of PetGame is recreated on PetGames button click - including the recreation of a new pet.
 so everything in the body of petgame gets recreated including the call to PetMoodDisplay().
since pet is not passed into PetMoodDisplay it create a new local @stateobject with the same value of 50.
 
 fix it by using @ObservedObject instead. this will pass in the pet and not recreate it.
 
i dont think my explanation is very clear or completely correct.  can you list the correct order  of what occurs in the life cycle of PetGame.
 */


class Pet: ObservableObject {
    @Published var happiness = 50
}

struct PetGame: View {
    @StateObject var pet = Pet()
    
    var body: some View {
        VStack {
            Text("Main Game View")
            PetMoodDisplay(pet: pet)
            Button("Pet the Dog") {
                pet.happiness += 10
            }
        }
    }
}

struct PetMoodDisplay: View {
    @ObservedObject var pet:Pet
    
    var body: some View {
        Text("Happiness: \(pet.happiness)")
    }
}


import SwiftUI

// ## SNIPPET
struct DraggersView: View {
    @State private var location: CGPoint = CGPoint(x: 50, y: 50)
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
            }
    }
    
    var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { (value, fingerLocation, transaction) in
                fingerLocation = value.location
            }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.red)
                .frame(width: 100, height: 100)
                .position(location)
                .gesture(
                    simpleDrag.simultaneously(with: fingerDrag)
                )
            if let fingerLocation = fingerLocation {
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .position(fingerLocation)
            }
        }
    }
}


/*
 CGPoint(x, y)
 100, 200 -- 100 right, 200 down
 by default - the view is created in the center
 
 position works on the center of a view
 so if there was a frame 100w, 100h and position is 0,0

 since position is a center of the view the result with have half the frame will be off screen
 
 */



//struct DoSomethingWithItView: View {
//    
//    @State var positionsArray:[CGPoint] = [
//        CGPoint(x: 0, y: 0),
//        CGPoint(x: 100, y: 100),
//        CGPoint(x:300, y:300)
//    ]
//    
//    enum positionsEnum {
//        case topLeft
//        case center
//        case bottomRight
//    }
//
//    var body: some View {
//        VStack{
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.yellow)
//                .frame(width: 100, height: 100)
//                .position(positionsArray.map{ myPoint:CGPoint in
//                    
//                })
//                .overlay{
//                    Text("x: \(0), y: \(0)")
//                }
//                
//        }
//
//    }
//}
/*
 
 the updating callback should use a @BestureState binding to the gesture (long press)
 
 */
struct MovingCircle: View {
    @State private var location = CGPoint(x: 150, y: 300)
    
    // binds to the .updating callback
    @GestureState private var isDetectingLongPress = false
        
    // create gesture
    // gesture callbacks:  updating, onChanged, onEnded
    let tap = TapGesture()
        .onEnded{ _ in
            print("View tapped")
        }
        
        
   
    
    // attach gesture to the view suing .gesture(gestureName)
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 100, height: 100)
            .position(location)
            .gesture(tap)
    }
}





#Preview {
//    TapGesturesViews()
//    DragCircleView()
//    XView()
//    GameScreen()
//    PetGame()
//    DraggersView()
//    /*DoSomethingWithItView*/()
    MovingCircle()
}
