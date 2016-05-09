//
//  ShogibanKit.swift
//  ShogibanKit
//
//	Copyright (c) 2016 Kaz Yoshikawa
//
//	This software may be modified and distributed under the terms
//	of the MIT license.  See the LICENSE file for details.
//

import Foundation



class KibanScanner : NSObject {

	var scanner: NSScanner

	init(string: String) {
		scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = NSCharacterSet.whitespaceCharacterSet()
	}
	
	func scan先手後手() -> 先手後手型? {
		for (key, value) in 先手後手型.記号表 {
			var string: NSString? = nil
			if scanner.scanString(key, intoString: &string) {
				return value
			}
		}
		return nil
	}

	func scan持駒() -> 持駒型? {
		var captured = 持駒型()
		let _ = self.scan先手後手()
		scanner.scanString("持駒:", intoString: nil)
		if !scanner.scanString("なし", intoString: nil) {
			for (key, value) in 駒型.記号表 {
				var string: NSString? = nil
				var count: Int = 1
				if scanner.scanString(key, intoString: &string) {
					scanner.scanInteger(&count)
					captured[value] = count
					scanner.scanString(",", intoString: nil)
				}
			}
		}
		return captured
	}

	func scan駒面() -> 駒面型? {
		for (key, value) in 駒面型.記号表 {
			if scanner.scanString(key, intoString: nil) {
				return value
			}
		}
		return nil
	}

	func scanSquare() -> 升型? {
		//var string: NSString? = nil
		if let 先手後手 = scan先手後手(), 駒面 = scan駒面() {
			return 升型(先後: 先手後手, 駒面: 駒面)
		}
		/* - following code somehow not working "　" zenkaku-space
		else if scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: "　"), intoString: nil) {
			return Square()
		} */
		else {
			return 升型()
		}
	}
	
}

let 総升数 = 81
let 総筋数 = 9
let 総段数 = 9

// MARK: - 筋型 （スジ）

public enum 筋型 : Int8, CustomStringConvertible { // right <- left
	case １, ２, ３, ４, ５, ６, ７, ８, ９

	static let 記号表: [String: 筋型] = [
		"１": .１, "２": .２, "３": .３, "４": .４, "５": .５, "６": .６, "７": .７, "８": .８, "９": .９
	]

	public init?(string: String) {
		for (key, value) in 筋型.記号表 {
			if string == key {
				self = value
				return
			}
		}
		return nil
	}
	
	public init?(_ index: Int) {
		if let 筋 = 筋型(rawValue: Int8(index)) { self = 筋 }
		else { return nil }
	}
	
	public var description: String {
		for (key, value) in 筋型.記号表 {
			if value == self {
				return key
			}
		}
		return "?"
	}
	
	public var index: Int {
		return Int(rawValue)
	}

	public static var 全筋: [筋型] {
		return [１, ２, ３, ４, ５, ６, ７, ８, ９]
	}
}

public func + (lhs: 筋型, rhs: Int) -> 筋型? {
	return 筋型(rawValue: lhs.rawValue + rhs)
}

public func - (lhs: 筋型, rhs: Int) -> 筋型? {
	return 筋型(rawValue: lhs.rawValue - rhs)
}

// MARK: - 段型

public enum 段型 : Int8, CustomStringConvertible { // top -> bottom
	case 一, 二, 三, 四, 五, 六, 七, 八, 九

	private  static let 記号表: [String: 段型] = [
		"一": .一, "二": .二, "三": .三, "四": .四, "五": .五, "六": .六, "七": .七, "八": .八, "九": .九
	]

	public init?(string: String) {
		for (key, value) in 段型.記号表 {
			if string == key {
				self = value
				return
			}
		}
		return nil
	}

	public init?(_ index: Int) {
		if let 段 = 段型(rawValue: Int8(index)) { self = 段 }
		else { return nil }
	}

	public var description: String {
		for (key, value) in 段型.記号表 {
			if value == self {
				return key
			}
		}
		return "?"
	}

	public var 陣: 陣型 {
		return 陣型(row: self)
	}

	public var index: Int {
		return Int(rawValue)
	}

	public static var 全段: [段型] {
		return [一, 二, 三, 四, 五, 六, 七, 八, 九]
	}
}

public func + (lhs: 段型, rhs: Int) -> 段型? {
	return 段型(rawValue: lhs.rawValue + rhs)
}

public func - (lhs: 段型, rhs: Int) -> 段型? {
	return 段型(rawValue: lhs.rawValue - rhs)
}


// MARK: - 陣型

public enum 陣型 : Int8 {
	case 先手, 中立, 後手

	public init(row: 段型) {
		switch row {
		case .一, .二, .三: self = .後手
		case .四, .五, .六: self = .中立
		case .七, .八, .九: self = .先手
		}
	}

	public init(先後: 先手後手型) {
		switch (先後) {
		case .先手: self = .先手
		case .後手: self = .後手
		}
	}
}


// MARK: - 位置型

public enum 位置型 : Int8, Equatable, CustomStringConvertible { // Hashable

	case １一, １二, １三, １四, １五, １六, １七, １八, １九
	case ２一, ２二, ２三, ２四, ２五, ２六, ２七, ２八, ２九
	case ３一, ３二, ３三, ３四, ３五, ３六, ３七, ３八, ３九

	case ４一, ４二, ４三, ４四, ４五, ４六, ４七, ４八, ４九
	case ５一, ５二, ５三, ５四, ５五, ５六, ５七, ５八, ５九
	case ６一, ６二, ６三, ６四, ６五, ６六, ６七, ６八, ６九

	case ７一, ７二, ７三, ７四, ７五, ７六, ７七, ７八, ７九
	case ８一, ８二, ８三, ８四, ８五, ８六, ８七, ８八, ８九
	case ９一, ９二, ９三, ９四, ９五, ９六, ９七, ９八, ９九


	static let min: Int8 = 位置型.１一.rawValue
	static let max: Int8 = 位置型.９九.rawValue + 1
	

