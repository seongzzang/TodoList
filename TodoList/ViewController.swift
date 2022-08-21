//
//  ViewController.swift
//  TodoList
//
//  Created by 양성혜 on 2022/07/26.
//

import UIKit
import FSCalendar

class ViewController: UIViewController {
    
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calenderView: FSCalendar!
    @IBOutlet weak var dayLabel: UILabel!
    
    var doneButton:UIBarButtonItem?
    var tasks = [Task]() {
        didSet {
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks()
        self.setupCalender()
    }
    
    @objc func doneButtonTap(){
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false, day: "00년00월00일")
            self?.tasks.append(task)
            self?.tableView.reloadData()
        }
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField { textField in
            textField.placeholder = "할 일을 입력해주세요."
        }
        self.present(alert,animated: true,completion: nil)
    }
    
    func saveTasks(){
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done,
                "day": $0.day
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTasks(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String:Any]] else { return }
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else {return nil}
            guard let day = $0["day"] as? String else {return nil}
            return Task(title: title, done: done, day: day)
        }
    }
    
    func setupCalender(){
        self.calenderView.delegate = self
        self.calenderView.dataSource = self
        
        calenderView.scope = .month  // 월간
        calenderView.locale = Locale(identifier: "ko_KR")
        
        calenderView.scrollEnabled = true   // 가능
        calenderView.scrollDirection = .horizontal //가로
        
        calenderView.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)
        calenderView.appearance.selectionColor = UIColor(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)
        calenderView.appearance.todayColor = UIColor(red: 188/255, green: 224/255, blue: 253/255, alpha: 1)
        
        
        // 헤더 폰트 설정
        calenderView.appearance.headerTitleFont = UIFont(name: "NotoSansKR-Medium", size: 16)

        // Weekday 폰트 설정
        calenderView.appearance.weekdayFont = UIFont(name: "NotoSansKR-Regular", size: 14)

        // 각각의 일(날짜) 폰트 설정 (ex. 1 2 3 4 5 6 ...)
        calenderView.appearance.titleFont = UIFont(name: "NotoSansKR-Regular", size: 14)
        
        // 헤더의 날짜 포맷 설정
        calenderView.appearance.headerDateFormat = "YYYY년 MM월"

        // 헤더의 폰트 색상 설정
        calenderView.appearance.headerTitleColor = UIColor.link

        // 헤더의 폰트 정렬 설정
        // .center & .left & .justified & .natural & .right
        calenderView.appearance.headerTitleAlignment = .center

        // 헤더 높이 설정
        calenderView.headerHeight = 45

        // 헤더 양 옆(전달 & 다음 달) 글씨 투명도
        calenderView.appearance.headerMinimumDissolvedAlpha = 0.0
        
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if self.tasks.isEmpty {
            self.doneButtonTap()
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ViewController: FSCalendarDelegate, FSCalendarDataSource {
    
}

