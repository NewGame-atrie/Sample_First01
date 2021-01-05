//
//  ViewController.swift
//  First01
//
//  Created by 北田菜穂 on 2020/12/27.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //serchBarのdelegate通知先を設定
        searchText.delegate = self
        
        //入力のヒントとなるプレースホルダーを設定
        searchText.placeholder = "お菓子の名前を入力してください"
        
        //TableViewのdatasourceを設定
        tableView.dataSource = self
        
        //TableViewのdelegataを設定
        tableView.delegate = self
    }

    //お菓子のリスト（タプル配列）
    var okashiList : [(name:String, maker:String, link:URL, image:URL)] = []
    
    //検索ボタンをクリック時に
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            //デバックエリアに出力
            print(searchWord)
            //入力されていたらお菓子を検索
            searchOkashi(keyword: searchWord)
        }
    }
    
    //JSONのitem内のデータ構造
    struct ItemJson: Codable {
        //お菓子の名称
        let name: String?
        //メーカー
        let maker: String?
        //掲載URL
        let url: URL?
        //画像URL
        let image: URL?
    }
    
    //JSONデータ構造
    struct ResultJson: Codable {
        //複数要素
        let item: [ItemJson]?
    }
    
    //キーワードからお菓子を検索して、一覧表示するメソッド
    func searchOkashi(keyword: String) {
        //お菓子の検索きーわーどをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return
        }
        
        //リクエストURLの組み立て
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        print(req_url)
        
        //リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        //データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        //リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data , response , error) in
            //セッション終了
            session.finishTasksAndInvalidate()
            //do try catchでエラーハンドリング
            do {
                //JSONDecodarのインスタンスを取得
                let decoder = JSONDecoder()
                //受け取ったJSONデータをパースして格納
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                //お菓子の情報が取得できているか確認
                if let items = json.item {
                    //お菓子のリストを初期化
                    self.okashiList.removeAll()
                    //取得しているお菓子の数だけ処理
                    for item in items {
                        //お菓子の名称、メーカー名、掲載URL、画像URLをアンラップ
                        if let name = item.name , let maker = item.maker , let link = item.url , let image = item.image {
                            //１つの歌詞をタプルでまとめて管理する
                            let okashi = (name,maker,link,image)
                            //お菓子の配列へ追加
                            self.okashiList.append(okashi)
                        }
                    }
                    
                    //TableViewを更新
                    self.tableView.reloadData()
                    
                    if let okashidbg = self.okashiList.first {
                        print("--------------------")
                        print("okashiList[0] = \(okashidbg)")
                    }
                }
                
            } catch {
                //エラー処理
                print("エラーが発生しました")
            }
        })
        //ダウンロード開始
        task.resume()
    }
    
    //Cellに値を設定するdatasourceメソッド、必ず記述
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //お菓子リストの総数
        return okashiList.count
    }

    //Cellに値を設定するdatasourceメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行う、Cellオブジェクト１行を取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        //webDateにお菓子のデータを代入
        let webData = okashiList[indexPath.row]
        //お菓子のタイトルを設定
        cell.textLabel?.text = webData.name
        //お菓子の画像を取得
        if let imageData = try? Data(contentsOf: webData.image) {
            //正常に取得できた場合はUIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        //設定済のCellオブジェクトを画像に反映
        return cell
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "showWebPage" {
            
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let webData = okashiList[indexPath.row]
            (segue.destination as! DetailViewController).data = webData
        }
//            nextView.name = webData.name
//            nextView.link = webData.link
        }
    }
}