	public init?(筋: 筋型?, 段: 段型?) {
		if let 筋 = 筋, let 段 = 段 {
			self = 位置型(rawValue: 筋.rawValue * Int8(総段数) + 段.rawValue)!
		}
		else { return nil }
	}

/*
	init?(筋: Int, 段: Int) {
		if 0...8 ~= 筋 && 0...8 ~= 段 {
			self = 位置型(rawValue: Int8(筋 * 総段数 + 段))!
		}
		else {
			return nil
		}
	}
*/

	public init?(string: String) {
		if let position = 位置型.記号表[string] {
			self = position
		}
		else {
			return nil
		}
	}
	
	private static let 記号表: [String: 位置型] = [
		"１一": .１一, "１二": .１二, "１三": .１三, "１四": .１四, "１五": .１五, "１六": .１六, "１七": .１七, "１八": .１八, "１九": .１九,
		"２一": .２一, "２二": .２二, "２三": .２三, "２四": .２四, "２五": .２五, "２六": .２六, "２七": .２七, "２八": .２八, "２九": .２九,
		"３一": .３一, "３二": .３二, "３三": .３三, "３四": .３四, "３五": .３五, "３六": .３六, "３七": .３七, "３八": .３八, "３九": .３九,
		"４一": .４一, "４二": .４二, "４三": .４三, "４四": .４四, "４五": .４五, "４六": .４六, "４七": .４七, "４八": .４八, "４九": .４九,
		"５一": .５一, "５二": .５二, "５三": .５三, "５四": .５四, "５五": .５五, "５六": .５六, "５七": .５七, "５八": .５八, "５九": .５九,
		"６一": .６一, "６二": .６二, "６三": .６三, "６四": .６四, "６五": .６五, "６六": .６六, "６七": .６七, "６八": .６八, "６九": .６九,
		"７一": .７一, "７二": .７二, "７三": .７三, "７四": .７四, "７五": .７五, "７六": .７六, "７七": .７七, "７八": .７八, "７九": .７九,
		"８一": .８一, "８二": .８二, "８三": .８三, "８四": .８四, "８五": .８五, "８六": .８六, "８七": .８七, "８八": .８八, "８九": .８九,
		"９一": .９一, "９二": .９二, "９三": .９三, "９四": .９四, "９五": .９五, "９六": .９六, "９七": .９七, "９八": .９八, "９九": .９九
	]

	static let 全位置: [位置型] = [ // 筋は右から左へ
		.１一, .１二, .１三, .１四, .１五, .１六, .１七, .１八, .１九,
		.２一, .２二, .２三, .２四, .２五, .２六, .２七, .２八, .２九,
		.３一, .３二, .３三, .３四, .３五, .３六, .３七, .３八, .３九,
		.４一, .４二, .４三, .４四, .４五, .４六, .４七, .４八, .４九,
		.５一, .５二, .５三, .５四, .５五, .５六, .５七, .５八, .５九,
		.６一, .６二, .６三, .６四, .６五, .６六, .６七, .６八, .６九,
		.７一, .７二, .７三, .７四, .７五, .７六, .７七, .７八, .７九,
		.８一, .８二, .８三, .８四, .８五, .８六, .８七, .８八, .８九,
		.９一, .９二, .９三, .９四, .９五, .９六, .９七, .９八, .９九
	]

	public var 筋: 筋型 {
		return 筋型(rawValue: Int8(Int(self.rawValue) / 総段数))!
	}

	public var 段: 段型 {
		return 段型(rawValue: Int8(Int(self.rawValue) % 総段数))!
	}
	
	public func offsetted(x: Int, _ y: Int) -> 位置型? {
		if let 筋 = 筋型(x), let 段 = 段型(y) {
			return 位置型(筋: 筋, 段: 段)
		}
		return nil
	}

	public var description: String {
		for (key, value) in 位置型.記号表 {
			if value == self {
				return key
			}
		}
		return "huh?"
	}

	public var 陣 : 陣型 {
		return self.段.陣
	}
}

public func == (lhs: 位置型, rhs: 位置型) -> Bool {
	return lhs.rawValue == rhs.rawValue
}


// MARK: - 駒型

public enum 駒型 : Int8, CustomStringConvertible {
	case 歩, 香, 桂, 銀, 金, 角, 飛, 王

	private static let 記号表: [String: 駒型] = [
		"王": .王, "飛": .飛, "角": .角, "金": .金, "銀": .銀, "桂": .桂, "香": .香, "歩": .歩,
	]

	public init?(string: String) {
		if let piece = 駒型.記号表[string] {
			self = piece
		}
		else {
			return nil
		}
	}

	public var description: String {
		for (key, value) in 駒型.記号表 {
			if value == self {
				return key
			}
		}
		return "huh?"
	}
	
	public var 駒面: 駒面型 {
		switch self {
		case 歩: return .歩
		case 香: return .香
		case 桂: return .桂
		case 銀: return .銀
		case 金: return .金
		case 角: return .角
		case 飛: return .飛
		case 王: return .王
		}
	}

	public var 成る事が可能な駒か: Bool {
		switch self {
		case 歩, 香, 桂, 銀, 角, 飛: return true
		case 金, 王: return false
		}
	}

	public var 駒数: UInt8 {
		switch self {
		case 歩: return 18
		case 香, 桂, 銀, 金: return 4
		case 角, 飛: return 2
		case 王: return 2
		}
	}

	public func 指定段に打つ事は可能か(先後 先後: 先手後手型, 段: 段型) -> Bool {
		switch (先後, self) {
		case (.先手, 歩): return 段.index > 0 // 二歩は対象としない
		case (.先手, 香): return 段.index > 0
		case (.先手, 桂): return 段.index > 1
		case (.後手, 歩): return 段.index < 8 // 二歩は対象としない
		case (.後手, 香): return 段.index < 8
		case (.後手, 桂): return 段.index < 7
		default: return true
		}
	}

}


// MARK: - 駒面型

