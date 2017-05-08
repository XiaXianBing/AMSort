//
//  SortViewController.swift
//  AMSort
//
//  Created by XiaXianBing on 2017-5-2.
//  Copyright © 2017年 XiaXianBing. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SortViewController: AMViewController
{
	@IBOutlet var resetButtonItem: UIBarButtonItem!
	@IBOutlet var sortButtonItem: UIBarButtonItem!
	@IBOutlet var segmentControl: UISegmentedControl!
	@IBOutlet var subSegmentControl: UISegmentedControl!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var barChartView: UIView!
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
	
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
	
	
	// MARK: -
	// MARK: Lazy Methods
	
	lazy var viewModel: SortViewModel = {
		var viewModel = SortViewModel.init()
		return viewModel
	}()
	
	
	// MARK: -
	// MARK: Orrvide Methods
	
	override func initView()
	{
		if (viewModel.model?.barViews == nil) {
			viewModel.model?.barViews = NSMutableArray.init(capacity: BarCount)
			for _ in 0 ..< BarCount {
				let view = UIView.init()
				view.backgroundColor = UIColor.blue
				barChartView.addSubview(view)
				viewModel.model?.barViews?.add(view)
			}
		}
	}
	
	override func bindViewModel()
	{
		segmentControl.rx.value
			.subscribe(onNext: { _ in
				let mode: SortMode = SortMode(rawValue: self.segmentControl.selectedSegmentIndex)!
				switch mode {
				case .insert:
					self.subSegmentControl.selectedSegmentIndex = 0
					self.subSegmentControl.setTitle("直接插入", forSegmentAt: 0)
					self.subSegmentControl.setTitle("希尔排序", forSegmentAt: 1)
					self.subSegmentControl.isHidden = false
					break
					
				case .select:
					self.subSegmentControl.selectedSegmentIndex = 0
					self.subSegmentControl.setTitle("简单选择", forSegmentAt: 0)
					self.subSegmentControl.setTitle("堆排序", forSegmentAt: 1)
					self.subSegmentControl.isHidden = false
					break
					
				case .swap:
					self.subSegmentControl.selectedSegmentIndex = 0
					self.subSegmentControl.setTitle("冒泡排序", forSegmentAt: 0)
					self.subSegmentControl.setTitle("快速排序", forSegmentAt: 1)
					self.subSegmentControl.isHidden = false
					break
					
				case .merge, .radix:
					self.subSegmentControl.isHidden = true
					break
				}
				
				self.viewModel.resetSubject.onNext()
			})
			.addDisposableTo(disposeBag)
		
		subSegmentControl.rx.value
			.subscribe(onNext: { _ in
				self.viewModel.resetSubject.onNext()
			})
			.addDisposableTo(disposeBag)
		
		resetButtonItem.rx.tap
			.subscribe(onNext: { _ in
				self.viewModel.resetSubject.onNext()
			})
			.addDisposableTo(disposeBag)
		
		sortButtonItem.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.viewModel.sortSubject.onNext()
			})
			.addDisposableTo(disposeBag)
		
		viewModel.resetSubject
			.subscribe(onNext: { _ in
				self.timeLabel.text = ""
				self.viewModel.invalidSubject.onNext()
				self.viewModel.model?.values?.removeAllObjects()
				
				let maxHeight: Int = Int(self.barChartView.bounds.size.height)
				self.viewModel.model?.barViews?.enumerateObjects({ (bar, index, stop) in
					let height = 20 + arc4random_uniform(UInt32(maxHeight - 20))
					self.viewModel.model?.values?.add(Int(height))
					if (bar as AnyObject).isKind(of: UIView.self) {
						let barView = bar as! UIView
						barView.frame = CGRect(x: index * (BarWidth + BarMargin), y: Int(self.barChartView.bounds.size.height) - Int(height), width: BarWidth, height: Int(height))
					}
				})
			})
			.addDisposableTo(disposeBag)
		
		viewModel.invalidSubject
			.subscribe(onNext: { _ in
				if (self.viewModel.model?.timer) != nil {
					self.viewModel.model?.timer?.invalidate()
					self.viewModel.model?.timer = nil
				}
			})
			.addDisposableTo(disposeBag)
		
		viewModel.sortSubject
			.subscribe(onNext: { [weak self] in
				self?.viewModel.model?.semaphore = DispatchSemaphore(value: 0)
				
				//定时器信号
				let nowTime: TimeInterval = NSDate.init().timeIntervalSince1970
				self?.viewModel.model?.timer = Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true, block: { (timer) in
					//发出信号量, 唤醒排序线程
					self?.viewModel.model?.semaphore?.signal()
					//更新计时
					let interval = NSDate.init().timeIntervalSince1970 - nowTime
					self?.timeLabel.text = String.init(format: "耗时(秒):%2.3f", interval)
				})
				RunLoop.current.add((self?.viewModel.model?.timer)!, forMode: RunLoopMode.commonModes)
				
				DispatchQueue.global().async {
					let result: AMComparisonResult = { (object1, object2) in
						//模拟进行比较所需的耗时
						self?.viewModel.model?.semaphore?.wait()
						let view1 = object1 as! UIView
						let view2 = object2 as! UIView
						if view1.frame.size.height == view2.frame.size.height {
							return ComparisonResult.orderedSame
						}
						return (view1.frame.size.height < view2.frame.size.height) ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending
					}
					
					let refresh: AMRefreshCallback = { index in
						self?.viewModel.model?.semaphore?.wait()
						self?.viewModel.refreshSbuject.onNext(index)
					}
					
					let callback: AMExchangeCallback = { (object1, object2) in
						self?.viewModel.exchangeSubject.onNext((object1 as! UIView, object2 as! UIView))
					}
					
					let mode: SortMode = SortMode(rawValue: (self?.segmentControl.selectedSegmentIndex)!)!
					switch mode {
					case .insert:
						let submode: SortInsertMode = SortInsertMode(rawValue: (self?.subSegmentControl.selectedSegmentIndex)!)!
						switch submode {
						case .insert:
							self?.viewModel.model?.barViews?.insertSort(comparator: result, callback: callback)
							break
							
						case .shell:
							self?.viewModel.model?.barViews?.shellSort(comparator: result, callback: callback)
							break
						}
						break
						
					case .select:
						let submode: SortSelectMode = SortSelectMode(rawValue: (self?.subSegmentControl.selectedSegmentIndex)!)!
						switch submode {
						case .select:
							self?.viewModel.model?.barViews?.selectSort(comparator: result, callback: callback)
							break
							
						case .heap:
							self?.viewModel.model?.barViews?.heapSort(comparator: result, callback: callback)
							break
						}
						break
						
					case .swap:
						let submode: SortSwapMode = SortSwapMode(rawValue: (self?.subSegmentControl.selectedSegmentIndex)!)!
						switch submode {
						case .bubble:
							self?.viewModel.model?.barViews?.bubbleSort(comparator: result, callback: callback)
							break
							
						case .quick:
							self?.viewModel.model?.barViews?.quickSort(comparator: result, callback: callback)
							break
						}
						break
						
					case .merge:
						self?.viewModel.model?.barViews?.mergeSort(comparator: result, callback: callback)
						break
						
					case .radix:
						self?.viewModel.model?.barViews?.radixSort(callback: refresh)
						break
					}
					
					self?.viewModel.invalidSubject.onNext()
				}
			})
			.addDisposableTo(disposeBag)
		
		viewModel.refreshSbuject
			.subscribe(onNext: { index in
				DispatchQueue.main.async {
					let view = self.viewModel.model?.barViews?.object(at: index) as! UIView
					view.frame = CGRect.init(x: CGFloat(index * (BarWidth + BarMargin)), y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
				}
			})
			.addDisposableTo(disposeBag)
		
		viewModel.exchangeSubject
			.subscribe(onNext: { (view1, view2) in
				DispatchQueue.main.async {
					var frame1 = view1.frame
					var frame2 = view2.frame
					frame1.origin.x = view2.frame.origin.x
					frame2.origin.x = view1.frame.origin.x
					view1.frame = frame1
					view2.frame = frame2
				}
			})
			.addDisposableTo(disposeBag)
	}
	
	override func initData()
	{
		viewModel.resetSubject.onNext()
	}
	
	override func refreshView()
	{
	}
	
	override func refreshData()
	{
	}
	
	
	// MARK: -
	// MARK: Required Methods
	
}

