//
//  MainViewController.swift
//  PetUsingCoreData
//
//  Created by Pankaj Kumar on 21/01/20.
//  Copyright © 2020 Pankaj Kumar. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    @IBOutlet private weak var collectionView:UICollectionView!
    
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).parsistanceContainer.viewContext
  private var fetchedRC: NSFetchedResultsController<Friend>!
    private var filtered = [Friend]()
    private var isFiltered = false
    private var selected:IndexPath!
    private var picker = UIImagePickerController()
  private var query = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }
 
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refresh()
    showEditButton()
  }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "petSegue" {
            if let index = sender as? IndexPath {
                let pvc = segue.destination as! PetsViewController
                let friend = fetchedRC.object(at: index)
                pvc.friend = friend
            }
        }
    }
    


    // MARK:- Actions
    @IBAction func addFriend() {
        let data = FriendData()
        let friend = Friend(entity: Friend.entity(), insertInto: context)
        friend.name = data.name
        friend.address = data.address
        friend.dob = data.dob as NSDate as Date
        friend.eyeColour = data.eyeColor
        appDelegate.saveContext()
        refresh()
        collectionView.reloadData()
        showEditButton()
    }
    
    // MARK:- Private Methods
    private func showEditButton() {
    guard let objs = fetchedRC.fetchedObjects else {
      return
    }
    if objs.count > 0 {
            navigationItem.leftBarButtonItem = editButtonItem
        }
    }
 
  private func refresh() {
    let request = Friend.fetchRequest() as NSFetchRequest<Friend>
    if !query.isEmpty {
      request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
    }
    //let sort = NSSortDescriptor(keyPath: \Friend.name, ascending: true)
    let sort = NSSortDescriptor(key: #keyPath(Friend.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    let color = NSSortDescriptor(key: #keyPath(Friend.eyeColour), ascending: true)
    request.sortDescriptors = [color, sort]
    do {
      fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(Friend.eyeColour), cacheName: nil)
      try fetchedRC.performFetch()
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
 
}

// Collection View Delegates
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderRow", for: indexPath)
        if let label = view.viewWithTag(1000) as? UILabel {
            if let friends = fetchedRC.sections?[indexPath.section].objects as? [Friend], let friend = friends.first {
                label.text = "Eye Colour : " + friend.eyeColourString
            }
        }
        return view
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedRC.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedRC.sections, let objc = sections[section].objects else {
            return 0
        }
        return objc.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = fetchedRC.object(at: indexPath)
        cell.nameLabel.text = friend.name
        cell.addressLabel.text = friend.address
        cell.ageLabel.text = "Age : \(friend.age)"
        cell.eyeColorView.backgroundColor = friend.eyeColour as? UIColor
        if let data = friend.photo as Data?  {
            cell.pictureImageView.image = UIImage(data: data)
        }else {
            cell.pictureImageView.image = UIImage(named: "person-placeholder")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            selected = indexPath
            self.navigationController?.present(picker, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "petSegue", sender: indexPath)
        }
    }
}

// Search Bar Delegate
extension MainViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        query = text
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
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        let friend = fetchedRC.object(at: selected)
        friend.photo = image.pngData() as? NSData as Data?
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