public enum 駒面型 : Int8, CustomStringConvertible {
	case 歩, 香, 桂, 銀, 金, 角, 飛, 王
	case と, 杏, 圭, 全, 馬, 竜

	static let 記号表: [String: 駒面型] = [
		"歩": .歩,
		"香": .香,
		"桂": .桂,
		"銀": .銀,
		"金": .金,
		"角": .角,
		"飛": .飛,
		"王": .王, "玉": .王,
		"と": .と,
		"杏": .杏,
		"圭": .圭,
		"全": .全,
		"馬": .馬,
		"竜": .竜, "龍": .竜
	]

	public init?(string: String) {
		if let 駒面 = 駒面型.記号表[string] {
			self = 駒面
		}
		else {
			return nil
		}
	}
	
	public var 駒: 駒型 {
		switch self {
		case 歩, と: return .歩
		case 香, 杏: return .香
		case 桂, 圭: return .桂
		case 銀, 全: return .銀
		case 金: return .金
		case 角, 馬: return .角
		case 飛, 竜: return .飛
		case 王: return .王
		}
	}

	public var string: String {
		for (key, value) in 駒面型.記号表 {
			if self == value {
				return key
			}
		}
		return ""
	}

	public var description: String {
		return self.string
	}

	public func 移動可能なオフセット(駒面 駒面: 駒面型, 先後: 先手後手型) -> [(Int, Int)] {
		let y = 先後.direction
		assert(abs(y) == 1)

		switch 駒面 {
		case 歩: return [(0, y)]
		case 香: return []
		case 桂: return [(-1, y * 2), (1, y * 2)]
		case 銀: return [(-1, y), (0, y), (1, y),  (-1, -y), (1, -y)]
		case 角: return []
		case 飛: return []
		case 王, 馬, 竜: return [(-1, -1), (0, -1), (1, -1),  (-1, 0), (1, 0),  (-1, 1), (0, 1), (1, 1)]
		case 金, と, 杏, 圭, 全: return [(-1, -1), (0, -1), (1, -1),  (-1, 0), (1, 0),  (0, 1)]
		}
	}

	public func 移動可能なベクトル(駒面 駒面: 駒面型, 先後: 先手後手型) -> [(Int, Int)] {
		let y = 先後.direction
		assert(abs(y) == 1)

		switch 駒面 {
		case 香: return [(0, y)]
		case 角, 馬: return [(y, y), (-y, y), (y, -y), (-y, -y)]
		case 飛, 竜: return [(0, y), (0, -y), (y, 0), (-y, 0)]
		default: return []
		}
	}

	public func 成る() -> 駒面型 {
		switch self {
		case 歩: return と
		case 香: return 杏
		case 桂: return 圭
		case 銀: return 全
		case 角: return 馬
		case 飛: return 竜
		case 金, 王: fatalError("should have checked")
		case と, 杏, 圭, 全, 馬, 竜: return self
		}
	}
	
	public var 成る事は可能か: Bool {
		switch self {
		case 歩, 香, 桂, 銀, 角, 飛: return true
		case 金, 王, と, 杏, 圭, 全, 馬, 竜: return false
		}
	}

	public var 成駒か: Bool {
		switch self {
		case と, 杏, 圭, 全, 馬, 竜: return true
		default: return false
		}
	}

	
}


// MARK: - 持駒型

public struct 持駒型: Equatable, CustomStringConvertible {
	// can be dictionary but this saves some memoery foot print
	var 歩, 香, 桂, 銀, 金, 角, 飛: Int8
	
	public init(歩: Int8, 香: Int8, 桂: Int8, 銀: Int8, 金: Int8, 角: Int8, 飛: Int8) {
		self.歩 = 歩 ; self.香 = 香 ; self.桂 = 桂 ;
		self.銀 = 銀 ; self.金 = 金
		self.角 = 角 ; self.飛 = 飛
	}

	public init(歩: Int, 香: Int, 桂: Int, 銀: Int, 金: Int, 角: Int, 飛: Int) {
		self.歩 = Int8(歩) ; self.香 = Int8(香); self.桂 = Int8(桂)
		self.銀 = Int8(銀) ; self.金 = Int8(金)
		self.角 = Int8(角) ; self.飛 = Int8(飛)
	}

	public init() {
		self.init(歩: 0, 香: 0, 桂: 0, 銀: 0, 金: 0, 角: 0, 飛: 0)
	}

	public init(string: String) {
		self.init()

		// "飛角金2桂歩4", "角,銀3,香,歩", "なし"
		let scanner = KibanScanner(string: string)
		scanner.scan先手後手()
		scanner.scanner.scanString("持駒:", intoString: nil)
		for (key, value) in 持駒型.記号表 {
			var string: NSString? = nil
			var count: Int = 1
			if scanner.scanner.scanString(key, intoString: &string) {
				scanner.scanner.scanInteger(&count)
				self[value] = count
				scanner.scanner.scanString(",", intoString: nil)
			}
		}
		print("\(self.dictionaryRepresentation)")
	}

	static let 記号表: [String: 駒型] = [
		"飛": .飛, "角": .角, "金": .金, "銀": .銀, "桂": .桂, "香": .香, "歩": .歩
	]

	public var dictionaryRepresentation: [String: Int8] {
		return [
			"飛": self.飛, "角": self.角, "金": self.金, "銀": self.銀, "桂": self.桂, "香": self.香, "歩": self.歩
		]
	}

	public var string: String {

		func symbolWithCount(symbol: String, count: Int8) -> String? {
			if count > 0 {
				var string = ""
				string += symbol
				if count > 1 {
					string += "\(count)"
				}
				return string
			}
			return nil
		}

		var strings = [String]()
		for (key, value) in self.dictionaryRepresentation {
			if let string = symbolWithCount(key, count: value) {
				strings.append(string)
			}
		}

		var string = "持駒:"
		if strings.count > 0 {
			string += (strings as NSArray).componentsJoinedByString(",")
		}
		else {
			string += "なし"
		}
		return string
	}

	public func string(player: 先手後手型) -> String {
		return player.string + self.string
	}

