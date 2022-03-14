//
//  CovidDetailViewController.swift
//  COVID19
//
//  Created by 구희정 on 2022/03/13.
//

import UIKit

class CovidDetailViewController: UITableViewController {

    @IBOutlet weak var newCaseCell: UITableViewCell!
    @IBOutlet weak var totalCaseCell: UITableViewCell!
    @IBOutlet weak var recoverdCell: UITableViewCell!
    @IBOutlet weak var deathCell: UITableViewCell!
    @IBOutlet weak var percentageCell: UITableViewCell!
    @IBOutlet weak var overseasInflowCell: UITableViewCell!
    @IBOutlet weak var regionalOutbreakCell: UITableViewCell!
    
    var covidOverview : CovidOverView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView() {
        guard let covidOverview = covidOverview else { return }
        self.title = covidOverview.countryName
        self.newCaseCell.detailTextLabel?.text = covidOverview.newCase
        self.totalCaseCell.detailTextLabel?.text = covidOverview.totalCase
        self.recoverdCell.detailTextLabel?.text = covidOverview.recovered
        self.deathCell.detailTextLabel?.text = covidOverview.death
        self.percentageCell.detailTextLabel?.text = covidOverview.percentage
        self.overseasInflowCell.detailTextLabel?.text = covidOverview.newFcase
        self.regionalOutbreakCell.detailTextLabel?.text = covidOverview.newCcase
    }
}
