//
//  AMSortAlgorithm.swift
//  AMSort
//
//  Created by XiaXianBing on 2017-5-3.
//  Copyright © 2017年 XiaXianBing. All rights reserved.
//

import UIKit
import Foundation

public typealias AMComparisonResult = (Any, Any) -> ComparisonResult
public typealias AMRefreshCallback = (Int) -> Void
public typealias AMExchangeCallback = (Any, Any) -> Void

extension NSMutableArray {
	public func refresh(index: Int, callback: AMRefreshCallback?) {
		if callback != nil {
			callback!(index)
		}
	}
	
	public func exchange(index: Int, toIndex: Int, callback: AMExchangeCallback?) {
		let temp = self.object(at: index)
		self.replaceObject(at: index, with: self.object(at: toIndex))
		self.replaceObject(at: toIndex, with: temp)
		if callback != nil {
			callback!(temp, self.object(at: index))
		}
	}
	
	
	// MARK: -
	// MARK: 插入排序
	
	// MARK: 直接插入
	// MARK: 原理: 插入排序就是每一步都将一个待排数据按其大小插入到已经排序的数据中的适当位置, 直到全部插入完毕. 插入排序方法分直接插入排序和折半插入排序两种.
	public func insertSort(comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		for i in stride(from: 1, to: self.count, by: +1) {
			for j in stride(from: i, to: 0, by: -1) {
				if comparator(self.object(at: j), self.object(at: j-1)) == ComparisonResult.orderedAscending {
					self.exchange(index: j, toIndex: j-1, callback: callback)
				}
			}
		}
	}
	
	
	// MARK: 希尔排序
	// MARK: 原理:
	public func shellSort(comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		var subcount = self.count/2
		while subcount > 0 {
			for i in 0..<subcount {
				self.shellInsertSort(start: i, count: subcount, comparator: comparator, callback: callback)
			}
			subcount = subcount/2
		}
	}
	
	private func shellInsertSort(start: Int, count: Int, comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		for i in stride(from: start+count, to: self.count, by: +count) {
			let current = self.object(at: i)
			var index = i
			while index >= count && comparator(self.object(at: index - count), current) == ComparisonResult.orderedDescending {
				self.exchange(index: index, toIndex: index - count, callback: callback)
				index -= count
			}
		}
	}
	
	
	// MARK: -
	// MARK: 选择排序
	
	// MARK: 简单选择
	// MARK: 原理: 在排序的一组数中, 选出最小的一个数与第1个位置的数交换; 然后在剩下的数当中再找最小的与第2个位置的数交换, 依次类推, 直到第n-1个元素(倒数第二个数)和第n个元素(最后一个数)比较为止.
	public func selectSort(comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		for i in stride(from: 0, to: self.count-1, by: +1) {
			for j in stride(from: i+1, to: self.count, by: +1) {
				if comparator(self.object(at: i), self.object(at: j)) == ComparisonResult.orderedDescending {
					self.exchange(index: i, toIndex: j, callback: callback)
				}
			}
		}
	}
	
	
	// MARK: 堆排序
	// MARK: 原理: 堆排序是一种树形选择排序，是对直接选择排序的有效改进。
	public func heapSort(comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		self.insert(NSNull.init(), at: 0)
		for i in stride(from: self.count/2, to: 0, by: -1) {
			self.heapSortSink(index: i, bottom: self.count-1, comparator: comparator, callback: callback)
		}
		for i in stride(from: self.count-1, to: 1, by: -1) {
			self.exchange(index: 1, toIndex: i, callback: callback)
			self.heapSortSink(index: 1, bottom: i-1, comparator: comparator, callback: callback)
		}
		self.removeObject(at: 0)
	}
	
	private func heapSortSink(index: Int, bottom: Int, comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		var temp = index
		var i = temp * 2
		while i < bottom {
			if i < bottom && comparator(self.object(at: i), self.object(at: i+1)) == ComparisonResult.orderedAscending {
				i = i + 1
			}
			if comparator(self.object(at: i), self.object(at: temp)) == ComparisonResult.orderedAscending {
				i = i * 2
				break
			}
			self.exchange(index: temp, toIndex: i, callback: callback)
			temp = i
			i = i * 2
		}
	}
	
	
	// MARK: -
	// MARK: 交换排序
	// MARK: 交换排序分冒泡排序、快速排序
	