	public subscript (key: 駒型) -> Int {
		get {
			switch key {
			case .歩: return Int(歩)
			case .香: return Int(香)
			case .桂: return Int(桂)
			case .銀: return Int(銀)
			case .金: return Int(金)
			case .角: return Int(角)
			case .飛: return Int(飛)
			default: return 0
			}
		}
		set {
			switch key {
			case .歩: 歩 = Int8(newValue)
			case .香: 香 = Int8(newValue)
			case .桂: 桂 = Int8(newValue)
			case .銀: 銀 = Int8(newValue)
			case .金: 金 = Int8(newValue)
			case .角: 角 = Int8(newValue)
			case .飛: 飛 = Int8(newValue)
			default: break
			}
		}
	}

	public var description: String {
		return self.string
	}

	mutating func 駒を加える(駒: 駒型) {
		switch (駒) {
		case .歩: self.歩 += 1; assert(self.歩 <= 18)
		case .香: self.香 += 1; assert(self.香 <= 4)
		case .桂: self.桂 += 1; assert(self.桂 <= 4)
		case .銀: self.銀 += 1; assert(self.銀 <= 4)
		case .金: self.金 += 1; assert(self.金 <= 4)
		case .角: self.角 += 1; assert(self.角 <= 2)
		case .飛: self.飛 += 1; assert(self.飛 <= 2)
		case .王: break /* aah! nice try! */
		}
	}

	mutating func 駒を減らす(駒: 駒型) {
		switch (駒) {
		case .歩: self.歩 -= 1; assert(self.歩 >= 0)
		case .香: self.香 -= 1; assert(self.香 >= 0)
		case .桂: self.桂 -= 1; assert(self.桂 >= 0)
		case .銀: self.銀 -= 1; assert(self.銀 >= 0)
		case .金: self.金 -= 1; assert(self.金 >= 0)
		case .角: self.角 -= 1; assert(self.角 >= 0)
		case .飛: self.飛 -= 1; assert(self.飛 >= 0)
		case .王: break /* aah! nice try! */
		}
	}

	public var integerValue: UInt32 {
		var value: UInt64 = 0
		value += UInt64(飛)
		value *= UInt64(駒型.角.駒数+1) ; value += UInt64(角)
		value *= UInt64(駒型.金.駒数+1) ; value += UInt64(金)
		value *= UInt64(駒型.銀.駒数+1) ; value += UInt64(銀)
		value *= UInt64(駒型.桂.駒数+1) ; value += UInt64(桂)
		value *= UInt64(駒型.香.駒数+1) ; value += UInt64(香)
		value *= UInt64(駒型.歩.駒数+1) ; value += UInt64(歩)
		assert(value <= 0x1_a17b)
		return UInt32(value)
	}

	public init(integerValue: UInt32) {
		var value = UInt64(integerValue)
		歩 = Int8(value % UInt64(駒型.歩.駒数+1)) ; value /= UInt64(駒型.歩.駒数+1)
		香 = Int8(value % UInt64(駒型.香.駒数+1)) ; value /= UInt64(駒型.香.駒数+1)
		桂 = Int8(value % UInt64(駒型.桂.駒数+1)) ; value /= UInt64(駒型.桂.駒数+1)
		銀 = Int8(value % UInt64(駒型.銀.駒数+1)) ; value /= UInt64(駒型.銀.駒数+1)
		金 = Int8(value % UInt64(駒型.金.駒数+1)) ; value /= UInt64(駒型.金.駒数+1)
		角 = Int8(value % UInt64(駒型.角.駒数+1)) ; value /= UInt64(駒型.角.駒数+1)
		飛 = Int8(value % UInt64(駒型.飛.駒数+1))
	}

	public func 全持駒() -> [駒型] {
		let 持駒情報 = [(歩, 駒型.歩), (香, 駒型.香), (桂, 駒型.桂), (銀, 駒型.銀), (金, 駒型.金), (角, 駒型.角), (飛, 駒型.飛)]
		var 持駒 = [駒型]()
		for (駒数, 駒) in 持駒情報 {
			持駒 += Array<駒型>(count: Int(駒数), repeatedValue: 駒)
		}
		return 持駒
	}

	public func 持ち駒の種類() -> Set<駒型> {
		let 持駒情報 = [(歩, 駒型.歩), (香, 駒型.香), (桂, 駒型.桂), (銀, 駒型.銀), (金, 駒型.金), (角, 駒型.角), (飛, 駒型.飛)]
		var 駒集合 = Set<駒型>()
		for (駒数, 駒) in 持駒情報 {
			if 駒数 > 0 { 駒集合.insert(駒) }
		}
		return 駒集合
	}
}

public func == (lhs: 持駒型, rhs: 持駒型) -> Bool {
	return lhs.歩 == rhs.歩 && lhs.香 == rhs.香 && lhs.桂 == rhs.桂 && lhs.銀 == rhs.銀 && lhs.金 == rhs.金 && lhs.角 == rhs.角 && lhs.飛 == rhs.飛
}

// MARK: - 先手後手型

public enum 先手後手型 : Int8, CustomStringConvertible {
	case 先手, 後手

	private static let 記号表: [String: 先手後手型] = [
		"▲": .先手, "☗": .先手, "先手": .先手,
		"▽": .後手, "☖": .後手, "後手": .後手
	]

	public init?(string: String) {
		if let player = 先手後手型.記号表[string] {
			self = player
		}
		else {
			return nil
		}
	}

	public var string: String {
		switch self {
		case .先手: return "▲"
		case .後手: return "▽"
		}
	}
	
	public var direction: Int {
		switch self {
		case .先手: return -1
		case .後手: return 1
		}
	}

	public var description: String {
		return self.string
	}

	public var 敵方: 先手後手型 {
		switch self {
		case .先手: return .後手
		case .後手: return .先手
		}
	}
	
	public func 升(駒面: 駒面型) -> 升型 {
		return 升型(先後: self, 駒面: 駒面)
	}
	
}


// MARK: - 升型

