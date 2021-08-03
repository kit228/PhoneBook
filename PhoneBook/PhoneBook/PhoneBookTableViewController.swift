//
//  PhoneBookTableViewController.swift
//  PhoneBook
//
//  Created by Вениамин Китченко on 03.08.2021.
//

import UIKit
import Contacts

class PhoneBookTableViewController: UITableViewController {
    
    var contactStore = CNContactStore()
    var contacts: [ContactStruct] = []
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .secondarySystemBackground
        
        // запрашиваем разрешение контактов
        contactStore.requestAccess(for: .contacts) { success, error in
            if let error = error {
                print("Не удалось получить доступ к контактам: \(error)")
            } else if success {
                print("Доступ к контактам получен")
                DispatchQueue.main.async {
                    self.fetchContacts() // в основном потоке перезагружаем tableView
                }
            }
        }
    }
    
    func fetchContacts() { // получаем список контактов
        
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        
        do {
            try contactStore.enumerateContacts(with: request) { contact, stoppingPointer in
//                let name = contact.givenName
//                let lastName = contact.familyName
//                let phoneNumber = contact.phoneNumbers.first?.value.stringValue // первый номер этого контакта
//                let contactToAppend = ContactStruct(name: name, lastName: lastName, phoneNumber: phoneNumber)
//                self.contacts.append(contactToAppend)
//                self.tableView.reloadData()
//            }
                
                let name = contact.givenName
                let lastName = contact.familyName
                
                if !contact.phoneNumbers.isEmpty {
                    for number in contact.phoneNumbers {
                        let phoneNumber = number.value.stringValue // номер этого контакта в формате строки
                        let contactToAppend = ContactStruct(name: name, lastName: lastName, phoneNumber: phoneNumber)
                        self.contacts.append(contactToAppend)
                    }
                }
                
                
                self.tableView.reloadData()
            }
        } catch {
            print("Не получилось взять контакт, ошибка: ", error.localizedDescription)
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.textColor = .label
        cell.textLabel?.text = contacts[indexPath.row].lastName + " " + contacts[indexPath.row].name + " / " + (contacts[indexPath.row].phoneNumber ?? "")
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // действие по нажатию на ячейку
        tableView.deselectRow(at: indexPath, animated: true) // снимаем подсвечивание ячейки
        
        // делаем вызов по мобильному
        if let number = contacts[indexPath.row].phoneNumber {
            guard let url = URL(string: "tel://" + number) else {return}
            UIApplication.shared.openURL(url)
        }
    }

}
