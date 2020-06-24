//
//  ViewController.swift
//  NotesApp
//
//  Created by Danny Vo on 2020-06-21.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UINavigationControllerDelegate {
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(goToWrite))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let defaults = UserDefaults.standard
        
        if let savedNotes = defaults.object(forKey: "final2") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var count = 0
        for item in notes {
            if item.body == "" {
                notes.remove(at: count)
            }
            count += 1
        }
        self.save()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notes", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].body
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.note = notes[indexPath.row]
            vc.i = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.save()
        }
    }
    
    @objc func edit(sender: UIBarButtonItem) {
        //let deleteBtn = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: )
        isEditing = !isEditing
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "final2")
        } else {
            print("Failed to save notes")
        }
    }
}