public enum 升型 : Int8, CustomStringConvertible {
	case 空

	case 先歩, 先香, 先桂, 先銀, 先金, 先角, 先飛, 先玉
	case 先と, 先杏, 先圭, 先全, 先馬, 先竜

	case 後歩, 後香, 後桂, 後銀, 後金, 後角, 後飛, 後王
	case 後と, 後杏, 後圭, 後全, 後馬, 後竜

	static let max = 29

	public init(先後: 先手後手型, 駒面: 駒面型) {
		switch (先後, 駒面) {
		case (.先手, .歩): self = .先歩
		case (.先手, .香): self = .先香
		case (.先手, .桂): self = .先桂
		case (.先手, .銀): self = .先銀
		case (.先手, .金): self = .先金
		case (.先手, .角): self = .先角
		case (.先手, .飛): self = .先飛
		case (.先手, .王): self = .先玉
		case (.先手, .と): self = .先と
		case (.先手, .杏): self = .先杏
		case (.先手, .圭): self = .先圭
		case (.先手, .全): self = .先全
		case (.先手, .馬): self = .先馬
		case (.先手, .竜): self = .先竜

		case (.後手, .歩): self = .後歩
		case (.後手, .香): self = .後香
		case (.後手, .桂): self = .後桂
		case (.後手, .銀): self = .後銀
		case (.後手, .金): self = .後金
		case (.後手, .角): self = .後角
		case (.後手, .飛): self = .後飛
		case (.後手, .王): self = .後王
		case (.後手, .と): self = .後と
		case (.後手, .杏): self = .後杏
		case (.後手, .圭): self = .後圭
		case (.後手, .全): self = .後全
		case (.後手, .馬): self = .後馬
		case (.後手, .竜): self = .後竜
		}
	}

	public init() {
		self = .空
	}

	public var 先後: 先手後手型? {
		switch self {
		case 空: return nil
		case 先歩, 先香, 先桂, 先銀, 先金, 先角, 先飛, 先玉, 先と, 先杏, 先圭, 先全, 先馬, 先竜: return .先手
		case 後歩, 後香, 後桂, 後銀, 後金, 後角, 後飛, 後王, 後と, 後杏, 後圭, 後全, 後馬, 後竜: return .後手
		}
	}

	public var 駒面: 駒面型? {
		switch self {
		case 先歩, 後歩: return .歩
		case 先香, 後香: return .香
		case 先桂, 後桂: return .桂
		case 先銀, 後銀: return .銀
		case 先金, 後金: return .金
		case 先角, 後角: return .角
		case 先飛, 後飛: return .飛
		case 先玉, 後王: return .王

		case 先と, 後と: return .と
		case 先杏, 後杏: return .杏
		case 先圭, 後圭: return .圭
		case 先全, 後全: return .全
		case 先馬, 後馬: return .馬
		case 先竜, 後竜: return .竜
		default: return nil
		}
	}

//		"▲": .先手, "▲": .先手, "先手": .先手,
//		"▽": .後手, "△": .後手, "後手": .後手

	private static let 記号表 : [String: 升型] = [
		"　　": .空,
		"▲歩": .先歩, "▲香": .先香, "▲桂": .先桂, "▲銀": .先銀, "▲金": .先金, "▲角": .先角, "▲飛": .先飛, "▲玉": .先玉,
		"▲と": .先と, "▲杏": .先杏, "▲圭": .先圭, "▲全": .先全, "▲馬": .先馬, "▲竜": .先竜,
		"▽歩": .後歩, "▽香": .後香, "▽桂": .後桂, "▽銀": .後銀, "▽金": .後金, "▽角": .後角, "▽飛": .後飛, "▽王": .後王,
		"▽と": .後と, "▽杏": .後杏, "▽圭": .後圭, "▽全": .後全, "▽馬": .後馬, "▽竜": .後竜,
		"▲王": .先玉, "▲龍": .先竜, "▽龍": .後竜,
	]
	
	public var string: String {
		for (key, value) in 升型.記号表 {
			if self == value {
				return key
			}
		}
		return "?"
	}

	public var description: String {
		for (key, value) in 升型.記号表 {
			if value == self {
				return key
			}
		}
		return "?"
	}
}

// MARK: - 手合割型

public enum 手合割型 {
	case 平手 //, 香落ち, 角落ち, 飛車落ち, 飛香落ち, 二枚落ち, 四枚落ち, 六枚落ち


	public static let 平手初期盤面: String =
			"▽持駒:なし\r" +
			"|▽香|▽桂|▽銀|▽金|▽王|▽金|▽銀|▽桂|▽香|\r" +
			"|　　|▽飛|　　|　　|　　|　　|　　|▽角|　　|\r" +
			"|▽歩|▽歩|▽歩|▽歩|▽歩|▽歩|▽歩|▽歩|▽歩|\r" +
			"|　　|　　|　　|　　|　　|　　|　　|　　|　　|\r" +
			"|　　|　　|　　|　　|　　|　　|　　|　　|　　|\r" +
			"|　　|　　|　　|　　|　　|　　|　　|　　|　　|\r" +
			"|▲歩|▲歩|▲歩|▲歩|▲歩|▲歩|▲歩|▲歩|▲歩|\r" +
			"|　　|▲角|　　|　　|　　|　　|　　|▲飛|　　|\r" +
			"|▲香|▲桂|▲銀|▲金|▲王|▲金|▲銀|▲桂|▲香|\r" +
			"▲持駒:なし\r"
}


// MARK: - 指手型

public enum 指手型: CustomStringConvertible {
	case 動(先後: 先手後手型, 移動前の位置: 位置型, 移動後の位置: 位置型, 移動後の駒面: 駒面型)
	case 打(先後: 先手後手型, 位置:位置型, 駒:駒型)
	case 投了(先後: 先手後手型)

