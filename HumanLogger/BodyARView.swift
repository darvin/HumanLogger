//
//  BodyARView.swift
//  HumanLogger
//
//  Created by standard on 2/27/23.
//

import Foundation


import ARKit
import RealityKit
import BodyTracking



class BodyARView: ARView {
    
    
    ///This is an anchor entity that will be used to attatch the character to the person.
    ///
    ///This is an Anchor Entity (from RealityKit) targeting a body,
    ///which is Not the same thing as an ARBodyAnchor (from ARKit).
    private let bodyAnchor = AnchorEntity(.body)
    
    private var robot: BodyTrackedEntity!
    
    private var bodyEntity : BodyEntity3D!
    
    private var handTrackers: [HandTracker2D]!


    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        

        self.bodyEntity = BodyEntity3D(arView: self,
                                       smoothingAmount: 0.7)
        //This is an alternative to a do-try-catch block.
        guard let _ = try? runBodyTrackingConfig3D() else {
            print("This device does Not support body tracking.")
            return
        }

        self.scene.addAnchor(bodyAnchor)

        BodyTrackedEntity.loadCharacterAsync(named: "robotWhite"){ robot in
            print("Loaded \"robotWhite\"")
            print(robot)
            
//            var material = SimpleMaterial()
//
//            material.tintColor = UIColor.init(red: 1.0,
//                                            green: 1.0,
//                                             blue: 1.0,
//                                            alpha: 0.025)
//
//            material.baseColor = MaterialColorParameter.color(UIColor.red)
//
//            robot.model?.materials = [material]

            if let modelComp = robot.components[ModelComponent.self] as? ModelComponent {
                print(modelComp.materials)
            }
            self.robot = robot
            self.bodyAnchor.addChild(robot)
        }
        makeTrackedJointsVisible()

        
        
        
        




        
    }
    
    
    
    // Track the screen dimensions:
    lazy var windowWidth: CGFloat = {
        return UIScreen.main.bounds.size.width
    }()
    
    lazy var windowHeight: CGFloat = {
        return UIScreen.main.bounds.size.height
    }()

    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        
        self.handTrackers =
            [HandTracker2D(arView: self),
             HandTracker2D(arView: self)
            ]

        for handTracker in handTrackers {
        //            handTracker.requestRate = .quarter
            makeHandJointsVisible(handTracker: handTracker)
        }
    }
    
    
    private func makeCircle(circleRadius: CGFloat = 20,
                            color: CGColor = #colorLiteral(red: 0.3175252703, green: 0.7384468404, blue: 0.9564777644, alpha: 1)) -> UIView {
        
        // Place circle at the center of the screen to start.
        let xStart = floor((windowWidth - circleRadius) / 2)
        let yStart = floor((windowHeight - circleRadius) / 2)
        let frame = CGRect(x: xStart, y: yStart, width: circleRadius, height: circleRadius)
        
        let circleView = UIView(frame: frame)
        circleView.layer.cornerRadius = circleRadius / 2
        circleView.layer.backgroundColor = color
        return circleView
    }
    
    
    
    private func makeHandJointsVisible(handTracker: HandTracker2D){
        
        //Another way to attach views to the skeletion, but iteratively this time:
        HandTracker2D.allHandJoints.forEach { joint in
            let circle = makeCircle(circleRadius: 5, color: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1))
            handTracker.attach(thisView: circle, toThisJoint: joint)
        }
    }

    
    private func makeTrackedJointsVisible(){
        //There are more joints you could attach entities to, I'm just using these.
        //Another way to attach entities to the skeletion, but iteratively this time:
        ThreeDBodyJoint.trackedJoints.forEach { joint in
            let sphere = Entity.makeSphere(color: .white, radius: 0.01, isMetallic: true)
            bodyEntity.attach(thisEntity: sphere, toThisJoint: joint)
        }
    }

    

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stopSession(){
        self.session.pause()
        self.scene.anchors.removeAll()

        self.robot.removeFromParent()
        self.robot = nil
   }
    
    deinit {
        self.stopSession()
    }
    
}
