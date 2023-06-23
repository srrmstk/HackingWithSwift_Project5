//
//  ViewController.swift
//  Project5
//
//  Created by srrmstk on 21.06.2023.
//

import UIKit

class ViewController: UITableViewController {

  var allWords = [String]()
  var usedWords = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Start Game", style: .plain, target: self, action: #selector(startGame))

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      // try? means: call this code, and if it throws - return nil
      if let startWords = try? String(contentsOf: startWordsURL) {
        allWords = startWords.components(separatedBy: "\n")
      }
    }

    if allWords.isEmpty {
      allWords = ["silkworm"]
    }

    startGame()
  }

  @objc
  func promptForAnswer() {
    let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
    ac.addTextField()

    let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
      guard let answer = ac?.textFields?[0].text else { return }
      self?.submit(answer)
    }

    ac.addAction(submitAction)
    present(ac, animated: true)
  }

  func submit(_ answer: String) {
    let lowerAnswer = answer.lowercased()

    if isPossible(word: lowerAnswer) {
      if isOriginal(word: lowerAnswer) {
        if isReal(word: lowerAnswer) {
          usedWords.insert(answer, at: 0)

          let indexPath = IndexPath(row: 0, section: 0)
          tableView.insertRows(at: [indexPath], with: .automatic)

          return
        } else {
          showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
        }
      } else {
        showErrorMessage(title: "Word used already", message: "Be more original!")
      }
    } else {
      guard let title = title?.lowercased() else { return }
      showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title)")
    }

  }

  func showErrorMessage(title: String, message: String) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }

  func isPossible(word: String) -> Bool {
    guard var tempWord = title?.lowercased() else { return false }
    for letter in word {
      if let position = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: position)
      } else {
        return false
      }
    }
    return true
  }

  func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

    return misspelledRange.location == NSNotFound && word.utf16.count >= 3
  }

  func isOriginal(word: String) -> Bool {
    return !usedWords.contains(word) && word.lowercased() != title?.lowercased()
  }

  @objc
  func startGame() {
    title = allWords.randomElement()
    usedWords.removeAll(keepingCapacity: true)
    tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
    var content = cell.defaultContentConfiguration()
    content.text = usedWords[indexPath.row]
    cell.contentConfiguration = content
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usedWords.count
  }

}