	public var description: String {
		var string = ""
		switch self {
		case .動(let 先後, let 移動前の位置, let 移動後の位置, let 移動後の駒面):
			string += "\(先後)\(移動前の位置)->\(移動後の位置)\(移動後の駒面)"
		case .打(let 先後, let 位置, let 駒):
			string += "\(先後)\(位置)\(駒)打"
		case .投了(let 先後):
			string += "\(先後)投了"
		}
		return string
	}
}

// MARK: - 局面型

public class 局面型: Equatable, CustomStringConvertible, SequenceType {

	var score: Int = 0
	weak var 前の局面: 局面型?

	var 全升: [升型]
	var 持駒辞書: [先手後手型: 持駒型]
	var 手番: 先手後手型

	public init() {
		全升 = [升型](count: 総升数, repeatedValue: 升型.空)
		持駒辞書 = [.先手: 持駒型(), .後手: 持駒型()]
		手番 = .先手
	}

	public init(手番: 先手後手型, 全升: [升型], 持駒: [先手後手型: 持駒型]) {
		self.全升 = 全升
		self.持駒辞書 = 持駒
		self.手番 = 手番
	}

	public init?(string: String, 手番: 先手後手型) {
		全升 = [升型](count: 総升数, repeatedValue: 升型.空)
		持駒辞書 = [.先手: 持駒型(), .後手: 持駒型()]
		self.手番 = 手番

		var lines = string.lines()
		if lines.count >= (9 + 2) {
			持駒辞書[.後手] = 持駒型(string: lines[0])
			for rowIndex in 段型.全段 {
				let line = lines[rowIndex.index + 1]
				print("\(line)")
				let scanner = KibanScanner(string: line)
				scanner.scanner.scanString("|", intoString: nil)
				for columnIndex in 筋型.全筋.reverse() {
					if let square = scanner.scanSquare() {
						self[columnIndex, rowIndex] = square
						scanner.scanner.scanString("|", intoString: nil)
					}
				}
			}
			持駒辞書[.先手] = 持駒型(string: lines[10])
		}
		else {
			return nil
		}
	}

	public init(局面: 局面型) {
		self.全升 = 局面.全升
		self.持駒辞書 = 局面.持駒辞書
		self.手番 = 局面.手番.敵方
	}

	public subscript(筋: 筋型, 段: 段型) -> 升型? {
		get {
			if let 位置 = 位置型(筋: 筋, 段: 段) {
				return 全升[Int(位置.rawValue)]
			}
			return nil
		}
		set {
			if let 位置 = 位置型(筋: 筋, 段: 段) {
				全升[Int(位置.rawValue)] = newValue!
			}
		}
	}
	
	public subscript(位置: 位置型) -> 升型 {
		get {
			return 全升[Int(位置.rawValue)]
		}
		set {
			全升[Int(位置.rawValue)] = newValue
		}
	}
	
	public var description: String {
		var string = String()
		if let captured = 持駒辞書[.後手] {
			string += "後手" + captured.string + "\r"
		}
		for rowIndex in 段型.全段 {
			string += "|"

			for columnIndex in 筋型.全筋.reverse() {
				if let 升 = self[columnIndex, rowIndex] {
					string += 升.string
					string += "|"
				}
			}

			string += "\r"
		}
		if let captured = 持駒辞書[.先手] {
			string += "先手" + captured.string + "\r"
		}
		return string
	}

	public func 指定位置の駒の移動可能位置列(指定位置: 位置型) -> [位置型] {
		let 指定筋 = 指定位置.筋
		let 指定段 = 指定位置.段
	
		var 位置列 = [位置型]()
		
		if let 升 = self[指定筋, 指定段], 先後 = 升.先後, 駒面 = 升.駒面 {
			let 敵方 = 先後.敵方

			// find movable positions for single step like 歩, 桂, 金, ...
			for (dx, dy) in 駒面.移動可能なオフセット(駒面: 駒面, 先後: 先後) {
				let (x, y) = (指定筋 + dx, 指定段 + dy)
				if let 位置 = 位置型(筋: 指定筋 + dx, 段: 指定段 + dy) {
					let 対象升 = self[位置]
					if let どちらの駒 = 対象升.先後 where どちらの駒 == 先後 {
					}
					else if let 位置 = 位置型(筋: x, 段: y) {
						位置列.append(位置)
					}
					else if let position = 位置型(筋: x, 段: y) {
						位置列.append(position)
					}
				}
			}

			// find movable positions for distant move like 香, 飛, 角
			for (vx, vy) in 駒面.移動可能なベクトル(駒面: 駒面, 先後: 先後) {

				// 盤を外れるまで繰り返す
				var (x, y) = (指定筋 + vx, 指定段 + vy)
				
				while let 筋 = x, let 段 = y {
					if let 対象升 = self[筋, 段] {
						if 対象升.先後 == 先後 {
							break // 自駒に当たった場合
						}
						else if 対象升.先後 == 敵方 {
							if let 位置 = 位置型(筋: 筋, 段: 段) {
								位置列.append(位置)
								break
							}
						}
						else {
							if let 位置 = 位置型(筋: 筋, 段: 段) {
								位置列.append(位置)
							}
						}
					}
				
					(x, y) = (筋 + vx, 段 + vy)
				}
			}
		}
		return 位置列
	}
	
	public func 指定位置の駒の移動可能指手列(位置: 位置型) -> [指手型] {
		var 指手列 = [指手型]()
		let 升 = self[位置]
		if let 先後 = 升.先後, let 駒面 = 升.駒面 {

			for 移動後位置 in 指定位置の駒の移動可能位置列(位置) {
				if 不成で移動可能か(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動後位置, 移動前の駒面: 駒面) {
					指手列.append(指手型.動(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動後位置, 移動後の駒面: 駒面))
				}
				if 成って移動可能か(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動後位置, 移動前の駒面: 駒面) {
					指手列.append(指手型.動(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動後位置, 移動後の駒面: 駒面.成る()))
				}
			}

		}
		return 指手列
	}

