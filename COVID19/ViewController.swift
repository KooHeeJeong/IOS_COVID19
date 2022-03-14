//
//  ViewController.swift
//  COVID19
//
//  Created by 구희정 on 2022/03/13.
//
import Alamofire
import UIKit
import Charts


class ViewController: UIViewController {
    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var newCaseLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCovidOverview(completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(result):
                debugPrint("success \(result)")
                
            case let .failure(error):
                debugPrint("error \(error)")
            }
            
        })
        
    }
    
    //요청에 성공하면 CityCovidOverView 열거형 연관값으로 전달
    //요청에 실패하면 Error 열거형 연관값으로 전달
    //Void - Return값이 없음
    //@escaping 이란?
    //함수내에서 비동기 작업을 하고 비동기 작업의 결과를 반환받기 위해서 사용한다.
    //그렇지 않으면 비동기작업의 함수가 끝나면 결과값을 반환 받을 수 없다.
    func fetchCovidOverview(completionHandler: @escaping (Result<CityCovidOverVIew, Error>) -> Void) {
        let url = "https://api.corona-19.kr/korea/country/new/"
        
        //딕셔너리 형태로 넣어준다.
        //딕셔너리 형태 = [Key : Value]
        let param = [
            "serviceKey" : "65KONQCdotEYgfUVx1reul8m3ZbIFTqhW"
        ]
        
        AF.request(url, method: .get, parameters: param)
            .responseData(completionHandler: { response in
                switch response.result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(CityCovidOverVIew.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        completionHandler(.failure(error))
                    }
                    
                case let .failure(error):
                    completionHandler(.failure(error))
                }
                
            })
    }


}

