//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Danny Vo on 2020-06-21.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit
import FirebaseAuth

class NotesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolbar: UIToolbar!
    var notes = [Note]()
    var moveIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Notes"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(goToWrite))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        toolbar.setBackgroundImage(UIImage(),
                                        forToolbarPosition: .any,
                                        barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        let defaults = UserDefaults.standard
        
        if let savedNotes = defaults.object(forKey: "final3") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes")
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var count = 0
        for item in notes {
            if item.body == "" {
                notes.remove(at: count)
            }
            count += 1
        }
        
        if moveIndex != -1 {
            let tempNote = notes[moveIndex]
            notes.remove(at: moveIndex)
            notes.insert(tempNote, at: 0)
            moveIndex = -1
        }
        
        self.save()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    @objc func goToWrite() {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            // push the text into next view
            let newNote = Note(body: "")
            notes.append(newNote)
            vc.note = notes[notes.count - 1]
            vc.i = notes.count - 1
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func edit(sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "final3")
        } else {
            print("Failed to save notes")
        }
    }
}


extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.note = notes[indexPath.row]
            vc.i = indexPath.row
            self.moveIndex = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.save()
        }
    }
}

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notes", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].body
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
}


