local config = {
    keyBind   = nil,
    checkBox  = nil,
    textEntry = nil,
    multiBox  = nil,
    comboBox  = nil,
    colorPick = nil,
    slider    = nil,
    button    = nil
}

local options = PZAPI.ModOptions:create("BanditsAddOptions", getText("UI_options_BanditsAddOptions"))
config.checkBox = options:addTickBox("AllowBanditIcons", getText("UI_options_AllowBanditIcons"), true, getText("UI_options_AllowBanditIcons_checkBox_tooltip"))