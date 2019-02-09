//
//  LocationsViewController.swift
//  MyLocation
//
//  Created by Phi Hoang Huy on 1/3/19.
//  Copyright © 2019 Phi Hoang Huy. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    lazy var fetchedResultController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        // Sorting based on category and
        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "date", ascending: true)
        //
        fetchRequest.sortDescriptors = [sort1, sort2]
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        fetchedResultController.delegate = self
        return fetchedResultController
    }()
    deinit {
        fetchedResultController.delegate = nil
    }
    var managedObjectContext: NSManagedObjectContext!
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section]
        return sectionInfo.numberOfObjects
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = fetchedResultController.object(at: indexPath)
        cell.configure(for: location)
        return cell
    }
    override func numberOfSections(in tableView: UITableView)
        -> Int {
            return fetchedResultController.sections!.count
    }
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultController.sections![section]
        return sectionInfo.name
    }
    //////
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem
    }
    func performFetch() {
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
}

    // MARK:- NSFetchedResultsController Delegate Extension
    // NSFetchedResultsController will invoke these methods to know that certain objects were inserted, removed, or just updated. In response, you call the corresponding methods on the UITableView to insert, remove or update rows.
    extension LocationsViewController: NSFetchedResultsControllerDelegate {
        func controllerWillChangeContent(_ controller:
            NSFetchedResultsController<NSFetchRequestResult>) {
            print("*** controllerWillChangeContent")
            tableView.beginUpdates()
        }
        func controller(_ controller:
            NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any, at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                print("*** NSFetchedResultsChangeInsert (object)")
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                print("*** NSFetchedResultsChangeDelete (object)")
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                print("*** NSFetchedResultsChangeUpdate (object)")
                if let cell = tableView.cellForRow(at: indexPath!)
                    as? LocationCell {
                    let location = controller.object(at: indexPath!)
                        as! Location
                    cell.configure(for: location)
                }
            case .move:
                print("*** NSFetchedResultsChangeMove (object)")
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            } }
        func controller(_ controller:
            NSFetchedResultsController<NSFetchRequestResult>,
                        didChange sectionInfo: NSFetchedResultsSectionInfo,
                        atSectionIndex sectionIndex: Int,
                        for type: NSFetchedResultsChangeType) {
            switch type {
            case .insert:
                print("*** NSFetchedResultsChangeInsert (section)")
                tableView.insertSections(IndexSet(integer: sectionIndex),
                                         with: .fade)
            case .delete:
                print("*** NSFetchedResultsChangeDelete (section)")
                tableView.deleteSections(IndexSet(integer: sectionIndex),
                                         with: .fade)
            case .update:
                print("*** NSFetchedResultsChangeUpdate (section)")
            case .move:
                print("*** NSFetchedResultsChangeMove (section)")
            }
        }
        func controllerDidChangeContent(_ controller:
            NSFetchedResultsController<NSFetchRequestResult>) {
            print("*** controllerDidChangeContent")
            tableView.endUpdates()
        }
        // Delete
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let location = fetchedResultController.object(at: indexPath)
                location.removePhotoFile()
                    managedObjectContext.delete(location)
                do {
                    try managedObjectContext.save()
                } catch {
                    fatalCoreDataError(error)
                }
            }
        }
        override func tableView(_ tableView: UITableView,
                                viewForHeaderInSection section: Int) -> UIView? {
            let labelRect = CGRect(x: 15,
                                   y: tableView.sectionHeaderHeight - 14,
                                   width: 300, height: 14)
            let label = UILabel(frame: labelRect)
            label.font = UIFont.boldSystemFont(ofSize: 11)
            label.text = tableView.dataSource!.tableView!(
                tableView, titleForHeaderInSection: section)
            label.textColor = UIColor(white: 1.0, alpha: 0.4)
            label.backgroundColor = UIColor.clear
            let separatorRect = CGRect(
                x: 15, y: tableView.sectionHeaderHeight - 0.5,
                width: tableView.bounds.size.width - 15, height: 0.5)
            let separator = UIView(frame: separatorRect)
            separator.backgroundColor = tableView.separatorColor
            let viewRect = CGRect(x: 0, y: 0,
                                  width: tableView.bounds.size.width,
                                  height: tableView.sectionHeaderHeight)
            let view = UIView(frame: viewRect)
            view.backgroundColor = UIColor(white: 0, alpha: 0.85)
            view.addSubview(label)
            view.addSubview(separator)
            return view
        }
    }