	// MARK: 冒泡排序
	// MARK: 原理: 临近的数字两两进行比较, 按照从小到大的顺序进行交换, 这样一趟过去后, 最大的数字被交换到了最后一位, 然后再从头开始进行两两比较交换, 直到倒数第二位时结束.
	public func bubbleSort(comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		var isMoved: Bool = false
		for i in stride(from: self.count - 1, to: 0, by: -1) {
			isMoved = false
			for j in stride(from: 0, to: i, by: +1) {
				if comparator(self.object(at: j), self.object(at: j+1)) == ComparisonResult.orderedDescending {
					self.exchange(index: j, toIndex: j+1, callback: callback)
					isMoved = true
				}
			}
			
			if !isMoved {
				break
			}
		}
	}
	
	
	// MARK: 快速排序
	// MARK: 原理: 通过一趟扫描将要排序的数据分割成独立的两部分, 其中一部分的所有数据都比另外一部分的所有数据都要小, 然后再按此方法对这两部分数据分别进行快速排序, 整个排序过程可以递归进行, 以此达到整个数据变成有序序列.
	public func quickSort(comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		self.quickSort(start: 0, end: self.count - 1, comparator: comparator, callback: callback)
	}
	
	private func quickSort(start: Int, end: Int, comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		if start >= end {
			return
		}
		
		let temp = self.object(at: start)
		var i: Int = start
		var j: Int = end
		
		while i < j {
			while (i < j) && (comparator(self.object(at: j), temp) != ComparisonResult.orderedAscending) {
				j = j - 1
			}
			if i < j {
				self.exchange(index: i, toIndex: j, callback: callback)
				i = i + 1
			}
			
			while (i < j) && (comparator(self.object(at: i), temp) != ComparisonResult.orderedDescending) {
				i = i + 1
			}
			if i < j {
				self.exchange(index: i, toIndex: j, callback: callback)
				j = j - 1
			}
		}
		self.quickSort(start: start, end: i-1, comparator: comparator, callback: callback)
		self.quickSort(start: i+1, end: end, comparator: comparator, callback: callback)
	}
	
	
	// MARK: -
	// MARK: 归并排序
	// MARK: 原理: 归并排序法是将两个(或两个以上)有序表合并成一个新的有序表, 即把待排序序列分为若干个子序列, 每个子序列是有序的, 然后再把有序子序列合并为整体有序序列.
	public func mergeSort(comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		self.mergeSort(start: 0, end: self.count - 1, comparator: comparator, callback: callback)
	}
	
	private func mergeSort(start: Int, end: Int, comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		if start < end {
			self.mergeSort(start: start, end: (start + end)/2, comparator: comparator, callback: callback)
			self.mergeSort(start: (start + end)/2 + 1, end: end, comparator: comparator, callback: callback)
			self.merge(start: start, center: (start + end)/2, end: end, comparator:comparator, callback:callback)
		}
	}
	
	private func merge(start: Int, center: Int, end: Int, comparator: AMComparisonResult, callback: AMExchangeCallback?) -> Void {
		var i = start
		var j = center + 1
		while i < j && j <= end {
			if comparator(self.object(at: i), self.object(at: j)) == ComparisonResult.orderedDescending {
				var temp = j
				for k in stride(from: j-1, through: i, by: -1) {
					if comparator(self.object(at: k), self.object(at: temp)) == ComparisonResult.orderedDescending {
						self.exchange(index: k, toIndex: temp, callback: callback)
						temp = k
					}
					else {
						break
					}
				}
				i = temp
				j = j + 1
			}
			i = i + 1
		}
	}
	
	
	// MARK: -
	// MARK: 基数排序
	// MARK: 原理: 将阵列分到有限数量的桶子里, 每个桶子再个别排序(有可能再使用别的排序算法或是以递回方式继续使用桶排序进行排序).
	public func radixSort(callback: AMRefreshCallback?) -> Void {
		let radix = 10
		var done = false
		var index: Int
		var digit = 1
		
		while !done {
			done = true
			
			var buckets: [[Any]] = []
			for _ in 1...radix {
				buckets.append([])
			}
			
			for item in self {
				if ((item as AnyObject).isKind(of: UIView.self)) {
					let view = item as! UIView
					let number = Int(view.frame.size.height)
					index = number / digit
					buckets[index % radix].append(item)
					if done && index > 0 {
						done = false
					}
				}
			}
			
			var i = 0
			for j in 0..<radix {
				let bucket = buckets[j]
				for item in bucket {
					self[i] = item
					self.refresh(index: i, callback: callback)
					i = i + 1
				}
			}
			digit = digit * radix
		}
	}
}