	// in order to avoid huge number of linear search, build a lookup dictionary from square to position
	public func 駒から升への辞書() -> [升型: [位置型]] {
		var 辞書 = [升型: [位置型]]()
		for (index, 升) in 全升.enumerate() {
			if let 位置 = 位置型(rawValue: Int8(index)) {
				var 位置列 = 辞書[升] ?? []
				位置列.append(位置)
				辞書[升] = 位置列
			}
		}
		return 辞書
	}

	public func 駒の位置列(駒: 駒型, 先後: 先手後手型) -> [位置型] {
		var 位置列 = [位置型]()
		for (index, 升) in 全升.enumerate() {
			if let 升の駒 = 升.駒面?.駒, let 升の駒の先後 = 升.先後, let 位置 = 位置型(rawValue: Int8(index)) where 駒 == 升の駒 && 升の駒の先後 == 先後 {
				位置列.append(位置)
			}
		}
		return 位置列
	}

	public func 指手を実行(指手: 指手型) -> 局面型? {
		let 局面 = 局面型(局面: self)
		局面.前の局面 = self
		switch 指手 {
		case .動(let 先手後手, let 移動前の位置, let 移動後の位置, let 移動後の駒面):
			let 移動前のマス = self[移動前の位置]
			let 移動後のマス = self[移動後の位置]
			if let 移動前の駒面 = 移動前のマス.駒面 where 移動前の駒面.駒 == 移動後の駒面.駒 {
				if let 移動後の駒面 = 移動後のマス.駒面, 移動後のマスの駒の先手後手 = 移動後のマス.先後 {
					// 相手の駒を取る
					assert(移動後のマスの駒の先手後手 == 先手後手.敵方)
					if 移動後の駒面.駒 == .王 { // 相手の王を取る
						return nil
					}
					局面.持駒辞書[先手後手]!.駒を加える(移動後の駒面.駒)
				}
				局面[移動前の位置] = .空
				局面[移動後の位置] = 升型(先後: 先手後手, 駒面: 移動後の駒面)
			}
			else { /*論理エラー*/ }
			break
		case .打(let 先後, let 位置, let 駒):
			assert(self[位置] == .空)
			assert(先後 == self.手番)
			局面[位置] = 升型(先後: 先後, 駒面: 駒.駒面)
			局面.持駒辞書[先後]!.駒を減らす(駒)
			break
		default:
			break
		}
		return 局面
	}


	public func 全位置で実行(closure: (位置型) -> ()) {
		for 筋 in 筋型.全筋 {
			for 段 in 段型.全段 {
				if let position = 位置型(筋: 筋, 段: 段) {
					closure(position)
				}
			}
		}
	}

	public func 全可能指手列() -> [指手型] {
		var 指手列 = [指手型]()
		for 位置 in self.全位置() {
			let 升 = self[位置]
			if let 先後 = 升.先後, 駒面 = 升.駒面 where 先後 == 手番 {
				for 移動可能位置 in 指定位置の駒の移動可能位置列(位置) {
					if 不成で移動可能か(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動可能位置, 移動前の駒面: 駒面) {
						指手列.append(指手型.動(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動可能位置, 移動後の駒面: 駒面))
					}
					if 成って移動可能か(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動可能位置, 移動前の駒面: 駒面) {
						指手列.append(指手型.動(先後: 先後, 移動前の位置: 位置, 移動後の位置: 移動可能位置, 移動後の駒面: 駒面.成る()))
					}
				}
			}
			else if 升 == .空 {
				let 持駒 = 持駒辞書[手番]!
				for 駒 in 持駒.持ち駒の種類() {
					if 指定位置へ打つ事は可能か(先後: 手番, 指定位置: 位置, 駒: 駒) {
						指手列.append(指手型.打(先後: 手番, 位置: 位置, 駒: 駒))
					}
				}

			}
		}
		return 指手列
	}

	public func 成って移動可能か(先後 先後: 先手後手型, 移動前の位置: 位置型, 移動後の位置: 位置型, 移動前の駒面: 駒面型) -> Bool {
		let 敵 = 先後.敵方
		let 敵陣 = 陣型(先後: 敵)
		let 移動前 = 移動前の位置.陣
		let 移動後 = 移動後の位置.陣
		
		return (移動前 == 敵陣 || 移動後 == 敵陣) && 移動前の駒面.成る事は可能か && !移動前の駒面.成駒か
	}

	public func 不成で移動可能か(先後 先後: 先手後手型, 移動前の位置: 位置型, 移動後の位置: 位置型, 移動前の駒面: 駒面型) -> Bool {

		switch (移動後の位置.段, 移動前の駒面, 先後) {
		case (.一, .歩, .先手): return false
		case (.一, .香, .先手): return false
		case (.一, .桂, .先手): return false
		case (.二, .桂, .先手): return false

		case (.八, .桂, .先手): return false
		case (.九, .桂, .後手): return false
		case (.九, .香, .後手): return false
		case (.九, .歩, .後手): return false

		default: return true // 成駒の移動は不成で移動とみなす
		}
	}

	public func 指定位置へ打つ事は可能か(先後 先後: 先手後手型, 指定位置: 位置型, 駒: 駒型) -> Bool {
		if 駒.指定段に打つ事は可能か(先後: 先後, 段: 指定位置.段) {
			switch 駒.駒面 {
			case .歩:
				// TODO: 打ち歩詰め
				return 指定位置に歩を打つ事は可能か(手番: 先後, 位置: 指定位置) // 二歩・打ち歩詰めの確認
			default: return true
			}
		}
		else { return false }
	}
	
	public func 指定位置に歩を打つ事は可能か(手番 手番: 先手後手型, 位置: 位置型) -> Bool {
		// 二歩のチェック
		let 筋 = 位置.筋
		for 段 in 段型.全段 {
			if let 升 = self[筋, 段], let 駒面 = 升.駒面, let 先後 = 升.先後 {
				if 駒面 == .歩 && 手番 == 先後 {
					return false
				}
			}
		}

		// 打ち歩詰め
		let 指手 = 指手型.打(先後: 手番, 位置: 位置, 駒: .歩)
		if !self.指手を実行(指手)!.詰みか() { return false }
		
		return true
	}

