//
//  ClipLikeUITestsLaunchTests.swift
//  ClipLikeUITests
//
//  Created by henery on 2026/2/2.
//

import XCTest

final class ClipLikeUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.windows["ClipLike.ContentView-1-AppWindow-1"].firstMatch/*[[".windows",".containing(.button, identifier: \"_XCUI:CloseWindow\").firstMatch",".containing(.toolbar, identifier: nil).firstMatch",".containing(.group, identifier: nil).firstMatch",".firstMatch",".windows[\"ClipLike\"].firstMatch",".windows[\"ClipLike.ContentView-1-AppWindow-1\"].firstMatch"],[[[-1,6],[-1,5],[-1,0,1]],[[-1,4],[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.typeKey("w", modifierFlags:.command)
        
        let app2 = XCUIApplication(bundleIdentifier: "com.trae.app")
        app2.activate()
        app2.staticTexts.matching(identifier: "Builder").element(boundBy: 1).click()
        app2/*@START_MENU_TOKEN@*/.textViews["@"]/*[[".textViews",".containing(.staticText, identifier: \"@\")",".containing(.group, identifier: nil)",".groups.textViews[\"@\"]",".textViews[\"@\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeKey(.delete, modifierFlags:[])
        app2/*@START_MENU_TOKEN@*/.textViews.groups.firstMatch/*[[".groups.element(boundBy: 352)",".textViews.groups.firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let element = app2/*@START_MENU_TOKEN@*/.textViews["\n"]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.group, identifier: nil)",".groups.textViews[\"\\n\"]",".textViews[\"\\n\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.typeKey(.delete, modifierFlags:[])
        element.typeKey(.delete, modifierFlags:[])
        element.typeText("")
        element.typeKey(.delete, modifierFlags:[])
        
        let element2 = app2/*@START_MENU_TOKEN@*/.textViews["1."]/*[[".textViews",".containing(.staticText, identifier: \"1.\")",".containing(.group, identifier: nil)",".groups.textViews[\"1.\"]",".textViews[\"1.\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element2.typeText("xainchxian chakachakan benxmu gen")
        element2.typeKey(.delete, modifierFlags:.command)
        app2/*@START_MENU_TOKEN@*/.textViews["1. "]/*[[".textViews",".containing(.staticText, identifier: \"1. \")",".containing(.group, identifier: nil)",".groups.textViews[\"1. \"]",".textViews[\"1. \"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeKey(.delete, modifierFlags:.command)
        app2/*@START_MENU_TOKEN@*/.textViews["1. c​"]/*[[".textViews",".containing(.staticText, identifier: \"1. c​\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. c​\"]",".textViews[\"1. c​\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeKey(.delete, modifierFlags:.command)
        
        let element3 = app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录下docs/"]/*[[".textViews",".containing(.staticText, identifier: \"1. 查看本项目根目录下docs\/\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录下docs\/\"]",".textViews[\"1. 查看本项目根目录下docs\/\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element3.typeText("1. chakan benxmu genml xia docs/")
        element3.typeKey(.leftArrow, modifierFlags:[.option, .function])
        element3.typeKey(.leftArrow, modifierFlags:.function)
        element3.typeKey(.leftArrow, modifierFlags:.function)
        element3.typeKey(.leftArrow, modifierFlags:.function)
        element3.typeKey(.leftArrow, modifierFlags:.function)
        
        let element4 = app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/"]/*[[".textViews",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/\"]",".textViews[\"1. 查看本项目根目录docs\/\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element4.typeKey(.delete, modifierFlags:[])
        element4.typeKey(.rightArrow, modifierFlags:[.command, .function])
        
        let element5 = app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的开发计划"]/*[[".textViews",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的开发计划\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的开发计划\"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的开发计划\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element5.typeText("wend ,shi benxiang mxmu de kaifajihua ")
        element5.typeKey(.leftArrow, modifierFlags:.function)
        element5.typeKey(.leftArrow, modifierFlags:.function)
        element5.typeKey(.leftArrow, modifierFlags:.function)
        element5.typeKey(.leftArrow, modifierFlags:.function)
        
        let element6 = app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划"]/*[[".textViews",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划\"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element6.typeText("chuban ")
        element6.typeKey(.rightArrow, modifierFlags:[.command, .function])
        app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划；"]/*[[".textViews",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划；\"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划；\"]"],[[[-1,4],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText(";\r")
        
        let element7 = app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划；\n2. "]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划；\\n2. \"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划；\\n2. \"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element7.typeText("2. ")
        
        let statusApp = XCUIApplication(bundleIdentifier: "com.bjango.istatmenus.status")
        statusApp.activate()
        statusApp/*@START_MENU_TOKEN@*/.statusItems["内存压力 20%"]/*[[".menuBars.statusItems[\"内存压力 20%\"]",".statusItems[\"内存压力 20%\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        statusApp.menuItems.element(boundBy: 5).click()
        
        let activityMonitorApp = XCUIApplication(bundleIdentifier: "com.apple.ActivityMonitor")
        activityMonitorApp.activate()
        let element8 = activityMonitorApp/*@START_MENU_TOKEN@*/.radioButtons["内存"]/*[[".radioGroups.radioButtons[\"内存\"]",".radioButtons[\"内存\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element8.click()
        
        let element9 = activityMonitorApp/*@START_MENU_TOKEN@*/.radioButtons["CPU"]/*[[".radioGroups.radioButtons[\"CPU\"]",".radioButtons[\"CPU\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element9.click()
        element8.click()
        
        let element10 = activityMonitorApp/*@START_MENU_TOKEN@*/.groups["_NS:820"]/*[[".groups",".containing(.staticText, identifier: \"已使用内存：\")",".containing(.staticText, identifier: \"24.00 GB\")",".containing(.staticText, identifier: \"物理内存：\")",".groups[\"_NS:820\"]"],[[[-1,4],[-1,0,1]],[[-1,4],[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element10.doubleClick()
        element10.click()
        
        let googleChromeElementsQuery = activityMonitorApp.staticTexts.matching(identifier: " Google Chrome Helper (Renderer)")
        googleChromeElementsQuery.element(boundBy: 4).click()
        googleChromeElementsQuery.element(boundBy: 3).click()
        
        let desktopApp = XCUIApplication(bundleIdentifier: "com.localraghub.desktop")
        desktopApp.activate()
        let element11 = desktopApp/*@START_MENU_TOKEN@*/.textFields["向本地知识库快速提问..."]/*[[".groups.textFields[\"向本地知识库快速提问...\"]",".textFields",".textFields[\"向本地知识库快速提问...\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element11.doubleClick()
        element11.click()
        desktopApp.groups/*@START_MENU_TOKEN@*/.containing(.textField, identifier: "向本地知识库快速提问...").firstMatch/*[[".element(boundBy: 5)",".containing(.staticText, identifier: \"LocalRAG Hub · 本地知识库助手\").firstMatch",".containing(.button, identifier: nil).firstMatch",".containing(.textField, identifier: \"向本地知识库快速提问...\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        activityMonitorApp.activate()
        element10.click()
        element10.click()
        
        statusApp.activate()
        statusApp/*@START_MENU_TOKEN@*/.statusItems["内存压力 23%"]/*[[".menuBars.statusItems[\"内存压力 23%\"]",".statusItems[\"内存压力 23%\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        activityMonitorApp.activate()
        activityMonitorApp/*@START_MENU_TOKEN@*/.staticTexts[" lldb-rpc-server"]/*[[".cells.staticTexts[\" lldb-rpc-server\"]",".staticTexts[\" lldb-rpc-server\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        let element12 = activityMonitorApp/*@START_MENU_TOKEN@*/.staticTexts[" LocalRAG Hub Helper (GPU)"]/*[[".cells.staticTexts[\" LocalRAG Hub Helper (GPU)\"]",".staticTexts[\" LocalRAG Hub Helper (GPU)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element12.click()
        element12.click()
        element9.click()
        activityMonitorApp/*@START_MENU_TOKEN@*/.radioButtons["能耗"]/*[[".radioGroups.radioButtons[\"能耗\"]",".radioButtons[\"能耗\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        app2.activate()
        let element13 = app2/*@START_MENU_TOKEN@*/.staticTexts["Work with Builder Automates routine development tasks end-to-end for faster and more efficient delivery."]/*[[".staticTexts",".containing(.staticText, identifier: \"Work with\")",".containing(.image, identifier: nil)",".containing(.staticText, identifier: \"Automates routine development tasks end-to-end for faster and more efficient delivery.\")",".groups.staticTexts[\"Work with Builder Automates routine development tasks end-to-end for faster and more efficient delivery.\"]",".staticTexts[\"Work with Builder Automates routine development tasks end-to-end for faster and more efficient delivery.\"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element13.click()
        element13.click()
        element13.click()
        
        let chromeApp = XCUIApplication(bundleIdentifier: "com.google.Chrome")
        chromeApp.activate()
        chromeApp/*@START_MENU_TOKEN@*/.groups["Account Setting | TRAE - Collaborate with Intelligence - Google Chrome - 范光"].webViews["Account Setting | TRAE - Collaborate with Intelligence"].firstMatch/*[[".webViews",".containing(.staticText, identifier: \"26\").firstMatch",".matching(identifier: \"Account Setting | TRAE - Collaborate with Intelligence\")",".element(boundBy: 0)",".containing(.staticText, identifier: \"You are on Free Plan. Usage reset in\").firstMatch",".groups[\"Account Setting | TRAE - Collaborate with Intelligence - Google Chrome - 范光\"]",".webViews.firstMatch",".webViews[\"Account Setting | TRAE - Collaborate with Intelligence\"].firstMatch"],[[[-1,5,2],[-1,0,1]],[[-1,4],[-1,2,3],[-1,1]],[[-1,7],[-1,6]],[[-1,4],[-1,3]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        let groupsQuery = chromeApp.groups
        groupsQuery/*@START_MENU_TOKEN@*/.containing(.staticText, identifier: "You are on Free Plan. Usage reset in").firstMatch/*[[".element(boundBy: 52)",".containing(.staticText, identifier: \" days\").firstMatch",".containing(.staticText, identifier: \"26\").firstMatch",".containing(.staticText, identifier: \"You are on Free Plan. Usage reset in\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        groupsQuery.element(boundBy: 32).click()
        chromeApp/*@START_MENU_TOKEN@*/.windows["hao123_上网从这里开始 - Google Chrome - 范光"].buttons["_XCUI:CloseWindow"].firstMatch/*[[".buttons.matching(identifier: \"_XCUI:CloseWindow\").element(boundBy: 0)",".windows[\"hao123_上网从这里开始 - Google Chrome - 范光\"].buttons[\"_XCUI:CloseWindow\"].firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        groupsQuery/*@START_MENU_TOKEN@*/.containing(.group, identifier: "Usage").firstMatch/*[[".element(boundBy: 26)",".containing(.tab, identifier: \"Settings\").firstMatch",".containing(.tab, identifier: \"Profile\").firstMatch",".containing(.group, identifier: \"Usage\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        groupsQuery.element(boundBy: 19).click()
        groupsQuery/*@START_MENU_TOKEN@*/.containing(.group, identifier: "AI 模式历史记录").firstMatch/*[[".element(boundBy: 72)",".containing(.button, identifier: \"开始新的搜索\").firstMatch",".containing(.table, identifier: nil).firstMatch",".containing(.group, identifier: \"AI 模式历史记录\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let element14 = chromeApp/*@START_MENU_TOKEN@*/.textViews["提问"]/*[[".groups.textViews[\"提问\"]",".textViews",".textViews[\"提问\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element14.click()
        element14.click()
        element14.typeText("zmdajian ?jinqu Xcodechaungjianxiangmu anzhao tade tishi yibuyibu lai ma ?youhezhuyishixiang ?\r")
        chromeApp.staticTexts/*@START_MENU_TOKEN@*/.containing(.staticText, identifier: "2. 关键配置（避坑指南）").firstMatch/*[[".matching(identifier: \"2. 关键配置（避坑指南）\")",".element(boundBy: 0)",".containing(.staticText, identifier: \"2. 关键配置（避坑指南）\").firstMatch"],[[[-1,2],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let universalAccessAuthWApp = XCUIApplication(bundleIdentifier: "com.apple.accessibility.universalAccessAuthWarn")
        universalAccessAuthWApp.activate()
        let systempreferencesApp = XCUIApplication(bundleIdentifier: "com.apple.systempreferences")
        systempreferencesApp.activate()
        systempreferencesApp/*@START_MENU_TOKEN@*/.switches["Xcode_Toggle"]/*[[".cells.switches[\"Xcode_Toggle\"]",".switches[\"Xcode_Toggle\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        systempreferencesApp/*@START_MENU_TOKEN@*/.buttons["_XCUI:CloseWindow"]/*[[".windows.buttons[\"_XCUI:CloseWindow\"]",".buttons[\"_XCUI:CloseWindow\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        app2.activate()
        let groupsQuery2 = app2.groups
        let element15 = groupsQuery2/*@START_MENU_TOKEN@*/.containing(.staticText, identifier: "1. 查看本项目根目录docs/文档，是本项目的初版开发计划；").firstMatch/*[[".element(boundBy: 331)",".containing(.staticText, identifier: \"2. \").firstMatch",".containing(.group, identifier: \"\\n\").firstMatch",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划；\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element15.click()
        element15.click()
        element7.typeKey(.leftArrow, modifierFlags:.function)
        element7.typeText("(")
        app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划（）；\n2. "]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（）；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（）；\\n2. \"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（）；\\n2. \"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeKey(.leftArrow, modifierFlags:[])
        
        let element16 = app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\n2. "]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. \"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. \"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element16.typeText("dangran youkn buwanmei /buzhunque /bufuhe ,houxu xuyao zai2pinggu ")
        element16.typeKey(.downArrow, modifierFlags:.function)
        app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\n2. 阅读本项目现有的代码。这是我通过Xcode创建x'mu​"]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建x'mu​\"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建x'mu​\"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("benxyuedu benxmu xianyou de diama .zhehsi wo tg Xcodecahungjian")
        app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目"]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目\"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目\"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeKey(.delete, modifierFlags:.option)
        app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\n3. 其他"]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\\n3. 其他\"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\\n3. 其他\"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("chuangjian xmu yibuyibu xuanxinxuanxiang hou shengc de xmu chushidaima wenjian ,shangweipeizhi qita neir ;\r")
        
        let element17 = app2/*@START_MENU_TOKEN@*/.textViews["1. 查看本项目根目录docs/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\n3. 其他已知信息：开发一"]/*[[".textViews",".containing(.group, identifier: \"\\n\")",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\")",".containing(.group, identifier: nil)",".groups.textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\\n3. 其他已知信息：开发一\"]",".textViews[\"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\\n3. 其他已知信息：开发一\"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element17.typeText("3. qita yizhixinxi :kaifa yikuan macOS daunduan ")
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeText("leisi P")
        app2/*@START_MENU_TOKEN@*/.textFields["Search files by name (append :<line No.> to go to line or @<symbol> to go to symbol"]/*[[".groups.textFields[\"Search files by name (append :<line No.> to go to line or @<symbol> to go to symbol\"]",".textFields",".textFields[\"Search files by name (append :<line No.> to go to line or @<symbol> to go to symbol\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("op")
        
        let element18 = app2/*@START_MENU_TOKEN@*/.menuItems["PopClipLike_可行性评估与实施方案.md docs, recently opened"]/*[[".menuItems",".containing(.button, identifier: \"Remove from Recently Opened\")",".containing(.button, identifier: \"Open to the Side\")",".containing(.staticText, identifier: \"recently opened\")",".groups.menuItems[\"PopClipLike_可行性评估与实施方案.md docs, recently opened\"]",".menuItems[\"PopClipLike_可行性评估与实施方案.md docs, recently opened\"]"],[[[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element18.typeText("C")
        element18.typeText("lip")
        groupsQuery2/*@START_MENU_TOKEN@*/.containing(.group, identifier: "Add images").firstMatch/*[[".element(boundBy: 369)",".containing(.comboBox, identifier: \"GPT-5.2-Codex\").firstMatch",".containing(.textView, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\\n2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\\n3. 其他已知信息：开发一\").firstMatch",".containing(.group, identifier: \"Add images\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        app2/*@START_MENU_TOKEN@*/.staticTexts["3. 其他已知信息：开发一款类似PmacOS端"]/*[[".groups.staticTexts[\"3. 其他已知信息：开发一款类似PmacOS端\"]",".staticTexts[\"3. 其他已知信息：开发一款类似PmacOS端\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        element17.typeText("poClip")
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.delete, modifierFlags:[])
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeText("de ")
        element17.typeKey(.rightArrow, modifierFlags:[.command, .function])
        element17.typeText("xtjichajian ")
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.delete, modifierFlags:[])
        element17.typeText("ji ")
        element17.typeKey(.rightArrow, modifierFlags:[.command, .function])
        
        statusApp.activate()
        statusApp/*@START_MENU_TOKEN@*/.statusItems["内存压力 21%"]/*[[".menuBars.statusItems[\"内存压力 21%\"]",".statusItems[\"内存压力 21%\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        chromeApp.activate()
        let element19 = groupsQuery/*@START_MENU_TOKEN@*/.containing(.staticText, identifier: "这是 Web 开发者最容易忽略的三个系统级配置：").firstMatch/*[[".element(boundBy: 106)",".containing(.staticText, identifier: \"这是 Web 开发者最容易忽略的三个系统级配置：\").firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element19.click()
        element19.click()
        
        app2.activate()
        element17.typeText("(")
        element17.typeKey(.leftArrow, modifierFlags:[])
        element17.typeText("wuzhuchaungkzhuchuangkou yingy ")
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeText(",huazhongdian ")
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        groupsQuery2/*@START_MENU_TOKEN@*/.containing(.staticText, identifier: "1. 查看本项目根目录docs/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；").firstMatch/*[[".element(boundBy: 331)",".containing(.staticText, identifier: \"3. 其他已知信息：开发一款类似PoClip的macOS端系统级插件（无主窗口应用，划重点）\").firstMatch",".containing(.staticText, identifier: \"2. 阅读本项目现有的代码。这是我通过Xcode创建项目一步一步选项后生成的项目初始代码文件，尚未配置其他内容；\").firstMatch",".containing(.staticText, identifier: \"1. 查看本项目根目录docs\/文档，是本项目的初版开发计划（当然有可能不完美、不准确、不符合，后续需要再评估）；\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        element17.typeText("kaijiqidong /changzhujinc2de ")
        element17.typeKey(.rightArrow, modifierFlags:[.command, .function])
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeText(",nenggou manzu :zaizhuliu yy (")
        element17.typeKey(.leftArrow, modifierFlags:[])
        element17.typeText("ru llq yemian ")
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeText("nei shub xuanzhongwenben hou nenggou liji zai shubiao fujinchuxain xiaofuchuang")
        element17.typeKey(.delete, modifierFlags:.option)
        element17.typeText("xiao fuchaung caozuotiao ,tigonganniss /fuzhi /fanyi deng anniu .zhxie anniu dainjihou hui tguo jiaoben huozhe peizhi de API keychufa qita yy chengxu ;\r")
        element17.typeText("4. gaiyy yaoqiu xaingjijishi")
        element17.typeKey(.delete, modifierFlags:.option)
        element17.typeText("xianging")
        element17.typeKey(.delete, modifierFlags:.option)
        element17.typeText("xiangyingjishi )")
        element17.typeKey(.delete, modifierFlags:.shift)
        element17.typeText("(")
        element17.typeKey(.leftArrow, modifierFlags:[])
        element17.typeText("haomiaoji ")
        element17.typeKey(.rightArrow, modifierFlags:.function)
        element17.typeText("/jianrong zhuliu duokuan app;\r")
        element17.typeText("5. zhyao kaifatiaoshi gongju shi Xcode,dan youyu woshi webqdkaifa chushen ,")
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:[.option, .function])
        element17.typeKey(.leftArrow, modifierFlags:[.option, .function])
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.leftArrow, modifierFlags:.function)
        element17.typeKey(.delete, modifierFlags:[])
        element17.typeText("shi ")
        element17.typeKey(.rightArrow, modifierFlags:[.command, .function])
        element17.typeText("dui Xcodekaifajishuzhan 0jichu ,kaifa")

        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
