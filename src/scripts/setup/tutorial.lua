lotj = lotj or {}
lotj.tutorial = lotj.tutorial or {}
lotj.tutorial.data = lotj.tutorial.data or {}
local path = getMudletHomeDir() .. "/lotj-ui-tutorial.lua"

local style = [[
  QLabel {
    background-color: #333333;
    border: 1px solid #00aaaa;
    border-top-right-radius: 4px;
    border-top-left-radius: 4px;
    margin: 3px 3px 3px 3px;
    font-family: ]] .. getFont() .. [[;
  }
    QLabel::hover {
      background-color: rgb(0, 102, 102)
    }
    QLabel::!hover {
      background-color :rgb(0, 26, 26)
    }
]]

--- Return values:  
--- `1` : `v1` is newer  
--- `-1`: `v2` is newer  
--- `0` :  Versions are equal
function lotj.tutorial.compareVersions(v1, v2)
  -- Remove 'v' prefix if present
  v1 = v1:gsub("^v", "")
  v2 = v2:gsub("^v", "")

  -- Split versions into parts
  local v1_parts = {}
  local v2_parts = {}

  for num in v1:gmatch("%d+") do
    table.insert(v1_parts, tonumber(num))
  end

  for num in v2:gmatch("%d+") do
    table.insert(v2_parts, tonumber(num))
  end

  -- Compare each part
  for i = 1, math.max(#v1_parts, #v2_parts) do
    local v1_part = v1_parts[i] or 0
    local v2_part = v2_parts[i] or 0

    if v1_part < v2_part then
      return -1  -- v2 is newer
    elseif v1_part > v2_part then
      return 1   -- v1 is newer
    end
  end

  return 0  -- versions are equal
end

--- This function contains all the code that will run when a user installs this
--- version of the package for the first time. There is no guarantee that the
--- user viewed the tutorial for the previous version, so only remove tutorial
--- features if absolutely necessary, prefer to add on.
function lotj.tutorial.run()
  local tutorialElements = {}
  local flashTimerKillID = nil

  local function hideTutorialElements()
    for _, g in ipairs(tutorialElements) do
      g:hide()
    end
    if tutorialElements.upperCon then tutorialElements.upperCon:hide() end
    if tutorialElements.lowerCon then tutorialElements.lowerCon:hide() end
    if tutorialElements.continue then tutorialElements.continue:hide() end
    if tutorialElements.dismissT then tutorialElements.dismissT:hide() end
    if tutorialElements.farewell then tutorialElements.farewell:hide() end
  end

  local function recursiveFlash(label)
    flashTimerKillID = tempTimer(2, function()
      label:flash()
      recursiveFlash(label)
    end)
  end

  -- Tutorial exit
  local function step14()
    hideTutorialElements()
    tutorialElements.farewell = Geyser.Label:new({
      name="tutorial_farwell",
      x="0%",y="25%",width="100%",height="50%",
      fontSize = 14,
      message=[[<center><p>
      You made it to the end of the tutorial!<br>
      If it's your first time playing,<br>
      <b>Welcome to Legends of the Jedi</b>.<br>
      We hope you have a great time here.<br></p>
      Click to end the tutorial and display plugin help docs<br>
      (Scroll up to read it all)
      </center>]]
    }, lotj.layout.rightPanel)
    tutorialElements.farewell:setStyleSheet(style)
    tutorialElements.farewell:setCursor("PointingHand")
    tutorialElements.farewell:raise()
    tutorialElements.farewell:setClickCallback(function()
      hideTutorialElements()
      lotj.layout.selectTab(lotj.layout.upperRightTabData, "map")
      lotj.layout.selectTab(lotj.layout.lowerRightTabData, "all")
      lotj.comlinkInfo.command("help")
      lotj.galaxyMap.showHelp()
      lotj.autoResearch.command("help")
      lotj.mapper.mapCommand("help")
      send("HELP DISCORD")
      tempTimer(1, function()
        cecho("<reset>\nConsider joining the discord! You'll find lots of resources and helpful people.\n")
        eventStartLogging()
      end)
    end)
    -- At the end always set the ran flag and save
    lotj.tutorial.data.ran = true
    table.save(path, lotj.tutorial.data)
  end

  -- Introduce the upper panel: `Galaxy`
  local function step13()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.upperRightTabData, "galaxy")
    local con = tutorialElements.lowerCon
    con:setStyleSheet(style)
    con:clear()
    con:echo([[<center><p>
    The galaxy map is an extremely useful tool for navigating<br>
    the galaxy. With a datapad in your inventory click the<br>
    button to populate it. (You may want to research showplanet<br>
    in a library first) Each point on the map has a right-click<br>
    menu for more options, and custom systems can be added<br>
    with the plus icon<br></p>
    Click here to continue the tutorial
    </center>]])
    con:setCursor("PointingHand")
    con:show()
    con:raise()
    con:setClickCallback(function()
      step14()
    end)
  end

  -- Introduce the upper panel: `System`
  local function step12()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.upperRightTabData, "system")
    local con = tutorialElements.lowerCon
    con:setStyleSheet(style)
    con:clear()
    con:echo([[<center><p>
    Here is the radar for when you make it to space<br>
    Use the plus and minus buttons to change the<br>
    radar's zoom, and click the radar button to<br>
    refresh the radar's data<br></p>
    Click here to continue the tutorial
    </center>]])
    con:setCursor("PointingHand")
    con:show()
    con:raise()
    con:setClickCallback(function()
      step13()
    end)
  end

  -- Introduce the upper panel: `Map`
  local function step11()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.upperRightTabData, "map")
    tutorialElements.lowerCon = Geyser.Label:new({
      name="tutorial_lowerCon",
      x="0%",y="0%",width="100%",height="100%",
      fontSize = 14,
      message = [[<center>
      <p>Above is the Map tab</p>
      <p>Here your position will update as you explore the galaxy!<br>
      Type `map start` in the console to enable the mapper now<br></p>
      Click here to continue the tutorial
      </center>]]
    }, lotj.layout.lowerContainer)
    local con = tutorialElements.lowerCon
    con:setStyleSheet(style)
    con:setCursor("PointingHand")
    con:show()
    con:raise()
    con:setClickCallback(function()
      step12()
    end)
  end

  -- Break down the bottom buttons
  local function step10()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center><p>
    See the row of buttons along the bottom<br>
    Here you can save, load, and reset the defaults<br>
    of all of the settings. Save often, and load your<br>
    save if you reset to defaults by accident<br>
    Reload the profile if an unexpected UI bug occurs<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_GUI_Preferences_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step11()
    end)
  end

  -- Break down the categories: `Debug Options`
  local function step9()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center>
    <p>Scroll down until you see the flashing<br>label and click it<br>
    These settings are self-explanatory<br>
    Interacting with these settings will have no effect<br>
    if debug mode is disabled<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_Debug_Options_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step10()
    end)
  end

  -- Break down the categories: `Advanced Options`
  local function step8()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center>
    <p>Scroll down until you see the flashing<br>label and click it<br><br>
    This category contains settings for advanced users<br>
    If you want to experiment with scripting and expl-<br>
    ore how the package works, enable debug mode<br>
    During play you should always be logging<br>
    Logging in HTML allows you to see in color when you<br>
    review your logs in the future<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_Advanced_Options_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step9()
    end)
  end

  -- Break down the categories: `GUI Preferences`
  local function step7()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center>
    <p>Scroll down until you see the flashing<br>label and click it<br>
    Here you'll find settings relating to the panel<br>you're currently interacting with<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_GUI_Preferences_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step8()
    end)
  end

  -- Break down the categories: `Extras`
  local function step6()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center>
    <p>Scroll down until you see the flashing<br>label and click it<br>
    Here you'll find miscelaneous or uncat-<br>egorized settings<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_Extras_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step7()
    end)
  end

  -- Break down the categories: `Notification Settings`
  local function step5()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center>
    <p>Scroll down until you see the flashing<br>label and click it<br>
    Here you can toggle whether to display<br>a slight flash when<br>a tab receives MUD output<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_Notification_Settings_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step6()
    end)
  end

  -- Break down the categories: `Keybinds`
  local function step4()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center>
    <p>Scroll down until you see the flashing<br>label and click it<br>
    Here you can modify the state of the<br>built-in keybinds<br>
    Don't worry if you don't understand<br>the meaning yet<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_Keybinds_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step5()
    end)
  end

  -- Break down the categories: `Gag Options`
  local function step3()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    local con = tutorialElements.upperCon
    con:clear()
    con:echo([[<center>
    <p>Scroll down until you see the flashing<br>label and click it<br>
    This is where you can edit the settings<br>affecting MUD output<br>
    Hover over an option to view the detailed<br>description of its function<br></p>
    Click here to continue the tutorial
    </center>]])
    con:show()
    con:raise()
    con:setCursor("PointingHand")
    local category = lotj.configWindow.scrollArea.windowList.configContent_lotj.windowList.category_Gag_Options_lotj
    local function resetCategory()
      killTimer(flashTimerKillID)
      category:setClickCallback(function() end)
      category:setCursor("Reset")
    end
    category:setClickCallback(resetCategory)
    category:setCursor("PointingHand")
    recursiveFlash(category)
    con:setClickCallback(function()
      resetCategory()
      step4()
    end)
  end

  -- Introduce the user to the settings tab
  local function step2()
    hideTutorialElements()
    lotj.layout.selectTab(lotj.layout.lowerRightTabData, "settings")
    lotj.layout.lowerRightTabData.tabs["settings"]:setClickCallback("lotj.layout.selectTab", lotj.layout.lowerRightTabData, "settings")

    tutorialElements.upperCon = Geyser.Label:new({
      name="tutorial_upperCon",
      x="0%",y="0%",width="100%",height="100%",
      fontSize = 14,
      message = [[<center>
      <p>Below is the Settings tab</p>
      <p>Here you'll find all the settings the LotJ-UI can modify</p>
      </center>]]
    }, lotj.layout.upperContainer)
    local con = tutorialElements.upperCon
    con:setStyleSheet(style)
    tutorialElements.continue = Geyser.Label:new({
      name="tutorial_continue",
      x="0%",y="0%",width="100%",height="100%"
    }, lotj.layout.rightPanel)
    tutorialElements.continue:setStyleSheet("background-color: transparent")
    tutorialElements.continue:setCursor("PointingHand")
    tutorialElements.continue:setClickCallback(step3)
    con:raise()
    tutorialElements.continue:raise()

    tempTimer(1  , function() lotj.chat["settings"]:flash(0.2) end)
    tempTimer(1.5, function() lotj.chat["settings"]:flash(0.2) end)
    tempTimer(2  , function() lotj.chat["settings"]:flash(0.2) end)
  end

  -- Welcome user to version `2.5.1`
  local function step1()
    tutorialElements.dismissT = Geyser.Label:new({
      name="tutorial_dismissT",
      x="0%",y="0%",width="100%",height="100%",
    })
    tutorialElements.dismissT:setStyleSheet("background-color: rgba(0, 0, 0, 150);")
    tutorialElements.dismissT:setClickCallback(function()
      lotj.tutorial.data.ran = true
      table.save(path, lotj.tutorial.data)
      hideTutorialElements()
    end)
    local welcome_label = Geyser.Label:new({
      name="tutorial_welcome_label",
      x="25%",y="25%",width="50%",height="50%",
      fontSize = getFontSize() + 5,
      message = [[<center>
      <p>Welcome to the new and improved Mudlet LotJ-UI @VERSION@!</p>

      <p>Click here to continue with the short feature tutorial</p><br>
      <p>Click outside the box to dismiss the tutorial permanently</p>
      </center>]]
    })
    table.insert(tutorialElements, welcome_label)
    welcome_label:setCursor("PointingHand")
    welcome_label:setClickCallback(function()
      tutorialElements.dismissT:hide()
      welcome_label:clear()
      welcome_label:setCursor("Reset")
      welcome_label:echo("<center>Do you see the settings tab in the bottom right? Click on it!</center>")
      tempTimer(0.5, [[lotj.layout.markTabUnread(lotj.layout.lowerRightTabData, "settings")]])
      lotj.layout.lowerRightTabData.tabs["settings"]:setClickCallback(step2)
    end)
    welcome_label:setStyleSheet(style)
    tutorialElements.dismissT:raise()
    welcome_label:raise()
  end

  -- Run
  step1()
end

function lotj.tutorial.setup()
  lotj.tutorial.data = {}
  local version = getPackageInfo("@PKGNAME@").version

  if io.exists(path) then
    table.load(path, lotj.tutorial.data)
  else
    lotj.tutorial.data = {
      newest = version,
      ran = false
    }
    table.save(path, lotj.tutorial.data)
  end

  local out = lotj.tutorial.compareVersions(version, lotj.tutorial.data.newest)
  -- We have the same version
  if out == 0 then
    -- Tutorial has already run
    if lotj.tutorial.data.ran then
      return
    -- Tutorial has not run
    else
      lotj.setup.registerEventHandler("lotjUiLoaded", lotj.tutorial.run)
    end
  -- The stored version is newer - probably shouldn't happen
  elseif out == -1 then
    return
  -- We have installed a new version
  elseif out == 1 then
    -- No need to check if the tutorial has already run
    lotj.tutorial.data.ran = false
    lotj.tutorial.data.newest = version
    lotj.setup.registerEventHandler("lotjUiLoaded", lotj.tutorial.run)
  end
end
