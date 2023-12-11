local util = require("util")
--local util = {}
--util.split = function(inputstr, sep)
--  local result = {}

--  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
--    table.insert(result, str)
--  end

--  return result
--end
--function table.deepcopy(object)
--  local lookup_table = {}
--  local function _copy(object)
--    if type(object) ~= "table" then
--      return object
--    -- don't copy factorio rich objects
--    elseif object.__self then
--      return object
--    elseif lookup_table[object] then
--      return lookup_table[object]
--    end
--    local new_table = {}
--    lookup_table[object] = new_table
--    for index, value in pairs(object) do
--      new_table[_copy(index)] = _copy(value)
--    end
--    return setmetatable(new_table, getmetatable(object))
--  end
--  return _copy(object)
--end

function reset()
    --for _,player in pairs(game.players) do
    --    local item_requester = player.gui.left.item_requester
    --    if item_requester then item_requester.destroy() end
    --end
    --global.settings=nil
end

function error_message(message)
    game.print{"","[",{"mod-name.HelmodAddonRequester"}," ",script.active_mods.HelmodAddonRequester,"] ",{"helmod-addon-requester.error_message"}}
    game.print(message)
end

function get_summary_from_player(player) 
    local HMSummaryPanel = player.gui.screen.HMSummaryPanel
    if not HMSummaryPanel then return end
    local scroll_panel = HMSummaryPanel.content_panel["summary-panel"]["scroll-panel"]

    local summary = {}
    for _,table_name in pairs {"table-factory","table-beacon","table-modules"} do
        local tables = scroll_panel[table_name]
        for _, item in pairs(tables.children) do
            local item_name = string.sub(item.row1.children[1].sprite,6) -- sprite = "item/bulah-bulah"
            local count = tonumber(item.row3.children[1].caption)
            if count~=0 then
                --table.insert(summary, {item_name=item_name, count=count})
                summary[item_name] = count
            end
        end
    end

    return summary
end


function create_gui(event)
    local player_index = event.player_index
    local player = game.players[player_index]

    local HMSummaryPanel = player.gui.screen.HMSummaryPanel
    if not HMSummaryPanel then return end
    local request_panel = HMSummaryPanel.content_panel.add{type="frame",name="request-panel",style="helmod_frame"}
    request_panel.style.horizontally_stretchable = true
    
    local scroll_panel = request_panel.add{type="scroll-pane", name="scroll-pane"}
    scroll_panel.style.horizontally_stretchable = true

    local request_label  = scroll_panel.add{type="label"             ,name="request_label" ,caption={"helmod_common.requests"}, style="helmod_label_title_frame"}
    local horizon_flow   = scroll_panel.add{type="flow"              ,name="horizon_flow"  ,direction="horizontal"}
    --local label  = horizon_flow.add{type="label",caption=game.table_to_json(get_summary_from_player(player))}
    --local label2 = horizon_flow.add{type="label",caption=game.table_to_json(get_summary_from_player(player))}

    --game.player.gui.screen.HMSummaryPanel.content_panel["request-panel"]["scroll-pane"]["horizon_flow"].every_flow
    local every_flow     = horizon_flow.add{type="flow"              ,name="every_flow"    ,direction="vertical"}
    local missing_flow   = horizon_flow.add{type="flow"              ,name="missing_flow"  ,direction="vertical"}
    every_flow.style.width=80

    local every_label   = every_flow  .add{type="label", name="every_label",   caption={"helmod-addon-requester.every"}}
    local missing_label = missing_flow.add{type="label", name="missing_label", caption={"helmod-addon-requester.missing"}}
    local every_label_flow   = every_flow  .add{type="flow", name="every_label_flow"  ,direction="vertical"}
    local missing_label_flow = missing_flow.add{type="flow", name="missing_label_flow",direction="vertical"}
    --every_label  .style.single_line=false
    --missing_label.style.single_line=false

    local every_comb_button   = every_flow  .add{type="sprite-button", name="HMSummaryPanel=combinator=every"  , tooltip={"helmod-addon-requester.every_comb"}, style="helmod_button_menu", sprite="item/constant-combinator"}
    local every_cons_button   = every_flow  .add{type="sprite-button", name="HMSummaryPanel=request=every"     , tooltip={"helmod-addon-requester.every_cons"}, style="helmod_button_menu", sprite="item/construction-robot"}
    local missing_comb_button = missing_flow.add{type="sprite-button", name="HMSummaryPanel=combinator=missing", tooltip={"helmod-addon-requester.missing_comb"}, style="helmod_button_menu", sprite="item/constant-combinator"}
    local missing_cons_button = missing_flow.add{type="sprite-button", name="HMSummaryPanel=request=missing"   , tooltip={"helmod-addon-requester.missing_cons"}, style="helmod_button_menu", sprite="item/construction-robot"}

    update_gui(player)
