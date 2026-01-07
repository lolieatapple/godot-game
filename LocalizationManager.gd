extends Node

var current_language = "zh_CN" # Default to Simplified Chinese

signal language_changed

var translations = {
	"zh_CN": {
		"press_any_key": "- 按任意键开始 -",
		"score": "分数: ",
		"level": "关卡: ",
		"kills": "击杀: ",
		"level_complete": "关卡完成!",
		"ready": "准备",
		"go": "行动!",
		"survivor": "幸存者",
		"press_space": "按空格键继续",
		"story_1": "2035年。病毒夺走了一切.\n我拥有抗体。我必须活下去。\n首先，通过这个房间建立安全屋。",
		"story_2": "物资快用完了。\n我看到附近有一家杂货店。\n饿死之前必须找到食物。",
		"story_3": "好渴……太渴了。\n城市的水源被污染了。\n必须在仓库里找到瓶装水。",
		"story_4": "腿上受了重伤。\n感染风险很高。\n需要去药房找抗生素。",
		"story_5": "几周没有无线电信号了。\n前面有一座广播塔。\n也许能联系上其他幸存者。",
		"story_6": "现在的尸潮规模更大了。\n发现了一个旧警察局。\n需要弹药。大量的弹药。",
		"story_7": "突变正在扩散。\n更快，更强的丧尸。\n必须找到一辆车继续前进。",
		"story_8": "冬天来了。\n夜晚冻死人。\n需要找到御寒衣物和燃料。",
		"story_9": "听到了信号！军事哨所？\n很远，要穿过市中心。\n这将是一场恶战。",
		"story_10": "信号是个陷阱……或者是坟墓。\n这里没人了。\n我是最后的希望。我要战斗到底。",
		"story_endless": "还活着。\n尸潮无穷无尽。\n必须继续前进。",
		"paused": "暂停",
		"resume": "继续游戏 (ESC)",
		"restart": "重新开始",
		"quit": "退出游戏",
		"game_over": "游戏结束",
		"final_score": "最终得分: ",
		"play_again": "再玩一次",
		"menu": "返回主菜单"
	},
	"en": {
		"press_any_key": "- Press Any Key to Start -",
		"score": "Score: ",
		"level": "Level: ",
		"kills": "Kills: ",
		"level_complete": "Level Complete!",
		"ready": "Ready",
		"go": "Go!",
		"survivor": "SURVIVOR",
		"press_space": "Press SPACE to continue",
		"story_1": "Year 2035. The virus took everything.\nI have the antibodies. I must survive.\nFirst, secure this safehouse.",
		"story_2": "Supplies are running low.\nI saw a grocery store nearby.\nNeed to find food before I starve.",
		"story_3": "Thirsty... so thirsty.\nThe city water is contaminated.\nMust find bottled water in the warehouse.",
		"story_4": "Got a nasty cut on my leg.\nInfection risk is high.\nNeed antibiotics from the pharmacy.",
		"story_5": "Radio silence for weeks.\nThere's a broadcast tower ahead.\nMaybe I can reach other survivors.",
		"story_6": "They swarm in larger groups now.\nFound an old police station.\nNeed ammo. Lots of it.",
		"story_7": "The mutation is spreading.\nFaster, stronger zombies.\nNeed to find a vehicle to keep moving.",
		"story_8": "Winter is coming.\nNights are freezing.\nNeed to find warm clothes and fuel.",
		"story_9": "Heard a signal! A military outpost?\nIt's far, through the city center.\nThis will be a tough fight.",
		"story_10": "The signal was a trap... or a grave.\nNo one is left here.\nI am the last hope. I keep fighting.",
		"story_endless": "Still alive.\nThe horde never ends.\nMust keep moving.",
		"paused": "PAUSED",
		"resume": "Resume (ESC)",
		"restart": "Restart",
		"quit": "Quit",
		"game_over": "GAME OVER",
		"final_score": "Final Score: ",
		"play_again": "Play Again",
		"menu": "Main Menu"
	}
}

func set_language(lang: String):
	if lang in translations:
		current_language = lang
		language_changed.emit()

func get_text(key: String) -> String:
	if current_language in translations and key in translations[current_language]:
		return translations[current_language][key]
	# Fallback to English if key missing in current language
	if "en" in translations and key in translations["en"]:
		return translations["en"][key]
	return key
