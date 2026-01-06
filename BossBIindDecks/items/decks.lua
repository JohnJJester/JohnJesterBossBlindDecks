SMODS.Atlas{
    key = 'amber_acorn', --atlas key
    path = 'amber_acorn.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71, --width of one card
    py = 95 -- height of one card
}
SMODS.Back {
    key = "amber_acorn",
    atlas = "amber_acorn",
    loc_txt = {
        name = "Amber Acorn",
        text = {
            "{C:attention}+1{} consumable slot.",
            "Start with {C:attention}Riff-Raff{}",
            "Applies the {C:money}Amber Acorn{}",
            "effect to all blinds."
        }
    },
    pos = { x = 0, y = 0 },
   
    apply = function(self, back)
        G.GAME.starting_params.consumable_slots = G.GAME.starting_params.consumable_slots + 1
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_riff_raff")
                card:add_to_deck()
                --card:start_materialize()
                G.jokers:emplace(card)
                return true
            end,
        }))
    end,
    calculate = function(self, back, context, blind)
        if context.setting_blind then
            if #G.jokers.cards > 0 then
                G.jokers:unhighlight_all()
                for _, joker in ipairs(G.jokers.cards) do
                    joker:flip()
                end
                if #G.jokers.cards > 1 then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.jokers:shuffle('aajk')
                                    play_sound('cardSlide1', 0.85)
                                    return true
                                end,
                            }))
                            delay(0.15)
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.jokers:shuffle('aajk')
                                    play_sound('cardSlide1', 1.15)
                                    return true
                                end
                            }))
                            delay(0.15)
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.jokers:shuffle('aajk')
                                    play_sound('cardSlide1', 1)
                                    return true
                                end
                            }))
                            delay(0.5)
                            return true
                        end
                    }))
                end
            end
        end 
    end
}
SMODS.Atlas{
    key = 'verdant_leaf', 
    path = 'verdant_leaf.png', 
    px = 71, 
    py = 95 
}
SMODS.Back {
    key = "verdant_leaf",
    atlas = "verdant_leaf",
    loc_txt = {
        name = "Verdant Leaf",
        text = {
            "Start with {C:attention}2{} {C:purple}Judgements{}.",
            "{C:Attention}Jokers{} are {C:attention}20x{}",
            "more likely to be {C:edition}Negative{}",
            "Applies the {C:green}Verdant Leaf{}",
            "effect to all blinds."
        }
    },
    pos = { x = 0, y = 0 },
    config = { blindActive = true, negativeodds = 6 }, -- 20x more likely ~ 6% chance
    loc_vars = function(self, info_queue, back)
        return {self.config.blindActive}
    end,
    apply = function(self, back)
         G.E_MANAGER:add_event(Event({
            func = function()
                for i = 1, 2 do
                        local card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, "c_judgement")
                        card:add_to_deck()
                        --card:start_materialize()
                        G.consumeables:emplace(card)
                end
                return true
            end,
        }))
    end,
    calculate = function(self, back, context)
        if context.debuff_card and context.debuff_card.area ~= G.jokers then
            if self.config.blindActive then
                return {
                    debuff = true
                }
            end
        end
        if context.selling_card and context.card.ability.set == 'Joker' then
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    self.config.blindActive = false
                    return true
                end
            }))
        end
        if context.opening_shop or context.closing_shop or context.setting_blind or context.starting_blind then
            -- The Creation and immediate destruction of this negative judgement is meant to update the deck to apply the debuff
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    self.config.blindActive = true
                    local card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, "c_judgement")
                    card:add_to_deck()
                    card:set_edition({negative = true}, true)
                    --card:start_materialize()
                    G.consumeables:emplace(card)
                    card:remove()
                    return true
                end
            }))
        end
        if context.reroll_shop or context.opening_shop then
            for i = 1, #G.shop_jokers.cards do
                if math.random(0,100) < self.config.negativeodds then -- can't turn up negetive specific edition rates (as far as I know) so all shop cards are 6% to turn negative (so 6.3 ish%)
                    if G.shop_jokers.cards[i].ability.set == 'Joker' then
                        G.shop_jokers.cards[i]:set_edition({negative = true}, true)
                    end
                end
            end
        end    
    end

}
SMODS.Atlas{
    key = 'violet_vessel', 
    path = 'violet_vessel.png', 
    px = 71, 
    py = 95 
}
SMODS.Back {
    key = "violet_vessel",
    atlas = "violet_vessel",
    loc_txt = {
        name = "Violet Vessel",
        text = {
            "Start with extra {C:money}$25{}",
            "{C:purple}Hyper Ante Scaling{}"
        }
    },
    pos = { x = 0, y = 0 },
    config = { anteScale = 1.2, moneyStart = 25, currentAnte = 1},
    loc_vars = function(self, info_queue, back)
        return {self.config.anteScale}
    end,
    apply = function(self, back)
        G.GAME.starting_params.dollars = G.GAME.starting_params.dollars + self.config.moneyStart
    end,

    calculate = function(self, blind, context)
        if context.end_of_round and not context.repetition and not context.individual and G.GAME.blind.boss then
            self.config.currentAnte = self.config.currentAnte + 1
            -- Formula for scaling up to debate
            G.GAME.starting_params.ante_scaling = self.config.anteScale ^ (self.config.currentAnte)
        end
    end

}

