//
//  TipsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ESPullToRefresh
import Kingfisher

class TipsViewController: BaseViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var tipsTableView: UITableView!

	var tipsArray = [Tip]()
	var selectedTip: Tip?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		tipsTableView.dataSource = self
		tipsTableView.delegate = self
        tipsTableView.emptyDataSetSource = self;
        tipsTableView.emptyDataSetDelegate = self;


		tipsTableView.es_addPullToRefresh {

			/// Do anything you want...
			/// ...
			self.runTipsInfoRequest()
			/// Stop refresh when your job finished, it will reset refresh footer if completion is true

			/// Set ignore footer or not
			// self?.teamTableView.es_stopPullToRefresh(completion: true, ignoreFooter: false)
		}
        tipsTableView.es_startPullToRefresh()

	}
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No tips"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func runTipsInfoRequest() {

		
		provider.request(.TipsInfo()) { result in
			switch result {
			case let .Success(moyaResponse):

				do {
					try moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
						print("wrong json format")
                        self.tipsTableView.es_stopPullToRefresh(completion: true)
						SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
						return
					}
					self.tipsArray.removeAll()
					for tip in json {
						let newTip = Tip(title: tip["title"] as? String, cover: tip["cover"] as? String, url: tip["url"] as? String)
						self.tipsArray.append(newTip)
					}

					self.tipsTableView.reloadData()
					SVProgressHUD.dismiss()
					self.tipsTableView.es_stopPullToRefresh(completion: true)

				}
				catch {

					guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
						item = json[0] as? [String: AnyObject],
						message = item["message"] as? String else {
							SVProgressHUD.showErrorWithStatus(Helper.ErrorKey.kSomethingWentWrong)
							self.tipsTableView.es_stopPullToRefresh(completion: true)
							return
					}
					SVProgressHUD.showErrorWithStatus("\(message)")
					self.tipsTableView.es_stopPullToRefresh(completion: true)
				}

			case let .Failure(error):
				guard let error = error as? CustomStringConvertible else {
					break
				}
				print(error.description)
				SVProgressHUD.showErrorWithStatus("\(error.description)")
				self.tipsTableView.es_stopPullToRefresh(completion: true)

			}
		}

	}

	func loadImage(indexPath: NSIndexPath, tip: Tip) {

		ImageDownloader(name: "imageDownloader").downloadImageWithURL(NSURL(string: tip.cover)!, progressBlock: { (receivedSize: Int64, expectedSize: Int64) -> Void in
			// progression tracking code

			}, completionHandler: { (image: Kingfisher.Image?, error: NSError?, imageURL: NSURL?, originalData: NSData?) -> Void in

			print("image \(image)  url \(NSURL(string:tip.cover))  error \(error)")

			if image != nil {
				let localImage: UIImage = image!

				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					tip.image = localImage
					self.tipsTableView.beginUpdates()
					self.tipsTableView.reloadRowsAtIndexPaths(
						[indexPath],
						withRowAnimation: .None)
					self.tipsTableView.endUpdates()
				})
			}

		})

	}

	func readMoreButtonTapped(sender: ButtonWithIndexPath) {
		selectedTip = tipsArray[(sender.indexPath?.row)!]
		performSegueWithIdentifier(Helper.SegueKey.kToTipDetailsViewController, sender: self)
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		if segue.identifier == Helper.SegueKey.kToTipDetailsViewController {
			let viewController: TipDetailsViewController = segue.destinationViewController as! TipDetailsViewController
			if (selectedTip != nil) {
				viewController.currentTip = selectedTip
			}

		}

	}

}

// MARK: - UITableViewDataSource
extension TipsViewController: UITableViewDataSource {

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 300
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tipsArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let tip: Tip = tipsArray[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TipTableViewCell

		cell.titleLabel.text = tip.title
		if tip.cover.characters.count > 0 && tip.image == nil {
			loadImage(indexPath, tip: tip)
		} else {
			cell.setPostedImage(tip.image)
		}
		cell.readMoreButton.indexPath = indexPath
		cell.readMoreButton.addTarget(self, action: #selector(readMoreButtonTapped(_:)), forControlEvents: .TouchUpInside)

		return cell
	}

}
// MARK: - UITableViewDelegate
extension TipsViewController: UITableViewDelegate {

}

