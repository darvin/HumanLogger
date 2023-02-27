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
    
    private var handTrackers: [HandTracker3D]!


    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        runNewConfig()

//
        

        self.bodyEntity = BodyEntity3D(arView: self,
                                       smoothingAmount: 0.7)
//        //This is an alternative to a do-try-catch block.
//        guard let _ = try? runBodyTrackingConfig3D() else {
//            print("This device does Not support body tracking.")
//            return
//        }

        self.scene.addAnchor(bodyAnchor)

        BodyTrackedEntity.loadCharacterAsync(named: "robotWhite"){ robot in
            print("Loaded \"robotWhite\"")
            print(robot)
            if let modelComp = robot.components[ModelComponent.self] as? ModelComponent {
                print(modelComp.materials)
            }
            self.robot = robot
            self.bodyAnchor.addChild(robot)
        }
        makeTrackedJointsVisible()

        
        
        
        
        self.handTrackers =
            [HandTracker3D(arView: self),
             HandTracker3D(arView: self)
            ]


        let sceneAnchor = AnchorEntity()

        self.scene.addAnchor(sceneAnchor)

        for handTracker in handTrackers {
            sceneAnchor.addChild(handTracker)
        //            handTracker.requestRate = .quarter
        }

        makeHandJointsVisible()

    }
    
    private func makeTrackedJointsVisible(){
        //There are more joints you could attach entities to, I'm just using these.
        //Another way to attach entities to the skeletion, but iteratively this time:
        ThreeDBodyJoint.trackedJoints.forEach { joint in
            let sphere = Entity.makeSphere(radius: 0.05)
            bodyEntity.attach(thisEntity: sphere, toThisJoint: joint)
        }
    }

    
    private func makeHandJointsVisible(){
        
        //Another way to attach views to the skeletion, but iteratively this time:
        HandTracker2D.allHandJoints.forEach { joint in
            for handTracker in handTrackers {
                let sphere = Entity.makeSphere(color: .white, radius: 0.01, isMetallic: true)
                handTracker.attach(thisEnt: sphere, toThisJoint: joint)
            }
        }
    }

    func runNewConfig(){
        // Create a session configuration
        let configuration = ARBodyTrackingConfiguration()
        
        //Goes with (currentFrame.smoothedSceneDepth ?? currentFrame.sceneDepth)?.depthMap
        let frameSemantics: ARConfiguration.FrameSemantics = [.smoothedSceneDepth, .sceneDepth]
        
        //Goes with currentFrame.estimatedDepthData
//        let frameSemantics: ARConfiguration.FrameSemantics = [.personSegmentationWithDepth]
//        let frameSemantics: ARConfiguration.FrameSemantics = [.personSegmentation]

        if ARBodyTrackingConfiguration.supportsFrameSemantics(frameSemantics) {
            configuration.frameSemantics.insert(frameSemantics)
        }
        // Run the view's session
        session.run(configuration)
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
