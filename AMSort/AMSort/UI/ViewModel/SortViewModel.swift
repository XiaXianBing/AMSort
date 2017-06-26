//
//  SortViewModel.swift
//  AMSort
//
//  Created by XiaXianBing on 2017-5-2.
//  Copyright © 2017年 XiaXianBing. All rights reserved.
//

import UIKit
import RxSwift

class SortViewModel: AMViewModel {
	var model: SortModel?
	
	
	// MARK: -
	// MARK: Orrvide
	
	override func initViewModel() {
		model = SortModel.init()
	}
	
	let resetSubject = PublishSubject<Void>()
	let invalidSubject = PublishSubject<Void>()
	let sortSubject = PublishSubject<Void>()
	let refreshSbuject = PublishSubject<(Int)>()
	let exchangeSubject = PublishSubject<(UIView, UIView)>()
}
