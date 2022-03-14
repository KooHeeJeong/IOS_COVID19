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
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicatorView.startAnimating()
        self.fetchCovidOverview(completionHandler: { [weak self] result in
            guard let self = self else { return }
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
            self.labelStackView.isHidden = false
            self.pieChartView.isHidden = false
            switch result {
            case let .success(result):
                //참고 - Alamofire에서는 response 데이터 메소드를 completionHandler는 메인스레드에서 동작하기때문에
                //따로 DispatchQueue.main 를 안 만들어줘도 된다.
                self.configureStackView(koreaCovidOverview: result.korea)
                
                let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
                self.configureChartView(covidOverViewList: covidOverviewList)
                
            case let .failure(error):
                debugPrint("error \(error)")
            }
            
        })
        
    }
    
    //총 확진자
    //신규 확진자
    func configureStackView(koreaCovidOverview : CovidOverView) {
        self.totalCaseLabel.text = "\(koreaCovidOverview.totalCase)명"
        self.newCaseLabel.text = "\(koreaCovidOverview.newCase)명"
    }
    
    func makeCovidOverviewList(cityCovidOverview: CityCovidOverView) -> [CovidOverView] {
        return [
            cityCovidOverview.seoul,
            cityCovidOverview.busan,
            cityCovidOverview.daegu,
            cityCovidOverview.incheon,
            cityCovidOverview.gwangju,
            cityCovidOverview.daejeon,
            cityCovidOverview.ulsan,
            cityCovidOverview.sejong,
            cityCovidOverview.gyeonggi,
            cityCovidOverview.chungbuk,
            cityCovidOverview.chungnam,
            cityCovidOverview.gyeongbuk,
            cityCovidOverview.gyeongnam,
            cityCovidOverview.jeju,
            
        ]
    }
    
    //PieChatView 를 만들어주는 곳
    //Param으로 CovidOverView 배열을 받아온다.
    func configureChartView(covidOverViewList: [CovidOverView]) {
        self.pieChartView.delegate = self
        let entries = covidOverViewList.compactMap{ [weak self] overview -> PieChartDataEntry? in
            guard let self = self else { return nil }
            return PieChartDataEntry(
                value: self.removeFormatString(string: overview.newCase),
                label: overview.countryName,
                data: overview
            )
        }
        let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황")
        dataSet.sliceSpace = 1
        dataSet.entryLabelColor = .black
        dataSet.valueTextColor = .black
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.3
        
        //Colors 배열에 여러 색상을 넣어주면 pieChart에 여러 색상으로 표시가 된다.
        dataSet.colors = ChartColorTemplates.vordiplom()
        + ChartColorTemplates.joyful()
        + ChartColorTemplates.liberty()
        + ChartColorTemplates.pastel()
        + ChartColorTemplates.material()
        
        //PieChartView 에 dataSet을 넣어줌.
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        
        //PieChartView spin을 주어 회전을 시켜준다.
        self.pieChartView.spin(duration: 0.3, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 80)
    }
    
    //String 값에 100,000 이런식으로 되어있는 것을 formatter 을 사용하여
    //순수 number로 format 해줌.
    func removeFormatString(string : String ) -> Double{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    
    //요청에 성공하면 CityCovidOverView 열거형 연관값으로 전달
    //요청에 실패하면 Error 열거형 연관값으로 전달
    //Void - Return값이 없음
    //@escaping 이란?
    //함수내에서 비동기 작업을 하고 비동기 작업의 결과를 반환받기 위해서 사용한다.
    //그렇지 않으면 비동기작업의 함수가 끝나면 결과값을 반환 받을 수 없다.
    func fetchCovidOverview(completionHandler: @escaping (Result<CityCovidOverView, Error>) -> Void) {
        let url = "https://api.corona-19.kr/korea/country/new/"
        
        //딕셔너리 형태로 넣어준다.
        //딕셔너리 형태 = [Key : Value]
        let param = [
            "serviceKey" : "65KONQCdotEYgfUVx1reul8m3ZbIFTqhW"
        ]
        
        //실행 지연을 주기위해 asyncAfter 을 이용하여 1초 뒤에 실행 하도록
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            
            //Alamofire 사용
            AF.request(url, method: .get, parameters: param)
                .responseData(completionHandler: { response in
                    switch response.result {
                    case let .success(data):
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(CityCovidOverView.self, from: data)
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
    
}

extension ViewController: ChartViewDelegate {
    //차트에서 항목을 선택하였을 때 호출되는 메소드
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let covidDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CovidDetailViewController") as? CovidDetailViewController else { return }
        guard let covidOverview = entry.data as? CovidOverView else { return }
        covidDetailViewController.covidOverview = covidOverview
        self.navigationController?.pushViewController(covidDetailViewController, animated: true)
    }
}

