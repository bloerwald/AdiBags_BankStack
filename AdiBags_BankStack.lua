local addonName, _ = ...
local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local BankStack = LibStub("AceAddon-3.0"):GetAddon("BankStack")
local mod = AdiBags:NewModule('BankStack', 'ABEvent-1.0')

local actions = {
	['Stack from bank to bags'] = BankStack.CommandDecorator(BankStack.StackSummary, 'bank bags'),
	['Stack from bags to bank'] = BankStack.CommandDecorator(BankStack.StackSummary, 'bags bank'),
	['Compress stacks in bags'] = BankStack.CommandDecorator(BankStack.Compress, 'bags'),
	['Compress stacks in bank'] = BankStack.CommandDecorator(BankStack.Compress, 'bank'),
	['Compress stacks in bags and bank'] = BankStack.CommandDecorator(BankStack.Compress, 'bags bank'),
}
local menu_order = {'Stack from bank to bags', 'Stack from bags to bank',
  'Compress stacks in bags', 'Compress stacks in bags', 'Compress stacks in bags and bank'}
local menu_order_bagsonly = {'Compress stacks in bags'}

mod.uiName = 'BankStack button integration'
mod.uiDesc = 'Add the BankStack button to the minibuttons on top of bags.'

local buttons = {}
local on_click

function mod:OnEnable()
	AdiBags:HookBagFrameCreation(self, 'OnBagFrameCreated')
	for button in pairs(buttons) do
		button:Show()
	end
end
function mod:OnDisable()
	for button in pairs(buttons) do
		button:Hide()
	end
end

function mod:OnBagFrameCreated(bag)
	local container = bag:GetFrame()
	local button = container:CreateModuleButton("BS",
	  5,
	  on_click,
	  {"BankStack: Stack to " .. (bag.isBank and 'Bank' or 'Bags'),},
	  'Right-click to open menu'
	)
	button.isBank = bag.isBank
	buttons[button] = true
end


local menu_bank_open
local menu_bank_closed
local info

local function on_menu()
	if not menu_bank_open then
	  menu_bank_open = CreateFrame("Frame", addonName.."ContextMenuBankOpen", UIParent, "UIDropDownMenuTemplate")
	  UIDropDownMenu_Initialize(menu_bank_open, function(self, level)
        info = UIDropDownMenu_CreateInfo()
        info.isTitle = true
        info.text = 'BankStack'
        UIDropDownMenu_AddButton(info, level)

        for _, text in pairs(menu_order) do
          info = UIDropDownMenu_CreateInfo()
          info.text = text
          info.func = actions[text]
          UIDropDownMenu_AddButton(info, level)
        end
      end, "MENU")
	end
	if not menu_bank_closed then
	  menu_bank_closed = CreateFrame("Frame", addonName.."ContextMenuBankClosed", UIParent, "UIDropDownMenuTemplate")
	  UIDropDownMenu_Initialize(menu_bank_closed, function(self, level)
        info = UIDropDownMenu_CreateInfo()
        info.isTitle = true
        info.text = 'BankStack'
        UIDropDownMenu_AddButton(info, level)

        for _, text in pairs(menu_order_bagsonly) do
          info = UIDropDownMenu_CreateInfo()
          info.text = text
          info.func = actions[text]
          UIDropDownMenu_AddButton(info, level)
        end
      end, "MENU")
	end

	ToggleDropDownMenu(1, nil, BankStack.bank_open and menu_bank_open or menu_bank_closed, 'cursor')
end

function on_click (self, button)
	if button == "RightButton" then
		return on_menu()
	end
	if self.isBank then
	  actions['Stack from bags to bank']()
	elseif BankStack.bank_open then
	  actions['Stack from bank to bags']()
	else
	  actions['Compress stacks in bags']()
	end
end
