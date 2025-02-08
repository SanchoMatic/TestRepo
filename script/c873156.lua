-- ブラックロードの大公 (Archduke of the Blacklords)
local s, id = GetID()

function s.initial_effect(c)
    -- Send 1 "Blacklord" monster from your Deck to the GY and change level
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.lvtg)
    e1:SetOperation(s.lvop)
    c:RegisterEffect(e1)
    
    -- Inflict damage if your opponent controls a monster Special Summoned from the Extra Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.dmgcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.dmgtg)
    e2:SetOperation(s.dmgop)
    c:RegisterEffect(e2)
end

function s.tgfilter(c)
    return c:IsSetCard(0x2226) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end


function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.lvop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 then
        local c = e:GetHandler()
        local opt = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
        if opt == 0 then
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(e1)
        else
            local e2 = Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_LEVEL)
            e2:SetValue(-1)
            e2:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(e2)
        end
    end
end

function s.dmgcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE) and
           Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x2226), tp, LOCATION_MZONE, 0, 1, nil) and
           Duel.IsExistingMatchingCard(Card.IsSummonLocation, tp, 0, LOCATION_MZONE, 1, nil, LOCATION_EXTRA)
end

function s.dmgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, 500)
end

function s.dmgop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.Damage(1-tp, 500, REASON_EFFECT) then
        Duel.BreakEffect()
        Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_EFFECT)
    end
end