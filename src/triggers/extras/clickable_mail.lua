if not lotj.settings.clickable_mail then return end

lotj.settings.clickable_mailRegexTrigger = tempRegexTrigger(
  [[^(?<id>\d+)\s*\|\s*(?<sender>.+?)\s*\|\s*(?<recipient>.+?)\s*\|\s(?<subject>.+?)$|^(?<empty>)$]],
  function()
    if matches.empty then
      -- killTrigger(lotj.settings.clickable_mailRegexTrigger)
      return false
    end
    local targetNumber = matches.id
    selectString(matches.subject:trim(), 1)
    setUnderline(true)
    setLink([[send("note read ]] .. targetNumber .. [[")]], "note read ".. targetNumber)
    resetFormat()
    return true
  end,
  1
)