	public func 指定位置へ移動可能な全ての駒の位置列(指定位置: 位置型, _ 先後: 先手後手型?) -> [位置型] {

		var 位置列 = [位置型]()
		// 盤上の全ての駒について調べる

		for 位置 in 位置型.全位置 {
			// そこに駒があれば、その駒の全ての移動可能先を調べる
			let 升 = self[位置]
			let 移動可能位置列 = 指定位置の駒の移動可能位置列(位置)
			for 該当位置 in 移動可能位置列 {
				if 該当位置 == 指定位置 { // && (先後 ?? 対象升.先後 == 対象升.先後) {
					// 該当升を対象として含める
					if let 指定先後 = 先後, let 升先後 = 升.先後 where 指定先後 == 升先後 {
						位置列.append(位置)
					}
					else if 先後 == nil {
						位置列.append(位置)
					}
				}
			}
		}
		return 位置列
	}

	public func 指定位置へ移動可能な全ての駒を移動させる指手(指定位置: 位置型, _ 先後: 先手後手型?) -> [指手型] {
		var 指手列 = [指手型]()
		for 指定位置へ移動可能な駒の位置 in self.指定位置へ移動可能な全ての駒の位置列(指定位置, 先後) {
			let 升 = self[指定位置へ移動可能な駒の位置]
			if let 先後 = 升.先後, 駒面 = 升.駒面 {
				if 不成で移動可能か(先後: 先後, 移動前の位置: 指定位置へ移動可能な駒の位置, 移動後の位置: 指定位置, 移動前の駒面: 駒面) {
					指手列.append(指手型.動(先後: 先後, 移動前の位置: 指定位置へ移動可能な駒の位置, 移動後の位置: 指定位置, 移動後の駒面: 駒面))
				}
				if 成って移動可能か(先後: 先後, 移動前の位置: 指定位置へ移動可能な駒の位置, 移動後の位置: 指定位置, 移動前の駒面: 駒面) {
					指手列.append(指手型.動(先後: 先後, 移動前の位置: 指定位置へ移動可能な駒の位置, 移動後の位置: 指定位置, 移動後の駒面: 駒面.成る()))
				}
			}
		}
		return 指手列
	}


	public func 王手列(手番: 先手後手型) -> [指手型] {
		let 辞書 = 駒から升への辞書()
		let 王 = 升型(先後: 手番, 駒面: .王)
		var 指手列 = [指手型]()
		if let 王の位置 = 辞書[王]?.first {
			let 敵方 = 手番.敵方
			for 敵駒の位置 in 指定位置へ移動可能な全ての駒の位置列(王の位置, 敵方) {
				if let 駒面 = self[敵駒の位置].駒面 { // 王手
					let 指手 = 指手型.動(先後: 敵方, 移動前の位置: 敵駒の位置, 移動後の位置: 王の位置, 移動後の駒面: 駒面)
					指手列.append(指手)
				}
			}
		}
		return 指手列
	}

	public func 詰みか() -> Bool {
		// 手番の王は詰みか？
		let 敵方 = self.手番.敵方
		for 王手 in 王手列(手番) {
			if case .動(let 先後, let 移動前の位置, let 移動後の位置, let 移動後の駒面) = 王手 {
				assert(先後 == 敵方)
				assert(self[移動後の位置].駒面 == .王)
				
				// 王手をかけている敵駒を取る事ができるか？
				for 指手 in 指定位置へ移動可能な全ての駒を移動させる指手(移動前の位置, 手番) {
					if let 次局面 = self.指手を実行(指手) where 次局面.王手列(手番).count == 0 {
						return false // 一つでも回避できれば詰みではない
					}
				}

				// 王の逃げ道はあるか
				for 指手 in 指定位置の駒の移動可能指手列(移動後の位置) {
					if let 次局面 = 指手を実行(指手) where 次局面.王手列(手番).count == 0 {
						return false // 一つでも回避できれば詰みではない
					}
				}
			}
		}
		return true
	}

	public func 全位置() -> [位置型] {
		// 玉の周りや、角、飛など優先順位に応じて、探索する順序を決めるベキ？
		return 位置型.全位置
	}

	public func generate() -> 局面Generator {
		return 局面Generator()
	}

	public func data() -> NSData {
		//var stream = NSOutputStream.outputStreamToMemory()
		let data = NSMutableData()
		for row in 段型.全段 {
			var value: UInt64 = 0
			for col in 筋型.全筋 {
				let square = self[col, row]
				value = value * UInt64(升型.max) + UInt64(square!.rawValue)
			}
			assert(value < 0x100_0000)
			for _ in 1...6 { // max 6 bytes
				var hex = UInt8(value % 0x100)
				data.appendBytes(&hex, length: 1)
				value /= 0x100
			}
		}
		var 先手持駒: UInt32 = CFSwapInt32HostToBig(持駒辞書[.先手]!.integerValue)
		var 後手持駒: UInt32 = CFSwapInt32HostToBig(持駒辞書[.後手]!.integerValue)
		data.appendBytes(&先手持駒, length: sizeof(UInt32))
		data.appendBytes(&後手持駒, length: sizeof(UInt32))
		return data
	}

}

public struct 局面Generator: GeneratorType {
	private var rawIndex = Int8(0)
	public mutating func next() -> 位置型? {
		if rawIndex < Int8(総升数) {
			defer { rawIndex += 1 }
			return 位置型(rawValue: rawIndex)
		}
		return nil
	}
}


public func == (lhs: 局面型, rhs: 局面型) -> Bool {
	return	lhs.全升 == rhs.全升 && lhs.手番 == rhs.手番 &&
			lhs.持駒辞書[.先手]! == rhs.持駒辞書[.先手]! &&
			lhs.持駒辞書[.後手]! == rhs.持駒辞書[.後手]!
}

/*
class 対局型 {
	var 手合割: 手合割型 = .平手
	var 指手列 = [指手型]()
	init(手合割: 手合割型) {
		self.手合割 = 手合割
	}
}
*/