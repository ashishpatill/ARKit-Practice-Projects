//
//  ViewController.swift
//  Ikea
//
//  Created by Ashish Pisey on 12/05/22.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var ikeaCollectionView: UICollectionView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var lblPlaneDetected: UILabel!
    var items = ["cup", "vase", "table", "boxing"]
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        ikeaCollectionView.dataSource = self
        ikeaCollectionView.delegate = self
        registerGestureRecognizers()
        sceneView.autoenablesDefaultLighting = true
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(sender:)))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            print("touched horizontal surface")
            addItem(hitTestResult: hitTest.first!)
        } else {
            print("no match")
        }
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale = 1.0 // important, scale should not increase exponentially
        } else {
            print("no match")
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult) {
        guard var selectedItem = getSelectedItemName() else { return }
        if selectedItem == "cup" { selectedItem = "coffe_cup" }
        let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
        guard let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false) else { return }
        
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    func getSelectedItemName() -> String? {
        if let indexPath = ikeaCollectionView.indexPathsForSelectedItems?.first,
           let cell = ikeaCollectionView.cellForItem(at: indexPath) as? ItemCell {
            return cell.itemName.text
        }
        return nil
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ItemCell
        cell.itemName.text = items[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .green
        cell?.isSelected = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .orange
        cell?.isSelected = false
    }
}

extension ViewController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        lblPlaneDetected.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("Plane detected")
            self.lblPlaneDetected.isHidden = true
        }
    }
}
