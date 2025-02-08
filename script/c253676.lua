-- サシャ、ブラックロードの女主人 (Sasha, Mistress of the Blacklords)
local s, id = GetID()
function s.initial_effect(c)
    -- Add 1 "Blacklord" monster from Deck to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    
    -- Add this card to hand from banishment
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetCondition(s.returncon)
    e2:SetTarget(s.returntg)
    e2:SetOperation(s.returnop)
    c:RegisterEffect(e2)
    
    -- Flag for tracking banishment
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e3:SetCode(EVENT_REMOVE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end

function s.thfilter(c)
    return c:IsSetCard(0x2226) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:GetCode()~=253676
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
        Duel.BreakEffect()
        Duel.DiscardHand(tp, nil, 1, 1, REASON_EFFECT + REASON_DISCARD, nil)
    end
end

function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 2)
end

function s.returncon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetFlagEffect(id) > 0 and Duel.GetTurnPlayer() ~= tp
end

function s.returntg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.returnop(e, tp, eg, ep, ev, re, r, rp)
    Duel.SendtoHand(e:GetHandler(), nil, REASON_EFFECT)
    Duel.ConfirmCards(1-tp, e:GetHandler())
    Duel.BreakEffect()
    Duel.DiscardHand(tp, nil, 1, 1, REASON_EFFECT + REASON_DISCARD, nil)
end