//
//  ViewController.swift
//  Drive AR
//
//  Created by Ashish Pisey on 30/05/22.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    let motionManager = CMMotionManager()
    var vehicle = SCNPhysicsVehicle()
    var orientation: CGFloat = 0.0
    var touched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [.showWorldOrigin]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func createConcreteNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
        node.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        node.geometry?.firstMaterial?.isDoubleSided = true
        node.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        node.physicsBody = SCNPhysicsBody.static()
        return node
    }
    
    @IBAction func addCar(_ sender: Any) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentCameraPosition = orientation + location
        
        let scene = SCNScene(named: "CarScene.scn")
        guard let chassis = scene?.rootNode.childNode(withName: "chassis", recursively: false) else { return }
        chassis.position = currentCameraPosition
        
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node:chassis, options:[.keepAsCompound: true]))
        body.mass = 1 //default
        
        chassis.physicsBody = body
        
        guard let rearLeftWheel = chassis.childNode(withName: "rearLeftParent", recursively: true) else { return }
        guard let rearRightWheel = chassis.childNode(withName: "rearRightParent", recursively: true) else { return }
        guard let frontLeftWheel = chassis.childNode(withName: "frontLeftParent", recursively: true) else { return }
        guard let frontRightWheel = chassis.childNode(withName: "frontRightParent", recursively: true) else { return }
        
        let v_frontLeftWheel = SCNPhysicsVehicleWheel(node:frontLeftWheel)
        let v_frontRightWheel = SCNPhysicsVehicleWheel(node:frontRightWheel)
        let v_rearLeftWheel = SCNPhysicsVehicleWheel(node:rearLeftWheel)
        let v_rearRightWheel = SCNPhysicsVehicleWheel(node:rearRightWheel)
        
        self.vehicle = SCNPhysicsVehicle(chassisBody: chassis.physicsBody!, wheels: [v_rearLeftWheel, v_rearRightWheel, v_frontLeftWheel, v_frontRightWheel])
        self.sceneView.scene.physicsWorld.addBehavior(self.vehicle)
        
        self.sceneView.scene.rootNode.addChildNode(chassis)
    }
    
    func setupAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1/60
            motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let accelerometerData = accelerometerData else { return }
                self.accelerometerDidChange(acceleration: accelerometerData.acceleration)
            }
        } else {
            print("Accelerometer not available")
        }
    }
    
    func accelerometerDidChange(acceleration: CMAcceleration) {
        print(acceleration.x, acceleration.y)
        if acceleration.x > 0 {
            self.orientation = CGFloat(acceleration.y)
        } else {
            self.orientation = -CGFloat(acceleration.y)
        }
        print("")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touched = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touched = false
    }
}

func +(first: SCNVector3, second: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(first.x + second.x, first.y + second.y, first.z + second.z)
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let concreteNode = createConcreteNode(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
        print("New plane detected")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        
        let concreteNode = createConcreteNode(planeAnchor: anchor)
        node.addChildNode(concreteNode)
        
        print("Update floor's anchors")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        print("simulate physics")
        self.vehicle.setSteeringAngle(orientation, forWheelAt: 2)
        self.vehicle.setSteeringAngle(orientation, forWheelAt: 3)
        var engineForce: CGFloat = 0
        
        if touched {
            engineForce = 5
        } else {
            engineForce = 0
        }
        
        self.vehicle.applyEngineForce(engineForce, forWheelAt: 0)
        self.vehicle.applyEngineForce(engineForce, forWheelAt: 1)
    }
    
    
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