SMODS.Atlas{
    key = 'crimson_heart', 
    path = 'crimson_heart.png', 
    px = 71, 
    py = 95 
}
SMODS.Back {
    key = "crimson_heart",
    atlas = "crimson_heart",
    loc_txt = {
        name = "Crimson Heart",
        text = {
            "{C:attention}+1{} hand size",
            "Start your run with",
            "no {C:hearts}Hearts{} in your deck",
            "Applies the {C:hearts}Crimson Heart{}",
            "effect to all blinds."
        }
    },
    pos = { x = 0, y = 0 },
    config = {jokerSelected = nil, currentDiscards},
    loc_vars = function(self, info_queue, back)
        return{self.config.jokerSelected}
    end,
    apply = function(self, back)
        G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size + 1
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    local v = G.playing_cards[i]
                    if v.base.suit == 'Hearts' then
                        v:remove()
                    end
                end
                return true
            end
        }))
    end,

     calculate = function(self, back, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
            func = function()
                self.config.currentDiscards = G.GAME.current_round.discards_left
                return true
            end
        }))
        end
    
        if context.hand_drawn and G.jokers.cards[1] then
            if self.config.currentDiscards == G.GAME.current_round.discards_left then
                if self.config.jokerSelected then
                    self.config.jokerSelected.debuff = false
                end
                local toselect= pseudorandom_element(G.jokers.cards, 'jjbbd_crimson_heart')
                while toselect == self.config.jokerSelected and #G.jokers.cards > 1 do
                    toselect = pseudorandom_element(G.jokers.cards, 'jjbbd_crimson_heart')
                end
                self.config.jokerSelected = toselect
                SMODS.recalc_debuff(self.config.jokerSelected)
                self.config.jokerSelected:juice_up()
                self.config.jokerSelected.debuff = true 
            else
                G.E_MANAGER:add_event(Event({
                    func = function()
                        self.config.currentDiscards = G.GAME.current_round.discards_left
                        return true
                    end
                }))
            end
        end
    end,

}
SMODS.Atlas{
    key = 'cerulean_bell',
    path = 'cerulean_bell.png', 
    px = 71, 
    py = 95 
}
SMODS.Back {
    key = "cerulean_bell",
    atlas = "cerulean_bell",
    loc_txt = {
        name = "Cerulean Bell",
        text = {
            "{C:blue}+1 Hand",
            "{C:red}+1 Discard{}",
            "Applies the {C:planet}Cerulean Bell{}",
            "effect to all blinds."
        }
    },
    pos = { x = 0, y = 0 },

    apply = function(self, back)
        G.GAME.starting_params.discards = G.GAME.starting_params.discards + 1
        G.GAME.starting_params.hands = G.GAME.starting_params.hands + 1
    end,
    calculate = function(self, back, context)
        if context.hand_drawn then
            local any_forced = nil
            for _, playing_card in ipairs(G.hand.cards) do
                if playing_card.ability.forced_selection then
                    any_forced = true
                end
            end
            if not any_forced then
                G.hand:unhighlight_all()
                local forced_card = pseudorandom_element(G.hand.cards, 'jjbbd_cerulean_bell')
                forced_card.ability.forced_selection = true
                G.hand:add_to_highlighted(forced_card)
            end
        end
    end,
}