end

function update_gui(player)
    local every_caption = {"","every"}
    local missing_caption = {"","missing"}
    local missing_summary = {}
    local missing_summary_count = 0
    local summary_count = 0

    local horizontal_flow = player.gui.screen.HMSummaryPanel.content_panel["request-panel"]["scroll-pane"]["horizon_flow"]
    local every_flow   = horizontal_flow.every_flow
    local missing_flow = horizontal_flow.missing_flow
    local every_label_flow   = every_flow  .every_label_flow
    local missing_label_flow = missing_flow.missing_label_flow

    every_label_flow.clear()
    missing_label_flow.clear()

    local summary = get_summary_from_player(player)
    --for _,item in pairs(summary) do
    for item_name,count in pairs(summary) do
        --local item_name = item.item_name
        --local count = item.count
        local missing_count = math.max(count-player.get_item_count(item_name), 0)
        --table.insert(every_caption  , "\n[img=item/"..item_name.."] "..tostring(count))
        --table.insert(missing_caption, "\n[img=item/"..item_name.."] "..tostring(missing_count))
        every_label_flow  .add{type="label", caption="[img=item/"..item_name.."] "..tostring(count)        ,tooltip={"?",{"entity-name."..item_name},{"item-name."..item_name}}}
        missing_label_flow.add{type="label", caption="[img=item/"..item_name.."] "..tostring(missing_count),tooltip={"?",{"entity-name."..item_name},{"item-name."..item_name}}}
        if missing_count~=0 then
            --table.insert(missing_summary, {item_name=item_name, count=missing_count})
            missing_summary[item_name]=missing_count
            missing_summary_count = missing_summary_count+1
        end
        summary_count = summary_count+1
    end
    --every_flow  .every_label  .caption = every_caption
    --missing_flow.missing_label.caption = missing_caption
    

    --game.print(game.table_to_json(summary))
    --game.print(game.table_to_json(missing_summary))
    --every_comb_button.tags  ={summary=summary,count=summary_count}
    --every_cons_button.tags  ={summary=summary,count=summary_count}
    --missing_comb_button.tags={summary=missing_summary,count=missing_summary_count}
    --missing_cons_button.tags={summary=missing_summary,count=missing_summary_count}
    every_flow.tags  ={summary=summary,count=summary_count}
    missing_flow.tags={summary=missing_summary,count=missing_summary_count}

end

function request_for_player(event)
    local player_index = event.player_index
    local player = game.players[player_index]
    local element = event.element

    --game.print("request_for_player")
    --game.print(game.table_to_json(element.parent.tags.summary))
    if element.parent.tags.count ~= 0 then
        player.surface.create_entity{
            name="item-request-proxy",
            position=player.position,
            force=player.force,
            target=player.character,
            modules=element.parent.tags.summary
        }
    else
        player.print{"helmod-addon-requester.no_request"}
    end
end

