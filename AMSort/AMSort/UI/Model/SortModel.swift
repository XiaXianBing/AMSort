//
//  SortModel.swift
//  AMSort
//
//  Created by XiaXianBing on 2017-5-2.
//  Copyright © 2017年 XiaXianBing. All rights reserved.
//

import UIKit

enum SortMode: Int {
	case insert = 0		//插入排序
	case select = 1		//选择排序
	case swap = 2		//交换排序
	case merge = 3		//归并排序
	case radix = 4		//基数排序
}

enum SortInsertMode: Int {
	case insert = 0		//直接插入排序
	case shell = 1		//希尔排序
}

enum SortSelectMode: Int {
	case select = 0		//简单选择排序
	case heap = 1		//堆排序
}

enum SortSwapMode: Int {
	case bubble = 0		//冒泡排序
	case quick = 1		//快速排序
}


let BarWidth: Int = 2
let BarMargin: Int = 1
let BarCount: Int = Int((UIScreen.main.bounds.size.width - 2 * 24.0)/CGFloat.init(BarWidth + BarMargin))

class SortModel: AMModel {
	var values: NSMutableArray?
	var barViews: NSMutableArray?
	
	var timer: Timer?
	var semaphore: DispatchSemaphore?
	
	
	// MARK: -
	// MARK: Orrvide
	
	override func initModel() {
	}
}
