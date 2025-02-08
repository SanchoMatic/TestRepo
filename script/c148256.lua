-- ブラックロードの絆 (Blacklord's Bond)
local s, id = GetID()

function s.initial_effect(c)
    -- Send 1 "Blacklord" monster from Deck to GY, then add 1 "Blacklord" card from Deck to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.tgfilter(c)
    return c:IsSetCard(0x2226) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.thfilter(c)
    return c:IsSetCard(0x2226) and c:IsAbleToHand()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g1 = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g1 > 0 and Duel.SendtoGrave(g1, REASON_EFFECT) ~= 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g2 = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g2 > 0 then
            Duel.SendtoHand(g2, nil, REASON_EFFECT)
            Duel.ConfirmCards(1-tp, g2)
        end
    end
end