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

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.bodyEntity = BodyEntity3D(arView: self,
                                       smoothingAmount: 0.7)
        

        //This is an alternative to a do-try-catch block.
        guard let _ = try? runBodyTrackingConfig3D() else {
            print("This device does Not support body tracking.")
            return
        }
        
        //Always remember to add the Anchors to the scene.
        self.scene.addAnchor(bodyAnchor)
        
        //Load and show the robot.
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

        
    }
    
    private func makeTrackedJointsVisible(){
        //There are more joints you could attach entities to, I'm just using these.
        //Another way to attach entities to the skeletion, but iteratively this time:
        ThreeDBodyJoint.trackedJoints.forEach { joint in
            let sphere = Entity.makeSphere(radius: 0.05)
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
