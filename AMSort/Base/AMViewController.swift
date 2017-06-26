//
//  AMViewController.swift
//  AMSort
//
//  Created by XiaXianBing on 2017-5-2.
//  Copyright © 2017年 XiaXianBing. All rights reserved.
//

import UIKit
import RxSwift

class AMViewController: UIViewController {
	var disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initView()
		bindViewModel()
		initData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshView()
		refreshData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: -
	// MARK: Orrvide
	
	func initView() {
	}
	
	func bindViewModel() {
	}
	
	func initData() {
	}
	
	func refreshView() {
	}
	
	func refreshData() {
	}
	
	
	// MARK: -
	// MARK: Required
}