function create_blueprint_for_player(event)
    local player_index = event.player_index
    local player = game.players[player_index]
    local element = event.element

    --game.print("create_blueprint_for_player")
    --game.print(game.table_to_json(element.parent.tags.summary))
    if element.parent.tags.count ~= 0 then
        local temp_inventory = game.create_inventory(1)
        local slot= temp_inventory[1]
        local entities = {}
        local index=0
        for i=1,math.ceil(element.parent.tags.count/20) do 
            entities[i] = {
                entity_number=i,
                name = "constant-combinator",
                position={i,0},
                connections={{green={}}},
                control_behavior={filters={}}
            }
        end
        for i=1,math.ceil(element.parent.tags.count/20)-1 do 
            table.insert(entities[i  ].connections[1].green, {entity_id=i+1})
            table.insert(entities[i+1].connections[1].green, {entity_id=i  })
        end


        for item_name,count in pairs(element.parent.tags.summary) do
            local entity_number = math.floor(index/20)+1
            local signal_number = index%20+1
            table.insert(entities[entity_number].control_behavior.filters,{
                signal = {type="item", name=item_name},
                count = count,
                index = signal_number
            })
            index = index + 1
        end

        slot.set_stack{name="helmod-requester-blueprint"}

        slot.set_blueprint_entities(entities)
        player.add_to_clipboard(slot)
        player.activate_paste()
        temp_inventory.destroy()
    else
        player.print{"helmod-addon-requester.no_request"}
    end
end
--function move_gui(player)

--end

function on_gui_click(event)
    local success,message = pcall(function ()
        --game.print("00")
        local element=event.element
        --game.print("11")
        if string.sub(element.name,1,2)~= "HM" then 
            return 
        end
        local HM = util.split(element.name, "=")

        --game.print(element.name)
        if HM[1] == "HMSummaryPanel" then
            --game.print("HM[2]="..HM[2])
            if HM[2] == "OPEN" then
                create_gui(event)
            elseif HM[2] == "combinator" then
                create_blueprint_for_player(event)
            elseif HM[2] == "request" then
                request_for_player(event)
            --elseif HM[2] == "minimize-window" then
            --elseif HM[2] == "maximize-window" then
            end
        end


    end)
    if not success then
        reset()
        error_message(message)
    end
end
script.on_event(defines.events.on_gui_click   ,on_gui_click   )


function on_player_main_inventory_changed(event)
    local success,message = pcall(function ()
        local player_index=event.player_index
        local player = game.players[player_index]

        local HMSummaryPanel = player.gui.screen.HMSummaryPanel
        if not HMSummaryPanel then return end
        
        update_gui(player)



    end)
    if not success then
        reset()
        error_message(message)
    end
end
script.on_event(defines.events.on_player_main_inventory_changed   ,on_player_main_inventory_changed   )


    --return game.table_to_json(summary)
--script.on_event(defines.events.on_robot_built_entity   ,on_robot_built_entity   )
--script.on_event(defines.events.on_pre_player_mined_item,on_pre_player_mined_item)
--script.on_event(defines.events.on_robot_pre_mined      ,on_robot_pre_mined      )

--script.on_event(defines.events.script_raised_built     ,script_raised_built     )
--script.on_event(defines.events.script_raised_destroy   ,script_raised_destroy   )

--script.on_event(defines.events.on_built_entity         ,on_built_or_mined   )
--script.on_event(defines.events.on_robot_built_entity   ,on_built_or_mined   )
--script.on_event(defines.events.on_pre_player_mined_item,on_built_or_mined   )
--script.on_event(defines.events.on_robot_pre_mined      ,on_built_or_mined   )

--script.on_event(defines.events.on_built_entity              , on_built                    ) -- {created_entity, player_index, stack, item tags, name, tick}
--script.on_event(defines.events.script_raised_built          , on_built                    ) -- {entity, name, tick}
--script.on_event(defines.events.on_marked_for_deconstruction , on_marked_for_deconstruction) -- {entity, player_index, name, tick}
--script.on_event(defines.events.on_marked_for_upgrade        , on_marked_for_upgrade       ) -- {entity, target, player_index, direction, name, tick}

--script.on_event(defines.events.on_tick   ,on_tick   )
