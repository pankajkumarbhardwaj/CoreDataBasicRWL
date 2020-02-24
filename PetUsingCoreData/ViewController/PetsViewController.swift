//
//  PetsViewController.swift
//  PetUsingCoreData
//
//  Created by Pankaj Kumar on 21/01/20.
//  Copyright © 2020 Pankaj Kumar. All rights reserved.
//

import UIKit
import CoreData

class PetsViewController: UIViewController {
    @IBOutlet private weak var collectionView:UICollectionView!
    
    var formatter = DateFormatter()
    var friend:Friend!

    private var fetchedRC:NSFetchedResultsController<Pet>!
    private var query = ""
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).parsistanceContainer.viewContext
    
    private var isFiltered = false
    private var filtered = [String]()
    private var selected:IndexPath!
    private var picker = UIImagePickerController()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        picker.delegate = self
        formatter.dateFormat = "d MM YYYY"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refresh()
    }
    
    private func refresh() {
        let request = Pet.fetchRequest() as NSFetchRequest<Pet>
        if query.isEmpty {
            request.predicate = NSPredicate(format: "owner = %@", friend)
        }else {
          request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND owner = %@", query, friend)
        }
        let sort = NSSortDescriptor(key: #keyPath(Pet.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedRC.delegate = self
            try fetchedRC.performFetch()
        }catch let error as NSError {
            print("Could not fetch ", error.userInfo)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Actions
    @IBAction func addPet() {
       let data = PetData()
        let pet = Pet(entity: Pet.entity(), insertInto: context)
        pet.name = data.name
        pet.dob = data.dob
        pet.kind = data.kind
        pet.owner = friend
        appDelegate.saveContext()
//        refresh()
//        collectionView.reloadData() // fetched result controller delegate handle this
    }
    
    @IBAction func handleLongPressGesture(gestureReconizer:UIGestureRecognizer) {
        if gestureReconizer.state  != .ended {
            return
        }
        let point = gestureReconizer.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let pet = fetchedRC.object(at: indexPath)
            context.delete(pet)
            appDelegate.saveContext()
            refresh()
//            collectionView.deleteItems(at: [indexPath])
        }
    }
}



// Collection View Delegates
extension PetsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pets = fetchedRC.fetchedObjects else {
            return 0
        }
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCell", for: indexPath) as! PetCell
        let pet = fetchedRC.object(at: indexPath)
        cell.nameLabel.text = pet.name
        cell.animalLabel.text = pet.kind
        if let dob = pet.dob {
            cell.dobLabel.text = formatter.string(from: dob)
        }else {
            cell.dobLabel.text = "Unknown"
        }
        if let data = pet.picture {
            cell.pictureImageView.image = UIImage(data: data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected = indexPath
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
}

// Search Bar Delegate
extension PetsViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let txt = searchBar.text else {
            return
        }
        query = txt
        refresh()
        searchBar.resignFirstResponder()
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        query = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
        refresh()
        collectionView.reloadData()
    }
}

// Image Picker Delegates
extension PetsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pet = fetchedRC.object(at: selected)
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        pet.picture = image.pngData()
        appDelegate.saveContext()
        collectionView?.reloadItems(at: [selected])
        picker.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension PetsViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let indexPath = indexPath ?? (newIndexPath ?? nil)
        guard let cellIndex = indexPath else { return}
        switch type {
        case .insert:
            collectionView.insertItems(at: [cellIndex])
        case .delete:
            collectionView.deleteItems(at: [cellIndex])
        default:
            break
        }
    }
}
